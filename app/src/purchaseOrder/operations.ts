import { HttpError } from 'wasp/server';
import { checkAuth, checkOrganization, canCreatePO, canEditPO, canDeletePO } from '../server/auth/permissions';

// ============================================
// CREATE PURCHASE ORDER
// ============================================

type CreatePurchaseOrderInput = {
  vendor: string;
  description: string;
  expenseTypeId: string;
  poDate?: Date;
  lineItems: {
    description: string;
    propertyId: string;
    glAccountId: string;
    quantity: number;
    unitPrice: number;
    taxAmount: number;
  }[];
  isTemplate?: boolean;
  templateName?: string;
  submitForApproval?: boolean; // If false, save as draft
};

export const createPurchaseOrder = async (
  args: CreatePurchaseOrderInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  if (!canCreatePO(context.user.role)) {
    throw new HttpError(403, 'You do not have permission to create purchase orders');
  }

  const { lineItems, submitForApproval, ...poData } = args;

  // Validate line items
  if (!lineItems || lineItems.length === 0) {
    throw new HttpError(400, 'Purchase order must have at least one line item');
  }

  // Calculate totals
  let subtotal = 0;
  let totalTax = 0;

  lineItems.forEach((item) => {
    const lineTotal = item.quantity * item.unitPrice;
    subtotal += lineTotal;
    totalTax += item.taxAmount;
  });

  const totalAmount = subtotal + totalTax;

  // Generate PO Number
  const lastPO = await context.entities.PurchaseOrder.findFirst({
    where: { organizationId: context.user.organizationId },
    orderBy: { createdAt: 'desc' },
  });

  let poNumber = '2001';
  if (lastPO && lastPO.poNumber) {
    const lastNumber = parseInt(lastPO.poNumber);
    poNumber = (lastNumber + 1).toString();
  }

  // Check if approval is required
  const organization = await context.entities.Organization.findUnique({
    where: { id: context.user.organizationId },
  });

  const requiresApproval = totalAmount >= (organization?.poApprovalThreshold || 500);

  // Create PO
  const purchaseOrder = await context.entities.PurchaseOrder.create({
    data: {
      organizationId: context.user.organizationId,
      createdById: context.user.id,
      poNumber,
      vendor: poData.vendor,
      description: poData.description,
      expenseTypeId: poData.expenseTypeId,
      poDate: poData.poDate || new Date(),
      subtotal,
      taxAmount: totalTax,
      totalAmount,
      requiresApproval,
      status: submitForApproval && requiresApproval ? 'PENDING_APPROVAL' : 'DRAFT',
      isTemplate: poData.isTemplate || false,
      templateName: poData.templateName,
      lineItems: {
        create: lineItems.map((item, index) => ({
          lineNumber: index + 1,
          description: item.description,
          propertyId: item.propertyId,
          glAccountId: item.glAccountId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          taxAmount: item.taxAmount,
          totalAmount: item.quantity * item.unitPrice + item.taxAmount,
        })),
      },
    },
    include: {
      lineItems: true,
      expenseType: true,
    },
  });

  // If submitted for approval and requires it, create approval steps
  if (submitForApproval && requiresApproval) {
    await createApprovalSteps(purchaseOrder.id, context);
  }

  return purchaseOrder;
};

// Helper function to create approval steps
async function createApprovalSteps(purchaseOrderId: string, context: any) {
  const approvalSteps = [
    { stepNumber: 1, stepName: 'Property Manager', requiredRole: 'PROPERTY_MANAGER' },
    { stepNumber: 2, stepName: 'Accounting', requiredRole: 'ACCOUNTING' },
    { stepNumber: 3, stepName: 'Corporate', requiredRole: 'CORPORATE' },
  ];

  await Promise.all(
    approvalSteps.map((step) =>
      context.entities.ApprovalStep.create({
        data: {
          purchaseOrderId,
          stepNumber: step.stepNumber,
          stepName: step.stepName,
          requiredRole: step.requiredRole as any,
          status: 'PENDING',
        },
      })
    )
  );

  // Update PO to set current approval step
  await context.entities.PurchaseOrder.update({
    where: { id: purchaseOrderId },
    data: { currentApprovalStep: 1 },
  });
}

// ============================================
// GET PURCHASE ORDERS
// ============================================

type GetPurchaseOrdersInput = {
  status?: string;
  isTemplate?: boolean;
  limit?: number;
};

