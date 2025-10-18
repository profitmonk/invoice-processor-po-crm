import { HttpError } from "wasp/server";
import { checkAuth, checkOrganization } from '../../server/auth/permissions';

// ============================================
// CREATE MANUAL INVOICE (for PO matching)
// ============================================


type CreateManualInvoiceInput = {
  purchaseOrderId?: string;
  invoiceNumber: string;
  invoiceDate: string;
  dueDate: string;
  vendor: string;
  description: string;
  totalAmount: number;
  taxAmount: number;
  lineItems: {
    description: string;
    propertyId: string;
    glAccountId: string;
    quantity: number;
    unitPrice: number;
    taxAmount: number;
  }[];
  // File upload fields (optional)
  fileName?: string;
  fileSize?: number;
  fileUrl?: string;
  mimeType?: string;
};

export const createManualInvoice = async (
  args: CreateManualInvoiceInput,
  context: any
) => {
  checkAuth(context.user);

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
    fileName,
    fileSize,
    fileUrl,
    mimeType,
  } = args;

  // Validate required fields
  if (!invoiceNumber || !vendor || !invoiceDate || !dueDate) {
    throw new HttpError(400, 'Missing required fields');
  }

  if (!lineItems || lineItems.length === 0) {
    throw new HttpError(400, 'Invoice must have at least one line item');
  }

  // If linking to PO, validate it exists and is approved
  let purchaseOrder:any = null;
  if (purchaseOrderId) {
    purchaseOrder = await context.entities.PurchaseOrder.findUnique({
      where: { id: purchaseOrderId },
      include: { lineItems: true },
    });

    if (!purchaseOrder) {
      throw new HttpError(404, 'Purchase order not found');
    }

    if (purchaseOrder.status !== 'APPROVED') {
      throw new HttpError(400, 'Purchase order must be approved');
    }

    // Check if PO already has an invoice (check from PO side since it owns the FK)
    if (purchaseOrder.linkedInvoiceId) {
      throw new HttpError(400, 'Purchase order already has an invoice');
    }
  }

  // Create the invoice with structured data
  const invoice = await context.entities.Invoice.create({
    data: {
      userId: context.user.id,
      invoiceNumber,
      invoiceDate: new Date(invoiceDate),
      vendorName: vendor,
      totalAmount,
      currency: 'USD',
      status: 'UPLOADED',
      // File fields - use provided values or defaults for manual entry
      fileName: fileName || `MANUAL-${invoiceNumber}`,
      fileSize: fileSize || 0,
      fileUrl: fileUrl || '',
      mimeType: mimeType || 'application/manual',
      // Store additional data in structuredData JSON field
      structuredData: {
        description,
        dueDate,
        subtotal: totalAmount - taxAmount,
        taxAmount,
        paymentStatus: 'PENDING',
      },
    },
  });

  // Create line items
  for (let i = 0; i < lineItems.length; i++) {
    const item = lineItems[i];
    await context.entities.InvoiceLineItem.create({
      data: {
        invoiceId: invoice.id,
        description: item.description,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        amount: item.quantity * item.unitPrice,
        taxAmount: item.taxAmount,
        lineNumber: i + 1,
      },
    });
  }

  // If linked to PO, update PO status and create notification
  if (purchaseOrderId && purchaseOrder) {
    await context.entities.PurchaseOrder.update({
      where: { id: purchaseOrderId },
      data: {
        status: 'INVOICED',
        linkedInvoiceId: invoice.id,
      },
    });

    // Create notification for PO creator
    await context.entities.Notification.create({
      data: {
        userId: purchaseOrder.createdById,
        type: 'INVOICE_PO_MISMATCH', // We can add a new type later
        title: 'Invoice Created',
        message: `Invoice ${invoiceNumber} has been created and linked to PO ${purchaseOrder.poNumber}`,
        actionUrl: `/invoices/manual/${invoice.id}`,
        purchaseOrderId: purchaseOrder.id,
        invoiceId: invoice.id,
      },
    });
  }

  return invoice;
};

// ============================================
// UPDATE MANUAL INVOICE
// ============================================

