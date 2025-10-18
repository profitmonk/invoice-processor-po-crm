import { HttpError } from 'wasp/server';
import { checkAuth, checkAdmin, checkOrganization } from '../server/auth/permissions';

// ============================================
// PROPERTY OPERATIONS
// ============================================

type CreatePropertyInput = {
  code: string;
  name: string;
  address?: string;
};

export const createProperty = async (
  args: CreatePropertyInput,
  context: any
) => {
  checkAuth(context.user);
  checkAdmin(context.user);
  checkOrganization(context.user);

  const property = await context.entities.Property.create({
    data: {
      organizationId: context.user.organizationId,
      code: args.code.toUpperCase(),
      name: args.name,
      address: args.address,
    },
  });

  return property;
};

export const getProperties = async (args: any, context: any) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const properties = await context.entities.Property.findMany({
    where: {
      organizationId: context.user.organizationId,
      isActive: true,
    },
    orderBy: { code: 'asc' },
  });

  return properties;
};

type UpdatePropertyInput = {
  id: string;
  code?: string;
  name?: string;
  address?: string;
  isActive?: boolean;
};

export const updateProperty = async (
  args: UpdatePropertyInput,
  context: any
) => {
  checkAuth(context.user);
  checkAdmin(context.user);

  const { id, ...updateData } = args;

  const property = await context.entities.Property.update({
    where: { id },
    data: updateData,
  });

  return property;
};

type DeletePropertyInput = {
  id: string;
};

export const deleteProperty = async (
  args: DeletePropertyInput,
  context: any
) => {
  checkAuth(context.user);
  checkAdmin(context.user);

  // Soft delete by setting isActive to false
  await context.entities.Property.update({
    where: { id: args.id },
    data: { isActive: false },
  });

  return { success: true };
};

// ============================================
// GL ACCOUNT OPERATIONS
// ============================================

type CreateGLAccountInput = {
  accountNumber: string;
  name: string;
  accountType: string;
  annualBudget?: number;
};

export const createGLAccount = async (
  args: CreateGLAccountInput,
  context: any
) => {
  checkAuth(context.user);
  checkAdmin(context.user);
  checkOrganization(context.user);

  const glAccount = await context.entities.GLAccount.create({
    data: {
      organizationId: context.user.organizationId,
      accountNumber: args.accountNumber,
      name: args.name,
      accountType: args.accountType,
      annualBudget: args.annualBudget,
    },
  });

  return glAccount;
};

export const getGLAccounts = async (args: any, context: any) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const glAccounts = await context.entities.GLAccount.findMany({
    where: {
      organizationId: context.user.organizationId,
      isActive: true,
    },
    orderBy: { accountNumber: 'asc' },
  });

  return glAccounts;
};

type UpdateGLAccountInput = {
  id: string;
  accountNumber?: string;
  name?: string;
  accountType?: string;
  annualBudget?: number;
  isActive?: boolean;
};

export const updateGLAccount = async (
  args: UpdateGLAccountInput,
  context: any
) => {
  checkAuth(context.user);
  checkAdmin(context.user);

  const { id, ...updateData } = args;

  const glAccount = await context.entities.GLAccount.update({
    where: { id },
    data: updateData,
  });

  return glAccount;
};

type DeleteGLAccountInput = {
  id: string;
};

export const deleteGLAccount = async (
  args: DeleteGLAccountInput,
  context: any
) => {
  checkAuth(context.user);
  checkAdmin(context.user);

  await context.entities.GLAccount.update({
    where: { id: args.id },
    data: { isActive: false },
  });

  return { success: true };
};

// ============================================
// EXPENSE TYPE OPERATIONS
// ============================================

type CreateExpenseTypeInput = {
  name: string;
  code: string;
};

export const createExpenseType = async (
  args: CreateExpenseTypeInput,
  context: any
) => {
  checkAuth(context.user);
  checkAdmin(context.user);
  checkOrganization(context.user);

  const expenseType = await context.entities.ExpenseType.create({
    data: {
      organizationId: context.user.organizationId,
      name: args.name,
      code: args.code.toUpperCase(),
    },
  });

  return expenseType;
};

export const getExpenseTypes = async (args: any, context: any) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const expenseTypes = await context.entities.ExpenseType.findMany({
    where: {
      organizationId: context.user.organizationId,
      isActive: true,
    },
    orderBy: { name: 'asc' },
  });

  return expenseTypes;
};

type UpdateExpenseTypeInput = {
  id: string;
  name?: string;
  code?: string;
  isActive?: boolean;
};

export const updateExpenseType = async (
  args: UpdateExpenseTypeInput,
  context: any
) => {
  checkAuth(context.user);
  checkAdmin(context.user);

  const { id, ...updateData } = args;

  const expenseType = await context.entities.ExpenseType.update({
    where: { id },
    data: updateData,
  });

  return expenseType;
};

type DeleteExpenseTypeInput = {
  id: string;
};

export const deleteExpenseType = async (
  args: DeleteExpenseTypeInput,
  context: any
) => {
  checkAuth(context.user);
  checkAdmin(context.user);

  await context.entities.ExpenseType.update({
    where: { id: args.id },
    data: { isActive: false },
  });

  return { success: true };
};
