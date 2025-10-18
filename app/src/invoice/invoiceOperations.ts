import { HttpError } from 'wasp/server';
import { checkAuth, checkOrganization } from '../server/auth/permissions';

// ============================================
// CREATE INVOICE
// ============================================

type CreateInvoiceInput = {
  purchaseOrderId?: string;
  invoiceNumber: string;
  invoiceDate: string;
  dueDate: string;
  vendor: string;
  description: string;
  totalAmount: number;
  taxAmount: number;
  lineItems: Array<{
    description: string;
    propertyId: string;
    glAccountId: string;
    quantity: number;
    unitPrice: number;
    taxAmount: number;
  }>;
};

export const createInvoice = async (
  args: CreateInvoiceInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const {
    purchaseOrderId,
    invoiceNumber,
    invoiceDate,
    dueDate,
    vendor,
    description,
    totalAmount,
    taxAmount,
    lineItems,
  } = args;

  // Check for duplicate invoice number within org
  const existingInvoice = await context.entities.Invoice.findFirst({
    where: {
      organizationId: context.user.organizationId,
      invoiceNumber,
    },
  });

  if (existingInvoice) {
    throw new HttpError(400, `Invoice number ${invoiceNumber} already exists`);
  }

  // If linked to PO, validate it
  let purchaseOrder: any = null;
  if (purchaseOrderId) {
    purchaseOrder = await context.entities.PurchaseOrder.findUnique({
      where: { id: purchaseOrderId },
      include: { lineItems: true },
    });

    if (!purchaseOrder) {
      throw new HttpError(404, 'Purchase order not found');
    }

    if (purchaseOrder.organizationId !== context.user.organizationId) {
      throw new HttpError(403, 'Access denied');
    }

    if (purchaseOrder.status !== 'APPROVED') {
      throw new HttpError(400, 'Can only create invoices for approved purchase orders');
    }

    if (purchaseOrder.linkedInvoiceId) {
      throw new HttpError(400, 'Purchase order already has an invoice');
    }
  }

  // Calculate subtotal from line items
  const subtotal = lineItems.reduce(
    (sum, item) => sum + item.quantity * item.unitPrice,
    0
  );

  // Create invoice
  const invoice = await context.entities.Invoice.create({
    data: {
      organizationId: context.user.organizationId,
      createdById: context.user.id,
      purchaseOrderId: purchaseOrderId || null,
      invoiceNumber,
      invoiceDate: new Date(invoiceDate),
      dueDate: new Date(dueDate),
      vendor,
      description,
      subtotal,
      taxAmount,
      totalAmount,
      status: 'PENDING',
      lineItems: {
        create: lineItems.map((item) => ({
          description: item.description,
          propertyId: item.propertyId,
          glAccountId: item.glAccountId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          taxAmount: item.taxAmount,
          amount: item.quantity * item.unitPrice,
        })),
      },
    },
    include: {
      lineItems: true,
      createdBy: {
        select: {
          id: true,
          email: true,
          username: true,
        },
      },
    },
  });

  // If linked to PO, update PO status
  if (purchaseOrderId && purchaseOrder) {
    await context.entities.PurchaseOrder.update({
      where: { id: purchaseOrderId },
      data: {
        status: 'INVOICED',
        linkedInvoiceId: invoice.id,
      },
    });

    // Create notification for PO creator
    if (purchaseOrder.createdById !== context.user.id) {
      await context.entities.Notification.create({
        data: {
          userId: purchaseOrder.createdById,
          type: 'INVOICE_CREATED',
          title: 'Invoice Created',
          message: `Invoice ${invoiceNumber} created for PO #${purchaseOrder.poNumber}`,
          invoiceId: invoice.id,
          read: false,
        },
      });
    }
  }

  return invoice;
};

// ============================================
// GET INVOICES
// ============================================

type GetInvoicesInput = {
  status?: string;
};

export const getInvoices = async (args: GetInvoicesInput, context: any) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const { status } = args;

  const invoices = await context.entities.Invoice.findMany({
    where: {
      organizationId: context.user.organizationId,
      ...(status && { status }),
    },
    include: {
      createdBy: {
        select: {
          id: true,
          email: true,
          username: true,
        },
      },
      purchaseOrder: {
        select: {
          id: true,
          poNumber: true,
        },
      },
      lineItems: {
        include: {
          property: true,
          glAccount: true,
        },
      },
    },
    orderBy: { createdAt: 'desc' },
  });

  return invoices;
};

// ============================================
// GET INVOICE BY ID
// ============================================

type GetInvoiceInput = {
  id: string;
};