type UpdateManualInvoiceInput = {
  id: string;
  invoiceNumber?: string;
  invoiceDate?: string;
  dueDate?: string;
  vendor?: string;
  description?: string;
  totalAmount?: number;
  taxAmount?: number;
  lineItems?: Array<{
    description: string;
    propertyId: string;
    glAccountId: string;
    quantity: number;
    unitPrice: number;
    taxAmount: number;
  }>;
};

export const updateManualInvoice = async (
  args: UpdateManualInvoiceInput,
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

  if (invoice.userId !== context.user.id) {
    throw new HttpError(403, 'Access denied');
  }

  // Don't allow editing of OCR invoices
  if (invoice.mimeType !== 'application/manual') {
    throw new HttpError(400, 'Can only edit manually created invoices');
  }

  // Check if invoice is paid
  const structuredData = invoice.structuredData as any;
  if (structuredData?.paymentStatus === 'PAID') {
    throw new HttpError(400, 'Cannot edit paid invoices');
  }

  // Build update data
  const updatedData: any = {};

  if (updateData.invoiceNumber) updatedData.invoiceNumber = updateData.invoiceNumber;
  if (updateData.invoiceDate) updatedData.invoiceDate = new Date(updateData.invoiceDate);
  if (updateData.vendor) updatedData.vendorName = updateData.vendor;
  if (updateData.totalAmount !== undefined) updatedData.totalAmount = updateData.totalAmount;

  // Update structured data
  if (updateData.dueDate || updateData.description || updateData.taxAmount !== undefined) {
    const currentStructuredData = (invoice.structuredData as any) || {};
    updatedData.structuredData = {
      ...currentStructuredData,
      ...(updateData.dueDate && { dueDate: updateData.dueDate }),
      ...(updateData.description && { description: updateData.description }),
      ...(updateData.taxAmount !== undefined && { taxAmount: updateData.taxAmount }),
    };
  }

  // Update line items if provided
  if (lineItems) {
    // Delete existing line items
    await context.entities.InvoiceLineItem.deleteMany({
      where: { invoiceId: id },
    });

    // Create new line items
    await Promise.all(
      lineItems.map((item, index) =>
        context.entities.InvoiceLineItem.create({
          data: {
            invoiceId: id,
            description: item.description,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            amount: item.quantity * item.unitPrice,
            category: null,
            lineNumber: index + 1,
          },
        })
      )
    );

    // Recalculate subtotal
    const subtotal = lineItems.reduce(
      (sum, item) => sum + item.quantity * item.unitPrice,
      0
    );
    updatedData.structuredData = {
      ...(updatedData.structuredData || invoice.structuredData),
      subtotal,
    };
  }

  // Update invoice
  const updatedInvoice = await context.entities.Invoice.update({
    where: { id },
    data: updatedData,
    include: {
      lineItems: true,
    },
  });

  return updatedInvoice;
};

// ============================================
// DELETE MANUAL INVOICE
// ============================================

type DeleteManualInvoiceInput = {
  id: string;
};

export const deleteManualInvoice = async (
  args: DeleteManualInvoiceInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const invoice = await context.entities.Invoice.findUnique({
    where: { id: args.id },
    include: {
      lineItems: true,
    },
  });

  if (!invoice) {
    throw new HttpError(404, 'Invoice not found');
  }

  if (invoice.userId !== context.user.id) {
    throw new HttpError(403, 'Access denied');
  }

  // Don't allow deleting OCR invoices through this operation
  if (invoice.mimeType !== 'application/manual') {
    throw new HttpError(400, 'Can only delete manually created invoices through this operation');
  }

  // Check if paid
  const structuredData = invoice.structuredData as any;
  if (structuredData?.paymentStatus === 'PAID') {
    throw new HttpError(400, 'Cannot delete paid invoices');
  }

  // If linked to PO, update PO status back to APPROVED
  if (invoice.linkedPurchaseOrder) {
    await context.entities.PurchaseOrder.update({
      where: { id: invoice.linkedPurchaseOrder},
      data: {
        status: 'APPROVED',
        linkedInvoiceId: null,
      },
    });
  }

  // Delete line items first
  await context.entities.InvoiceLineItem.deleteMany({
    where: { invoiceId: args.id },
  });

  // Delete invoice
  await context.entities.Invoice.delete({
    where: { id: args.id },
  });

  return { success: true };
};

