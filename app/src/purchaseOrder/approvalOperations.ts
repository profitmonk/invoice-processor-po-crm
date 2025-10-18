import { HttpError } from 'wasp/server';
import { checkAuth, checkOrganization, canApproveAtStep } from '../server/auth/permissions';

// ============================================
// APPROVE PURCHASE ORDER
// ============================================

type ApprovePurchaseOrderInput = {
  purchaseOrderId: string;
  comment?: string;
};

export const approvePurchaseOrder = async (
  args: ApprovePurchaseOrderInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const { purchaseOrderId, comment } = args;

  // Get PO with approval steps
  const purchaseOrder = await context.entities.PurchaseOrder.findUnique({
    where: { id: purchaseOrderId },
    include: {
      approvalSteps: {
        orderBy: { stepNumber: 'asc' },
      },
    },
  });

  if (!purchaseOrder) {
    throw new HttpError(404, 'Purchase order not found');
  }

  if (purchaseOrder.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  if (purchaseOrder.status !== 'PENDING_APPROVAL') {
    throw new HttpError(400, 'Purchase order is not pending approval');
  }

  // Get current approval step
  const currentStep = purchaseOrder.approvalSteps.find(
    (step: any) => step.stepNumber === purchaseOrder.currentApprovalStep
  );

  if (!currentStep) {
    throw new HttpError(400, 'No pending approval step found');
  }

  // Check if user has permission to approve this step
  if (!canApproveAtStep(context.user.role, currentStep.stepNumber)) {
    throw new HttpError(403, `Only ${currentStep.requiredRole} can approve this step`);
  }

  // Update approval step
  await context.entities.ApprovalStep.update({
    where: { id: currentStep.id },
    data: {
      status: 'APPROVED',
      approvedById: context.user.id,
      approvedAt: new Date(),
      comment: comment || null,
    },
  });

  // Record approval action
  await context.entities.ApprovalAction.create({
    data: {
      userId: context.user.id,
      purchaseOrderId,
      stepNumber: currentStep.stepNumber,
      action: 'APPROVED',
      comment: comment || null,
    },
  });

  // Check if there are more steps
  const nextStep = purchaseOrder.approvalSteps.find(
    (step: any) => step.stepNumber === currentStep.stepNumber + 1
  );

  if (nextStep) {
    // Move to next approval step
    await context.entities.PurchaseOrder.update({
      where: { id: purchaseOrderId },
      data: { currentApprovalStep: nextStep.stepNumber },
    });

    // TODO: Send notification to next approver (Phase 6)
  } else {
    // All steps approved - mark PO as approved
    await context.entities.PurchaseOrder.update({
      where: { id: purchaseOrderId },
      data: {
        status: 'APPROVED',
        currentApprovalStep: null,
      },
    });

    // Create notification for PO creator
    await context.entities.Notification.create({
      data: {
        userId: purchaseOrder.createdById,
        type: 'PO_APPROVED',
        title: 'Purchase Order Approved',
        message: `Purchase order #${purchaseOrder.poNumber} has been fully approved`,
        purchaseOrderId,
        read: false,
      },
    });
  }

  return { success: true };
};

// ============================================
// REJECT PURCHASE ORDER
// ============================================

type RejectPurchaseOrderInput = {
  purchaseOrderId: string;
  comment: string;
};

export const rejectPurchaseOrder = async (
  args: RejectPurchaseOrderInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const { purchaseOrderId, comment } = args;

  if (!comment || comment.trim().length === 0) {
    throw new HttpError(400, 'Comment is required when rejecting');
  }

  // Get PO with approval steps
  const purchaseOrder = await context.entities.PurchaseOrder.findUnique({
    where: { id: purchaseOrderId },
    include: {
      approvalSteps: {
        orderBy: { stepNumber: 'asc' },
      },
    },
  });

  if (!purchaseOrder) {
    throw new HttpError(404, 'Purchase order not found');
  }

  if (purchaseOrder.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  if (purchaseOrder.status !== 'PENDING_APPROVAL') {
    throw new HttpError(400, 'Purchase order is not pending approval');
  }

  // Get current approval step
  const currentStep = purchaseOrder.approvalSteps.find(
    (step: any) => step.stepNumber === purchaseOrder.currentApprovalStep
  );

  if (!currentStep) {
    throw new HttpError(400, 'No pending approval step found');
  }

  // Check if user has permission to reject this step
  if (!canApproveAtStep(context.user.role, currentStep.stepNumber)) {
    throw new HttpError(403, `Only ${currentStep.requiredRole} can reject this step`);
  }

  // Update approval step
  await context.entities.ApprovalStep.update({
    where: { id: currentStep.id },
    data: {
      status: 'REJECTED',
      approvedById: context.user.id,
      approvedAt: new Date(),
      comment,
    },
  });

  // Record approval action
  await context.entities.ApprovalAction.create({
    data: {
      userId: context.user.id,
      purchaseOrderId,
      stepNumber: currentStep.stepNumber,
      action: 'REJECTED',
      comment,
    },
  });

  // Mark PO as rejected
  await context.entities.PurchaseOrder.update({
    where: { id: purchaseOrderId },
    data: {
      status: 'REJECTED',
      currentApprovalStep: null,
    },
  });

  // Create notification for PO creator
  await context.entities.Notification.create({
    data: {
      userId: purchaseOrder.createdById,
      type: 'PO_REJECTED',
      title: 'Purchase Order Rejected',
      message: `Purchase order #${purchaseOrder.poNumber} was rejected at step ${currentStep.stepNumber}`,
      purchaseOrderId,
      read: false,
    },
  });

  return { success: true };
};

// ============================================
// GET PENDING APPROVALS FOR USER
// ============================================

export const getPendingApprovals = async (args: any, context: any) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  // Find all POs pending approval at a step matching user's role
  const userRole = context.user.role;
  
  // Determine which step number this user can approve
  let approvalStepNumber = 0;
  if (userRole === 'PROPERTY_MANAGER' || userRole === 'ADMIN') {
    approvalStepNumber = 1;
  } else if (userRole === 'ACCOUNTING') {
    approvalStepNumber = 2;
  } else if (userRole === 'CORPORATE') {
    approvalStepNumber = 3;
  }

  if (approvalStepNumber === 0 && userRole !== 'ADMIN') {
    return []; // User role cannot approve anything
  }

  // Get POs pending approval
  const pendingPOs = await context.entities.PurchaseOrder.findMany({
    where: {
      organizationId: context.user.organizationId,
      status: 'PENDING_APPROVAL',
      ...(userRole !== 'ADMIN' && {
        currentApprovalStep: approvalStepNumber,
      }),
    },
    include: {
      createdBy: {
        select: {
          id: true,
          email: true,
          username: true,
        },
      },
      expenseType: true,
      approvalSteps: {
        where: {
          stepNumber: userRole === 'ADMIN' ? undefined : approvalStepNumber,
        },
        orderBy: { stepNumber: 'asc' },
      },
    },
    orderBy: { createdAt: 'desc' },
  });

  return pendingPOs;
};

// ============================================
// GET MY APPROVAL HISTORY
// ============================================

export const getMyApprovalHistory = async (args: any, context: any) => {
  checkAuth(context.user);

  const approvalActions = await context.entities.ApprovalAction.findMany({
    where: {
      userId: context.user.id,
    },
    include: {
      user: {
        select: {
          id: true,
          email: true,
          username: true,
        },
      },
    },
    orderBy: { createdAt: 'desc' },
    take: 50,
  });

  return approvalActions;
};