export const getInvoice = async (args: GetInvoiceInput, context: any) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const invoice = await context.entities.Invoice.findUnique({
    where: { id: args.id },
    include: {
      createdBy: {
        select: {
          id: true,
          email: true,
          username: true,
        },
      },
      purchaseOrder: {
        select: {
          id: true,
          poNumber: true,
          vendor: true,
          totalAmount: true,
        },
      },
      lineItems: {
        include: {
          property: true,
          glAccount: true,
        },
        orderBy: { createdAt: 'asc' },
      },
    },
  });

  if (!invoice) {
    throw new HttpError(404, 'Invoice not found');
  }

  if (invoice.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  return invoice;
};

// ============================================
// UPDATE INVOICE
// ============================================

type UpdateInvoiceInput = {
  id: string;
  invoiceNumber?: string;
  invoiceDate?: string;
  dueDate?: string;
  vendor?: string;
  description?: string;
  lineItems?: Array<{
    description: string;
    propertyId: string;
    glAccountId: string;
    quantity: number;
    unitPrice: number;
    taxAmount: number;
  }>;
};

export const updateInvoice = async (
  args: UpdateInvoiceInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const { id, lineItems, ...updateData } = args;

  const invoice = await context.entities.Invoice.findUnique({
    where: { id },
  });

  if (!invoice) {
    throw new HttpError(404, 'Invoice not found');
  }

  if (invoice.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  if (invoice.status !== 'PENDING') {
    throw new HttpError(400, 'Can only edit pending invoices');
  }

  // Update invoice
  const updatedInvoice = await context.entities.Invoice.update({
    where: { id },
    data: {
      ...updateData,
      ...(args.invoiceDate && { invoiceDate: new Date(args.invoiceDate) }),
      ...(args.dueDate && { dueDate: new Date(args.dueDate) }),
      ...(lineItems && {
        lineItems: {
          deleteMany: {},
          create: lineItems.map((item) => ({
            description: item.description,
            propertyId: item.propertyId,
            glAccountId: item.glAccountId,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            taxAmount: item.taxAmount,
            amount: item.quantity * item.unitPrice,
          })),
        },
        subtotal: lineItems.reduce(
          (sum, item) => sum + item.quantity * item.unitPrice,
          0
        ),
        taxAmount: lineItems.reduce((sum, item) => sum + item.taxAmount, 0),
        totalAmount:
          lineItems.reduce(
            (sum, item) => sum + item.quantity * item.unitPrice + item.taxAmount,
            0
          ),
      }),
    },
    include: {
      lineItems: true,
    },
  });

  return updatedInvoice;
};

// ============================================
// MARK INVOICE AS PAID
// ============================================

type MarkInvoicePaidInput = {
  id: string;
  paidDate: string;
  paymentMethod?: string;
  paymentReference?: string;
};

export const markInvoicePaid = async (
  args: MarkInvoicePaidInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const { id, paidDate, paymentMethod, paymentReference } = args;

  const invoice = await context.entities.Invoice.findUnique({
    where: { id },
  });

  if (!invoice) {
    throw new HttpError(404, 'Invoice not found');
  }

  if (invoice.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  if (invoice.status === 'PAID') {
    throw new HttpError(400, 'Invoice is already marked as paid');
  }

  const updatedInvoice = await context.entities.Invoice.update({
    where: { id },
    data: {
      status: 'PAID',
      paidDate: new Date(paidDate),
      paymentMethod,
      paymentReference,
    },
  });

  // Create notification for invoice creator
  await context.entities.Notification.create({
    data: {
      userId: invoice.createdById,
      type: 'INVOICE_PAID',
      title: 'Invoice Paid',
      message: `Invoice ${invoice.invoiceNumber} has been marked as paid`,
      invoiceId: invoice.id,
      read: false,
    },
  });

  return updatedInvoice;
};

// ============================================
// DELETE INVOICE
// ============================================

type DeleteInvoiceInput = {
  id: string;
};

export const deleteInvoice = async (
  args: DeleteInvoiceInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const invoice = await context.entities.Invoice.findUnique({
    where: { id: args.id },
  });

  if (!invoice) {
    throw new HttpError(404, 'Invoice not found');
  }

  if (invoice.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  if (invoice.status !== 'PENDING') {
    throw new HttpError(400, 'Can only delete pending invoices');
  }

  // If linked to PO, unlink it
  if (invoice.purchaseOrderId) {
    await context.entities.PurchaseOrder.update({
      where: { id: invoice.purchaseOrderId },
      data: {
        status: 'APPROVED',
        linkedInvoiceId: null,
      },
    });
  }

  await context.entities.Invoice.delete({
    where: { id: args.id },
  });

  return { success: true };
};

// ============================================
// GET APPROVED POS WITHOUT INVOICES
// ============================================

export const getApprovedPOsWithoutInvoices = async (
  args: any,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const approvedPOs = await context.entities.PurchaseOrder.findMany({
    where: {
      organizationId: context.user.organizationId,
      status: 'APPROVED',
      linkedInvoiceId: null,
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
    },
    orderBy: { createdAt: 'desc' },
  });

  return approvedPOs;
};