// ============================================
// GET APPROVED POS WITHOUT INVOICES
// ============================================

// ============================================
// GET APPROVED POS WITHOUT INVOICES
// ============================================

export const getApprovedPOsWithoutInvoices = async (
  args: any,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  // Get approved POs without invoices
  const approvedPOs = await context.entities.PurchaseOrder.findMany({
    where: {
      organizationId: context.user.organizationId,
      status: 'APPROVED',
      linkedInvoiceId: null, // POs that don't have an invoice yet
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
      lineItems: {
        include: {
          property: true,
          glAccount: true,
        },
      },
    },
    orderBy: { createdAt: 'desc' },
  });

  return approvedPOs;
};

// ============================================
// GET MANUAL INVOICES
// ============================================

type GetManualInvoicesInput = {
  paymentStatus?: 'PAID' | 'PENDING';
};

export const getManualInvoices = async (
  args: GetManualInvoicesInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);
  
  const { paymentStatus } = args;

  // Build the where clause
  const whereClause: any = {
    userId: context.user.id,
    ocrProcessedAt: null, // Manual invoices only (not OCR processed)
  };

  // Add payment status filter if provided
  if (paymentStatus) {
    whereClause.structuredData = {
      path: ['paymentStatus'],
      equals: paymentStatus,
    };
  }

  const invoices = await context.entities.Invoice.findMany({
    where: whereClause,
    include: {
      lineItems: {
        orderBy: { lineNumber: 'asc' },
      },
    },
    orderBy: { createdAt: 'desc' },
  });

  return invoices;
};


// ============================================
// GET SINGLE INVOICE (Manual or OCR)
// ============================================

type GetInvoiceByIdInput2 = {
  id: string;
};

export const getInvoiceById2 = async (
  args: GetInvoiceByIdInput,
  context: any
) => {
  checkAuth(context.user);

  const invoice = await context.entities.Invoice.findUnique({
    where: { id: args.id },
    include: {
      lineItems: {
        orderBy: { lineNumber: 'asc' },
      },
      linkedPurchaseOrder: {  // Add this to fetch the PO
        select: {
          id: true,
          poNumber: true,
          vendor: true,
          totalAmount: true,
          status: true,
        },
      },
    },
  });

  if (!invoice) {
    throw new HttpError(404, 'Invoice not found');
  }

  if (invoice.userId !== context.user.id) {
    throw new HttpError(403, 'Access denied');
  }

  // If linked to PO, get PO details
  let purchaseOrder = null;
  if (invoice.purchaseOrderId) {
    purchaseOrder = await context.entities.PurchaseOrder.findUnique({
      where: { id: invoice.purchaseOrderId },
      select: {
        id: true,
        poNumber: true,
        vendor: true,
        totalAmount: true,
        status: true,
      },
    });
  }

  return {
    ...invoice,
    purchaseOrder,
  };
};

// ============================================
// GET ALL INVOICES (Org-Wide)
// ============================================

type GetInvoicesInput = {
  filter?: 'all' | 'ocr' | 'manual' | 'corrected';
  paymentStatus?: string;
};

export const getAllInvoices = async (
  args: GetInvoicesInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);
  
  console.log('=== getAllInvoices Debug ===');
  console.log('Current user email:', context.user.email);
  console.log('Current user orgId:', context.user.organizationId);
  console.log('Filter args:', args);
  const { filter, paymentStatus } = args;

  const whereClause: any = {
    user: {
      organizationId: context.user.organizationId, // Org-wide access
    },
  };

  // Filter by entry type
  if (filter && filter !== 'all') {
    if (filter === 'ocr') {
      whereClause.entryType = 'OCR';
    } else if (filter === 'manual') {
      whereClause.entryType = 'MANUAL';
    } else if (filter === 'corrected') {
      whereClause.entryType = 'OCR_CORRECTED';
    }
  }

  // Filter by payment status
  if (paymentStatus) {
    whereClause.structuredData = {
      path: ['paymentStatus'],
      equals: paymentStatus,
    };
  }
  console.log('Where clause:', JSON.stringify(whereClause, null, 2));
  const invoices = await context.entities.Invoice.findMany({
    where: whereClause,
    include: {
      user: true,
      lineItems: {
        orderBy: { lineNumber: 'asc' },
      },
      linkedPurchaseOrder: {
        select: {
          id: true,
          poNumber: true,
          vendor: true,
          totalAmount: true,
          status: true,
        },
      },
    },
    orderBy: { createdAt: 'desc' },
  });

  console.log('Found invoices count:', invoices.length);
  console.log('Invoice creators:', invoices.map((i: any) => ({
    invoiceNum: i.invoiceNumber,
    creator: i.user?.email,
    creatorOrgId: i.user?.organizationId
  })));

  return invoices;
};

