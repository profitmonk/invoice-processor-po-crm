import { HttpError } from 'wasp/server';
import type { User } from 'wasp/entities';

// Define UserRole enum locally since it's not exported from entities
type UserRole = 'USER' | 'PROPERTY_MANAGER' | 'ACCOUNTING' | 'CORPORATE' | 'ADMIN';

export function checkAuth(user: User | null): asserts user is User {
  if (!user) {
    throw new HttpError(401, 'You must be logged in');
  }
}

export function checkOrganization(user: User): void {
  if (!user.organizationId) {
    throw new HttpError(400, 'User must belong to an organization');
  }
}

export function checkRole(user: User, allowedRoles: UserRole[]): void {
  if (!allowedRoles.includes(user.role as UserRole)) {
    throw new HttpError(403, `Access denied. Required role: ${allowedRoles.join(' or ')}`);
  }
}

export function checkAdmin(user: User): void {
  if (!user.isAdmin && user.role !== 'ADMIN') {
    throw new HttpError(403, 'Admin access required');
  }
}

export function checkSameOrganization(user: User, targetOrgId: string): void {
  if (user.organizationId !== targetOrgId) {
    throw new HttpError(403, 'Cannot access resources from other organizations');
  }
}

// Permission levels
export const canApproveAtStep = (userRole: string, stepNumber: number): boolean => {
  switch (stepNumber) {
    case 1:
      return userRole === 'PROPERTY_MANAGER' || userRole === 'ADMIN';
    case 2:
      return userRole === 'ACCOUNTING' || userRole === 'ADMIN';
    case 3:
      return userRole === 'CORPORATE' || userRole === 'ADMIN';
    default:
      return false;
  }
};

export const canCreatePO = (userRole: string): boolean => {
  return true; // All roles can create POs per your requirements
};

export const canEditPO = (user: User, poCreatorId: string, poStatus: string): boolean => {
  // Can edit if: creator and status is DRAFT, or admin
  return (user.id === poCreatorId && poStatus === 'DRAFT') || user.isAdmin;
};

export const canDeletePO = (user: User, poCreatorId: string, poStatus: string): boolean => {
  // Can delete if: creator and status is DRAFT, or admin
  return (user.id === poCreatorId && poStatus === 'DRAFT') || user.isAdmin;
};
