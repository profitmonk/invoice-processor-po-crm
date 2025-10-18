import { HttpError } from 'wasp/server';
import { checkAuth, checkAdmin, checkOrganization, checkSameOrganization } from '../server/auth/permissions';
// Define UserRole locally
type UserRole = 'USER' | 'PROPERTY_MANAGER' | 'ACCOUNTING' | 'CORPORATE' | 'ADMIN';
import crypto from 'crypto';
import { emailSender } from 'wasp/server/email';

// Invite user to organization
type InviteUserInput = {
  email: string;
  role: UserRole;
  phoneNumber?: string;
};

export const inviteUserToOrganization = async (
  args: InviteUserInput,
  context: any
) => {
  checkAuth(context.user);
  checkAdmin(context.user);
  checkOrganization(context.user);

  const { email, role, phoneNumber } = args;

  // Check if user already exists IN THIS ORGANIZATION
  const existingUser = await context.entities.User.findUnique({
    where: { email },
  });

  if (existingUser && existingUser.organizationId === context.user.organizationId) {
    throw new HttpError(400, 'User is already in this organization');
  }

  if (existingUser && existingUser.organizationId !== null) {
    throw new HttpError(400, 'User belongs to another organization');
  }

  // If user exists but has no organization (was removed), re-invite them
  if (existingUser && existingUser.organizationId === null) {
    // Update existing user instead of creating new one
    const invitationToken = crypto.randomBytes(32).toString('hex');
    const invitationExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

    const updatedUser = await context.entities.User.update({
      where: { id: existingUser.id },
      data: {
        role,
        phoneNumber,
        organizationId: context.user.organizationId,
        invitedById: context.user.id,
        invitationToken,
        invitationExpiresAt,
      },
    });

    // Send invitation email
    const invitationUrl = `${process.env.WASP_WEB_CLIENT_URL}/accept-invitation?token=${invitationToken}`;
    
    try {
      await emailSender.send({
        to: email,
        subject: 'You\'ve been invited to join our organization',
        text: `You've been invited to join our organization. Click here to accept: ${invitationUrl}`,
        html: `
          <h2>You've been invited!</h2>
          <p>You've been invited to join our organization with the role of <strong>${role}</strong>.</p>
          <p><a href="${invitationUrl}">Click here to accept the invitation</a></p>
          <p>This invitation expires in 7 days.</p>
        `,
      });
      console.log(`✅ Invitation email sent to ${email}`);
    } catch (error) {
      console.error('Failed to send invitation email:', error);
      console.log(`📧 Invitation URL for ${email}: ${invitationUrl}`);
    }

    return {
      id: updatedUser.id,
      email: updatedUser.email,
      role: updatedUser.role,
      invitationToken,
      invitationUrl,
    };
  }

  // Rest of the original function for new users...
  const invitationToken = crypto.randomBytes(32).toString('hex');
  const invitationExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

  const newUser = await context.entities.User.create({
    data: {
      email,
      role,
      phoneNumber,
      organizationId: context.user.organizationId,
      invitedById: context.user.id,
      invitationToken,
      invitationExpiresAt,
      credits: 3,
    },
  });

  const invitationUrl = `${process.env.WASP_WEB_CLIENT_URL}/accept-invitation?token=${invitationToken}`;
  
  try {
    await emailSender.send({
      to: email,
      subject: 'You\'ve been invited to join our organization',
      text: `You've been invited to join our organization. Click here to accept: ${invitationUrl}`,
      html: `
        <h2>You've been invited!</h2>
        <p>You've been invited to join our organization with the role of <strong>${role}</strong>.</p>
        <p><a href="${invitationUrl}">Click here to accept the invitation</a></p>
        <p>This invitation expires in 7 days.</p>
      `,
    });
    console.log(`✅ Invitation email sent to ${email}`);
  } catch (error) {
    console.error('Failed to send invitation email:', error);
    console.log(`📧 Invitation URL for ${email}: ${invitationUrl}`);
  }

  return {
    id: newUser.id,
    email: newUser.email,
    role: newUser.role,
    invitationToken,
    invitationUrl,
  };
};