// ============================================
// GET INVOICE BY ID (Org-Wide View)
// ============================================

type GetInvoiceByIdInput = {
  id: string;
};

export const getInvoiceById = async (
  args: GetInvoiceByIdInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);
  // ADD DEBUG LOGGING
  console.log('=== getInvoiceById Debug ===');
  console.log('Invoice ID requested:', args.id);
  console.log('Current user ID:', context.user.id);
  console.log('Current user orgId:', context.user.organizationId);

  const invoice = await context.entities.Invoice.findUnique({
    where: { id: args.id },
    include: {
      user: true,
      lineItems: {
        orderBy: { lineNumber: 'asc' },
      },
      linkedPurchaseOrder: {
        select: {
          id: true,
          poNumber: true,
          vendor: true,
          totalAmount: true,
          status: true,
          createdById: true,
        },
      },
    },
  });

  if (!invoice) {
    throw new HttpError(404, 'Invoice not found');
  }
  // MORE DEBUG LOGGING
  console.log('Invoice found:', invoice.id);
  console.log('Invoice user:', invoice.user);
  console.log('Invoice user orgId:', invoice.user?.organizationId);
  console.log('Comparison:', invoice.user?.organizationId, '!==', context.user.organizationId);

  // Check organization access
  if (invoice.user.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied - different organization');
  }

  return invoice;
};

// ============================================
// UPDATE INVOICE (Edit/Correct OCR)
// ============================================

type UpdateInvoiceInput = {
  id: string;
  invoiceNumber?: string;
  invoiceDate?: string;
  vendor?: string;
  description?: string;
  totalAmount?: number;
  taxAmount?: number;
  purchaseOrderId?: string;
  lineItems?: {
    description: string;
    propertyId: string;
    glAccountId: string;
    quantity: number;
    unitPrice: number;
    taxAmount: number;
  }[];
};

