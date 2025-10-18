import { HttpError } from 'wasp/server';
import { deleteFile } from '../utils/storage';

type DeleteInvoiceInput = {
  invoiceId: string;
};

export const deleteInvoice = async (
  args: DeleteInvoiceInput,
  context: any
): Promise<{ success: boolean }> => {
  const { invoiceId } = args;

  if (!context.user) {
    throw new HttpError(401, 'Unauthorized');
  }

  // Get invoice
  const invoice = await context.entities.Invoice.findUnique({
    where: { id: invoiceId },
  });

  if (!invoice) {
    throw new HttpError(404, 'Invoice not found');
  }

  // Verify ownership
  if (invoice.userId !== context.user.id) {
    throw new HttpError(403, 'Access denied');
  }

  try {
    // Delete from GCS (extract filename from URL)
    const fileName = invoice.fileUrl.split('/').pop();
    if (fileName) {
      await deleteFile(`invoices/${fileName}`).catch(err =>
        console.error('Failed to delete file from GCS:', err)
      );
    }

    // Delete from database (cascades to line items and processing job)
    await context.entities.Invoice.delete({
      where: { id: invoiceId },
    });

    return { success: true };
  } catch (error: any) {
    console.error('Error deleting invoice:', error);
    throw new HttpError(500, `Failed to delete invoice: ${error.message}`);
  }
};
