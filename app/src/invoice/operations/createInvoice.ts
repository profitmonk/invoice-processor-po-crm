import { type CreateInvoice } from 'wasp/server/operations';
import { HttpError } from 'wasp/server';

type CreateInvoiceInput = {
  fileName: string;
  fileSize: number;
  fileUrl: string;
  mimeType: string;
};

type CreateInvoiceOutput = {
  id: string;
  status: string;
  fileName: string;
};

export const createInvoice: CreateInvoice<CreateInvoiceInput, CreateInvoiceOutput> = async (
  { fileName, fileSize, fileUrl, mimeType },
  context
) => {
  // Check if user is authenticated
  if (!context.user) {
    throw new HttpError(401, 'You must be logged in to create invoices');
  }

  try {
    // Create invoice record in database
    const invoice = await context.entities.Invoice.create({
      data: {
        userId: context.user.id,
        fileName,
        fileSize,
        fileUrl,
        mimeType,
        status: 'UPLOADED',
      },
    });

    // Create processing job (we'll implement job execution later)
    await context.entities.ProcessingJob.create({
      data: {
        invoiceId: invoice.id,
        status: 'PENDING',
      },
    });

    console.log(`Invoice created: ${invoice.id} for user: ${context.user.id}`);

    return {
      id: invoice.id,
      status: invoice.status,
      fileName: invoice.fileName,
    };
  } catch (error: any) {
    console.error('Error creating invoice:', error);
    throw new HttpError(500, `Failed to create invoice: ${error.message}`);
  }
};