export const updateInvoice = async (
  args: UpdateInvoiceInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const {
    id,
    invoiceNumber,
    invoiceDate,
    vendor,
    description,
    totalAmount,
    taxAmount,
    purchaseOrderId,
    lineItems,
  } = args;

  // Get existing invoice
  const existingInvoice = await context.entities.Invoice.findUnique({
    where: { id },
    include: { 
      lineItems: true,
      user: true,
      linkedPurchaseOrder: true,
    },
  });

  if (!existingInvoice) {
    throw new HttpError(404, 'Invoice not found');
  }

  // Check organization access
  if (existingInvoice.user.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  // Check if user can edit (creator or admin)
  const canEdit = 
    existingInvoice.userId === context.user.id ||
    context.user.isAdmin ||
    context.user.role === 'ADMIN';

  if (!canEdit) {
    throw new HttpError(403, 'Only the invoice creator or admin can edit this invoice');
  }

  // Check if invoice is paid
  const structuredData = (existingInvoice.structuredData as any) || {};
  if (structuredData.paymentStatus === 'PAID') {
    throw new HttpError(400, 'Cannot edit a paid invoice');
  }

  // If linking to PO, validate it
  let purchaseOrder: any = null;
  if (purchaseOrderId) {
    purchaseOrder = await context.entities.PurchaseOrder.findUnique({
      where: { id: purchaseOrderId },
    });

    if (!purchaseOrder) {
      throw new HttpError(404, 'Purchase order not found');
    }

    if (purchaseOrder.organizationId !== context.user.organizationId) {
      throw new HttpError(403, 'Purchase order from different organization');
    }

    if (purchaseOrder.status !== 'APPROVED') {
      throw new HttpError(400, 'Purchase order must be approved');
    }

    if (purchaseOrder.linkedInvoiceId && purchaseOrder.linkedInvoiceId !== id) {
      throw new HttpError(400, 'Purchase order already linked to a different invoice');
    }
  }

  // Determine entry type
  let entryType = existingInvoice.entryType;
  if (existingInvoice.entryType === 'OCR') {
    entryType = 'OCR_CORRECTED';
  }

  // Calculate subtotal
  const subtotal = totalAmount && taxAmount ? totalAmount - taxAmount : undefined;

  // Update invoice
  const updatedInvoice = await context.entities.Invoice.update({
    where: { id },
    data: {
      ...(invoiceNumber && { invoiceNumber }),
      ...(invoiceDate && { invoiceDate: new Date(invoiceDate) }),
      ...(vendor && { vendorName: vendor }),
      ...(totalAmount !== undefined && { totalAmount }),
      entryType,
      structuredData: {
        ...structuredData,
        ...(description && { description }),
        ...(taxAmount !== undefined && { taxAmount }),
        ...(subtotal !== undefined && { subtotal }),
      },
    },
  });

  // Update line items if provided
  if (lineItems && lineItems.length > 0) {
    // Delete existing line items
    await context.entities.InvoiceLineItem.deleteMany({
      where: { invoiceId: id },
    });

    // Create new line items
    for (let i = 0; i < lineItems.length; i++) {
      const item = lineItems[i];
      await context.entities.InvoiceLineItem.create({
        data: {
          invoiceId: id,
          description: item.description,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          amount: item.quantity * item.unitPrice,
          taxAmount: item.taxAmount,
          lineNumber: i + 1,
        },
      });
    }
  }

  // Link to PO if provided
  if (purchaseOrderId && purchaseOrder) {
    // Unlink from old PO if exists
    if (existingInvoice.linkedPurchaseOrder && existingInvoice.linkedPurchaseOrder.id !== purchaseOrderId) {
      await context.entities.PurchaseOrder.update({
        where: { id: existingInvoice.linkedPurchaseOrder.id },
        data: {
          status: 'APPROVED',
          linkedInvoiceId: null,
        },
      });
    }

    // Link to new PO
    await context.entities.PurchaseOrder.update({
      where: { id: purchaseOrderId },
      data: {
        status: 'INVOICED',
        linkedInvoiceId: id,
      },
    });

    // Create notification
    await context.entities.Notification.create({
      data: {
        userId: purchaseOrder.createdById,
        type: 'INVOICE_PO_MISMATCH',
        title: 'Invoice Linked to PO',
        message: `Invoice ${invoiceNumber || existingInvoice.invoiceNumber} has been linked to PO ${purchaseOrder.poNumber}`,
        actionUrl: `/invoices/${id}`,
        purchaseOrderId: purchaseOrder.id,
        invoiceId: id,
      },
    });
  }

  return updatedInvoice;
};

// ============================================
// DELETE INVOICE (Creator or Admin Only)
// ============================================

export const deleteInvoice = async (
  args: { invoiceId: string },
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const invoice = await context.entities.Invoice.findUnique({
    where: { id: args.invoiceId },
    include: {
      linkedPurchaseOrder: true,
      user: true,
    },
  });

  if (!invoice) {
    throw new HttpError(404, 'Invoice not found');
  }

  // Check organization access
  if (invoice.user.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  // Check if user can delete (creator or admin)
  const canDelete = 
    invoice.userId === context.user.id ||
    context.user.isAdmin ||
    context.user.role === 'ADMIN';

  if (!canDelete) {
    throw new HttpError(403, 'Only the invoice creator or admin can delete this invoice');
  }

  // Check if paid
  const structuredData = (invoice.structuredData as any) || {};
  if (structuredData.paymentStatus === 'PAID') {
    throw new HttpError(400, 'Cannot delete a paid invoice');
  }

  // Unlink from PO if exists
  if (invoice.linkedPurchaseOrder) {
    await context.entities.PurchaseOrder.update({
      where: { id: invoice.linkedPurchaseOrder.id },
      data: {
        status: 'APPROVED',
        linkedInvoiceId: null,
      },
    });
  }

  // Delete line items
  await context.entities.InvoiceLineItem.deleteMany({
    where: { invoiceId: args.invoiceId },
  });

  // Delete invoice
  await context.entities.Invoice.delete({
    where: { id: args.invoiceId },
  });

  return { success: true };
};

// ============================================
// MARK AS PAID (Creator, Accounting, or Admin)
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

  const invoice = await context.entities.Invoice.findUnique({
    where: { id: args.id },
    include: {
      user: true,
    },
  });

  if (!invoice) {
    throw new HttpError(404, 'Invoice not found');
  }

  // Check organization access
  if (invoice.user.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  // Check if user can mark as paid
  const canMarkPaid = 
    invoice.userId === context.user.id ||
    context.user.role === 'ACCOUNTING' ||
    context.user.role === 'ADMIN' ||
    context.user.isAdmin;

  if (!canMarkPaid) {
    throw new HttpError(403, 'Only the invoice creator, accounting, or admin can mark invoice as paid');
  }

  // Update invoice
  const structuredData = (invoice.structuredData as any) || {};
  const updatedInvoice = await context.entities.Invoice.update({
    where: { id: args.id },
    data: {
      structuredData: {
        ...structuredData,
        paymentStatus: 'PAID',
        paidDate: args.paidDate,
        paymentMethod: args.paymentMethod,
        paymentReference: args.paymentReference,
      },
    },
  });

  return updatedInvoice;
};

// ============================================
// LINK INVOICE TO PO
// ============================================

type LinkInvoiceToPOInput = {
  invoiceId: string;
  purchaseOrderId: string;
};

export const linkInvoiceToPO = async (
  args: LinkInvoiceToPOInput,
  context: any
) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const { invoiceId, purchaseOrderId } = args;

  // Get invoice
  const invoice = await context.entities.Invoice.findUnique({
    where: { id: invoiceId },
    include: { 
      user: true,
      linkedPurchaseOrder: true,
    },
  });

  if (!invoice) {
    throw new HttpError(404, 'Invoice not found');
  }

  // Check organization access
  if (invoice.user.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  // Check if user can link (creator or admin)
  const canLink = 
    invoice.userId === context.user.id ||
    context.user.isAdmin ||
    context.user.role === 'ADMIN';

  if (!canLink) {
    throw new HttpError(403, 'Only the invoice creator or admin can link to PO');
  }

  // Check if already linked
  if (invoice.linkedPurchaseOrder) {
    throw new HttpError(400, 'Invoice is already linked to a PO. Unlink first.');
  }

  // Get PO
  const purchaseOrder = await context.entities.PurchaseOrder.findUnique({
    where: { id: purchaseOrderId },
  });

  if (!purchaseOrder) {
    throw new HttpError(404, 'Purchase order not found');
  }

  if (purchaseOrder.organizationId !== context.user.organizationId) {
    throw new HttpError(403, 'Purchase order from different organization');
  }

  if (purchaseOrder.status !== 'APPROVED') {
    throw new HttpError(400, 'Purchase order must be approved');
  }

  if (purchaseOrder.linkedInvoiceId) {
    throw new HttpError(400, 'Purchase order already linked to another invoice');
  }

  // Link them
  await context.entities.PurchaseOrder.update({
    where: { id: purchaseOrderId },
    data: {
      status: 'INVOICED',
      linkedInvoiceId: invoiceId,
    },
  });

  // Create notification
  await context.entities.Notification.create({
    data: {
      userId: purchaseOrder.createdById,
      type: 'INVOICE_PO_MISMATCH',
      title: 'Invoice Linked to PO',
      message: `Invoice ${invoice.invoiceNumber} has been linked to PO ${purchaseOrder.poNumber}`,
      actionUrl: `/invoices/${invoiceId}`,
      purchaseOrderId: purchaseOrder.id,
      invoiceId: invoiceId,
    },
  });

  return { success: true };
};
