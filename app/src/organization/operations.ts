import { HttpError } from 'wasp/server';
import { checkAuth, checkAdmin, checkOrganization } from '../server/auth/permissions';
import type { Organization } from 'wasp/entities';

// Get current user's organization with full details
export const getUserOrganization = async (args: any, context: any) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const organization = await context.entities.Organization.findUnique({
    where: { id: context.user.organizationId },
    include: {
      users: {
        select: {
          id: true,
          email: true,
          username: true,
          role: true,
          isAdmin: true,
          createdAt: true,
          phoneNumber: true,
        },
        orderBy: { createdAt: 'desc' },
      },
      properties: {
        where: { isActive: true },
        orderBy: { code: 'asc' },
      },
      glAccounts: {
        where: { isActive: true },
        orderBy: { accountNumber: 'asc' },
      },
      expenseTypes: {
        where: { isActive: true },
        orderBy: { name: 'asc' },
      },
    },
  });

  return organization;
};

// Update organization settings (admin only)
type UpdateOrganizationInput = {
  name?: string;
  poApprovalThreshold?: number;
};

export const updateOrganization = async (
  args: UpdateOrganizationInput,
  context: any
) => {
  checkAuth(context.user);
  checkAdmin(context.user);
  checkOrganization(context.user);

  const organization = await context.entities.Organization.update({
    where: { id: context.user.organizationId },
    data: args,
  });

  return organization;
};