export const getPurchaseOrders = async (
  args: GetPurchaseOrdersInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const { status, isTemplate, limit = 50 } = args;

  const where: any = {
    organizationId: context.user.organizationId,
  };

  if (status) {
    where.status = status;
  }

  if (isTemplate !== undefined) {
    where.isTemplate = isTemplate;
  }

  const purchaseOrders = await context.entities.PurchaseOrder.findMany({
    where,
    include: {
      createdBy: {
        select: {
          id: true,
          email: true,
          username: true,
          role: true,
        },
      },
      expenseType: true,
      lineItems: {
        include: {
          property: true,
          glAccount: true,
        },
        orderBy: { lineNumber: 'asc' },
      },
      approvalSteps: {
        include: {
          approvedBy: {
            select: {
              id: true,
              email: true,
              username: true,
            },
          },
        },
        orderBy: { stepNumber: 'asc' },
      },
    },
    orderBy: { createdAt: 'desc' },
    take: limit,
  });

  return purchaseOrders;
};

// ============================================
// GET SINGLE PURCHASE ORDER
// ============================================

type GetPurchaseOrderInput = {
  id: string;
};

export const getPurchaseOrder = async (
  args: GetPurchaseOrderInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const purchaseOrder = await context.entities.PurchaseOrder.findUnique({
    where: { id: args.id },
    include: {
      createdBy: {
        select: {
          id: true,
          email: true,
          username: true,
          role: true,
        },
      },
      expenseType: true,
      lineItems: {
        include: {
          property: true,
          glAccount: true,
        },
        orderBy: { lineNumber: 'asc' },
      },
      approvalSteps: {
        include: {
          approvedBy: {
            select: {
              id: true,
              email: true,
              username: true,
            },
          },
        },
        orderBy: { stepNumber: 'asc' },
      },
      linkedInvoice: true,
    },
  });

  if (!purchaseOrder) {
    throw new HttpError(404, 'Purchase order not found');
  }

  // Check if user has access to this PO
  if (purchaseOrder.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  return purchaseOrder;
};

// ============================================
// UPDATE PURCHASE ORDER
// ============================================

type UpdatePurchaseOrderInput = {
  id: string;
  vendor?: string;
  description?: string;
  expenseTypeId?: string;
  lineItems?: {
    id?: string;
    description: string;
    propertyId: string;
    glAccountId: string;
    quantity: number;
    unitPrice: number;
    taxAmount: number;
  }[];
};

export const updatePurchaseOrder = async (
  args: UpdatePurchaseOrderInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const { id, lineItems, ...updateData } = args;

  // Get existing PO
  const existingPO = await context.entities.PurchaseOrder.findUnique({
    where: { id },
    include: { lineItems: true },
  });

  if (!existingPO) {
    throw new HttpError(404, 'Purchase order not found');
  }

  if (existingPO.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  if (!canEditPO(context.user, existingPO.createdById, existingPO.status)) {
    throw new HttpError(403, 'You can only edit draft POs that you created');
  }

  // If line items provided, recalculate totals
  let subtotal = existingPO.subtotal;
  let totalTax = existingPO.taxAmount;
  let totalAmount = existingPO.totalAmount;

  if (lineItems) {
    subtotal = 0;
    totalTax = 0;

    lineItems.forEach((item) => {
      const lineTotal = item.quantity * item.unitPrice;
      subtotal += lineTotal;
      totalTax += item.taxAmount;
    });

    totalAmount = subtotal + totalTax;

    // Delete existing line items
    await context.entities.POLineItem.deleteMany({
      where: { purchaseOrderId: id },
    });
  }

  // Update PO
  const purchaseOrder = await context.entities.PurchaseOrder.update({
    where: { id },
    data: {
      ...updateData,
      ...(lineItems && {
        subtotal,
        taxAmount: totalTax,
        totalAmount,
        lineItems: {
          create: lineItems.map((item, index) => ({
            lineNumber: index + 1,
            description: item.description,
            propertyId: item.propertyId,
            glAccountId: item.glAccountId,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            taxAmount: item.taxAmount,
            totalAmount: item.quantity * item.unitPrice + item.taxAmount,
          })),
        },
      }),
    },
    include: {
      lineItems: {
        include: {
          property: true,
          glAccount: true,
        },
      },
      expenseType: true,
    },
  });

  return purchaseOrder;
};

// ============================================
// SUBMIT PO FOR APPROVAL
// ============================================

type SubmitForApprovalInput = {
  id: string;
};

export const submitPurchaseOrderForApproval = async (
  args: SubmitForApprovalInput,
  context: any
) => {
  checkAuth(context.user);

  const purchaseOrder = await context.entities.PurchaseOrder.findUnique({
    where: { id: args.id },
  });

  if (!purchaseOrder) {
    throw new HttpError(404, 'Purchase order not found');
  }

  if (purchaseOrder.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  if (purchaseOrder.createdById !== context.user.id) {
    throw new HttpError(403, 'Only the creator can submit for approval');
  }

  if (purchaseOrder.status !== 'DRAFT') {
    throw new HttpError(400, 'Only draft POs can be submitted for approval');
  }

  if (!purchaseOrder.requiresApproval) {
    throw new HttpError(400, 'This PO does not require approval');
  }

  // Create approval steps if they don't exist
  const existingSteps = await context.entities.ApprovalStep.findMany({
    where: { purchaseOrderId: args.id },
  });

  if (existingSteps.length === 0) {
    await createApprovalSteps(args.id, context);
  }

  // Update PO status
  await context.entities.PurchaseOrder.update({
    where: { id: args.id },
    data: {
      status: 'PENDING_APPROVAL',
      currentApprovalStep: 1,
    },
  });

  // We'll add notification sending in Phase 6
  // TODO: Send notification to first approver

  return { success: true };
};

// ============================================
// DELETE PURCHASE ORDER
// ============================================

type DeletePurchaseOrderInput = {
  id: string;
};

export const deletePurchaseOrder = async (
  args: DeletePurchaseOrderInput,
  context: any
) => {
  checkAuth(context.user);

  const purchaseOrder = await context.entities.PurchaseOrder.findUnique({
    where: { id: args.id },
  });

  if (!purchaseOrder) {
    throw new HttpError(404, 'Purchase order not found');
  }

  if (purchaseOrder.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  if (!canDeletePO(context.user, purchaseOrder.createdById, purchaseOrder.status)) {
    throw new HttpError(403, 'You can only delete draft POs that you created');
  }

  // Delete PO (cascades to line items and approval steps)
  await context.entities.PurchaseOrder.delete({
    where: { id: args.id },
  });

  return { success: true };
};

// ============================================
// CANCEL PURCHASE ORDER
// ============================================

type CancelPurchaseOrderInput = {
  id: string;
};

export const cancelPurchaseOrder = async (
  args: CancelPurchaseOrderInput,
  context: any
) => {
  checkAuth(context.user);

  const purchaseOrder = await context.entities.PurchaseOrder.findUnique({
    where: { id: args.id },
  });

  if (!purchaseOrder) {
    throw new HttpError(404, 'Purchase order not found');
  }

  if (purchaseOrder.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  if (purchaseOrder.createdById !== context.user.id && !context.user.isAdmin) {
    throw new HttpError(403, 'Only the creator or admin can cancel a PO');
  }

  if (purchaseOrder.status === 'CANCELLED') {
    throw new HttpError(400, 'PO is already cancelled');
  }

  if (purchaseOrder.status === 'INVOICED') {
    throw new HttpError(400, 'Cannot cancel a PO that has been invoiced');
  }

  await context.entities.PurchaseOrder.update({
    where: { id: args.id },
    data: { status: 'CANCELLED' },
  });

  return { success: true };
};

// ============================================
// GET PO TEMPLATES
// ============================================

export const getPurchaseOrderTemplates = async (args: any, context: any) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const templates = await context.entities.PurchaseOrder.findMany({
    where: {
      organizationId: context.user.organizationId,
      isTemplate: true,
    },
    include: {
      expenseType: true,
      lineItems: {
        include: {
          property: true,
          glAccount: true,
        },
        orderBy: { lineNumber: 'asc' },
      },
    },
    orderBy: { templateName: 'asc' },
  });

  return templates;
};

// ============================================
// CREATE PO FROM TEMPLATE
// ============================================

type CreateFromTemplateInput = {
  templateId: string;
  vendor?: string;
};

export const createPurchaseOrderFromTemplate = async (
  args: CreateFromTemplateInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const template = await context.entities.PurchaseOrder.findUnique({
    where: { id: args.templateId },
    include: {
      lineItems: true,
    },
  });

  if (!template) {
    throw new HttpError(404, 'Template not found');
  }

  if (template.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  if (!template.isTemplate) {
    throw new HttpError(400, 'This is not a template');
  }

  // Create new PO from template
  const lineItems = template.lineItems.map((item: any) => ({
    description: item.description,
    propertyId: item.propertyId,
    glAccountId: item.glAccountId,
    quantity: item.quantity,
    unitPrice: item.unitPrice,
    taxAmount: item.taxAmount,
  }));

  const newPO = await createPurchaseOrder(
    {
      vendor: args.vendor || template.vendor,
      description: template.description,
      expenseTypeId: template.expenseTypeId,
      lineItems,
      submitForApproval: false,
    },
    context
  );

  return newPO;
};