// Accept invitation and complete onboarding
type AcceptInvitationInput = {
  token: string;
  username: string;
  password: string;
};

export const acceptInvitation = async (
  args: AcceptInvitationInput,
  context: any
) => {
  const { token, username, password } = args;

  // Find user by invitation token
  const user = await context.entities.User.findUnique({
    where: { invitationToken: token },
  });

  if (!user) {
    throw new HttpError(404, 'Invalid invitation token');
  }

  if (user.invitationExpiresAt && new Date() > user.invitationExpiresAt) {
    throw new HttpError(400, 'Invitation has expired');
  }

  if (user.hasCompletedOnboarding) {
    throw new HttpError(400, 'Invitation already accepted');
  }

  // Update user with credentials
  // Note: You'll need to handle password hashing via Wasp's auth system
  // This is a simplified version
  const updatedUser = await context.entities.User.update({
    where: { id: user.id },
    data: {
      username,
      hasCompletedOnboarding: true,
      invitationToken: null,
      invitationExpiresAt: null,
    },
  });

  return {
    success: true,
    userId: updatedUser.id,
  };
};

// Update user role (admin only)
type UpdateUserRoleInput = {
  userId: string;
  role: UserRole;
};

export const updateUserRole = async (
  args: UpdateUserRoleInput,
  context: any
) => {
  checkAuth(context.user);
  checkAdmin(context.user);

  const { userId, role } = args;

  // Get target user
  const targetUser = await context.entities.User.findUnique({
    where: { id: userId },
  });

  if (!targetUser) {
    throw new HttpError(404, 'User not found');
  }

  // Ensure same organization
  if (targetUser.organizationId) {
    checkSameOrganization(context.user, targetUser.organizationId);
  }

  // Update role
  const updatedUser = await context.entities.User.update({
    where: { id: userId },
    data: { role },
  });

  // Create notification for the user
  await context.entities.Notification.create({
    data: {
      userId: userId,
      type: 'ROLE_CHANGED',
      title: 'Your role has been updated',
      message: `Your role has been changed to ${role}`,
      read: false,
    },
  });

  return {
    id: updatedUser.id,
    email: updatedUser.email,
    role: updatedUser.role,
  };
};

// Get users by role (for selecting approvers)
type GetUsersByRoleInput = {
  role: UserRole;
};

export const getUsersByRole = async (
  args: GetUsersByRoleInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const users = await context.entities.User.findMany({
    where: {
      organizationId: context.user.organizationId,
      role: args.role,
    },
    select: {
      id: true,
      email: true,
      username: true,
      role: true,
      phoneNumber: true,
    },
    orderBy: { email: 'asc' },
  });

  return users;
};

// Remove user from organization (admin only)
type RemoveUserInput = {
  userId: string;
};

export const removeUserFromOrganization = async (
  args: RemoveUserInput,
  context: any
) => {
  checkAuth(context.user);
  checkAdmin(context.user);

  const { userId } = args;

  // Cannot remove yourself
  if (userId === context.user.id) {
    throw new HttpError(400, 'Cannot remove yourself');
  }

  // Get target user
  const targetUser = await context.entities.User.findUnique({
    where: { id: userId },
  });

  if (!targetUser) {
    throw new HttpError(404, 'User not found');
  }

  // Ensure same organization
  if (targetUser.organizationId) {
    checkSameOrganization(context.user, targetUser.organizationId);
  }

  // Remove from organization (set organizationId to null)
  await context.entities.User.update({
    where: { id: userId },
    data: {
      organizationId: null,
      role: 'USER',
    },
  });

  // Actually DELETE the user instead of just removing from organization
  await context.entities.User.delete({
    where: { id: userId },
  });

  return { success: true };
};
