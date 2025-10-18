import { checkAndDeductCredit } from '../utils/credits';
import { extractInvoiceData } from '../utils/llm';
import { HttpError } from 'wasp/server';
import { processInvoiceOCR, downloadFileFromGCS } from '../utils/ocr';

type ProcessPendingInvoiceInput = {
  invoiceId: string;
};

type ProcessPendingInvoiceOutput = {
  success: boolean;
  message: string;
};

export const processPendingInvoice = async (
  args: ProcessPendingInvoiceInput,
  context: any
): Promise<ProcessPendingInvoiceOutput> => {
  const { invoiceId } = args;

  if (!context.user) {
    throw new HttpError(401, 'Unauthorized');
  }

  try {
    console.log(`Starting processing for invoice: ${invoiceId}`);

    // Get invoice and job
    const invoice = await context.entities.Invoice.findUnique({
      where: { id: invoiceId },
      include: { processingJob: true },
    });

    if (!invoice) {
      throw new HttpError(404, 'Invoice not found');
    }

    // Verify ownership
    if (invoice.userId !== context.user.id) {
      throw new HttpError(403, 'Access denied');
    }

    // Check if already processed
    if (invoice.status === 'COMPLETED') {
      return { success: true, message: 'Invoice already processed' };
    }

    // Check and deduct credit
    const hasCredit = await checkAndDeductCredit(context.user.id, context.entities);
    
    if (!hasCredit) {
      await context.entities.Invoice.update({
        where: { id: invoiceId },
        data: { status: 'PAYMENT_REQUIRED' },
      });
      throw new HttpError(402, 'Insufficient credits. Please purchase more credits to continue.');
    }

    // Update status to PROCESSING_OCR
    await context.entities.Invoice.update({
      where: { id: invoiceId },
      data: { status: 'PROCESSING_OCR' },
    });

    if (invoice.processingJob) {
      await context.entities.ProcessingJob.update({
        where: { id: invoice.processingJob.id },
        data: {
          status: 'RUNNING',
          currentStep: 'ocr',
          startedAt: new Date(),
          attempts: invoice.processingJob.attempts + 1,
        },
      });
    }

    // Download file from GCS
    console.log(`Downloading file from: ${invoice.fileUrl}`);
    const fileBuffer = await downloadFileFromGCS(invoice.fileUrl);

    // Process with OCR
    console.log(`Processing OCR for: ${invoice.fileName}`);
    const ocrResult = await processInvoiceOCR(
      fileBuffer,
      invoice.fileName,
      invoice.mimeType
    );

    // Update invoice with OCR results
    ////await context.entities.Invoice.update({
    ////  where: { id: invoiceId },
    ////  data: {
    ////    ocrText: ocrResult.text,
    ////    ocrConfidence: ocrResult.confidence,
    ////    ocrProcessedAt: new Date(),
    ////    status: 'PROCESSING_LLM', // Will do LLM in Phase 5
    ////  },
    ////});

    ////console.log(`OCR completed for invoice: ${invoiceId}`);

    ////return {
    ////  success: true,
    ////  message: 'OCR processing completed successfully',
    ////};

    // Update invoice with OCR results
    await context.entities.Invoice.update({
      where: { id: invoiceId },
      data: {
        ocrText: ocrResult.text,
        ocrConfidence: ocrResult.confidence,
        ocrProcessedAt: new Date(),
        status: 'PROCESSING_LLM',
      },
    });

    console.log(`OCR completed, starting LLM extraction for: ${invoiceId}`);

    // Extract structured data with LLM
    const structuredData = await extractInvoiceData(ocrResult.text);

    // Save line items
    if (structuredData.lineItems && structuredData.lineItems.length > 0) {
      const validLineItems = structuredData.lineItems.filter(item => item.amount !== null);
      await Promise.all(
        validLineItems.map((item, index) =>
          context.entities.InvoiceLineItem.create({
            data: {
              invoiceId: invoiceId,
              description: item.description,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              amount: item.amount,
              category: item.category,
              lineNumber: index + 1,
            },
          })
        )
      );
    }

    // Update invoice with structured data
    await context.entities.Invoice.update({
      where: { id: invoiceId },
      data: {
        structuredData: structuredData as any,
        llmProcessedAt: new Date(),
        vendorName: structuredData.vendorName,
        invoiceNumber: structuredData.invoiceNumber,
        invoiceDate: structuredData.invoiceDate ? new Date(structuredData.invoiceDate) : null,
        totalAmount: structuredData.totalAmount,
        currency: structuredData.currency || 'USD',
        status: 'COMPLETED',
      },
    });

    // Mark job as completed
    if (invoice.processingJob) {
      await context.entities.ProcessingJob.update({
        where: { id: invoice.processingJob.id },
        data: {
          status: 'COMPLETED',
          completedAt: new Date(),
        },
      });
    }

    console.log(`Processing completed for invoice: ${invoiceId}`);

    return {
      success: true,
      message: 'Invoice processed successfully - OCR and LLM extraction complete',
    };

  } catch (error: any) {
    console.error(`Error processing invoice ${invoiceId}:`, error);

    // Update invoice with error
    await context.entities.Invoice.update({
      where: { id: invoiceId },
      data: {
        status: 'FAILED',
        errorMessage: error.message,
        failedAt: new Date(),
      },
    }).catch((err: any) => console.error('Failed to update invoice with error:', err));

    // Update job with error
    const invoice = await context.entities.Invoice.findUnique({
      where: { id: invoiceId },
      include: { processingJob: true },
    });

    if (invoice?.processingJob) {
      await context.entities.ProcessingJob.update({
        where: { id: invoice.processingJob.id },
        data: {
          status: 'FAILED',
          lastError: error.message,
          completedAt: new Date(),
        },
      }).catch((err: any) => console.error('Failed to update job with error:', err));
    }

    throw new HttpError(500, `Processing failed: ${error.message}`);
  }
};
