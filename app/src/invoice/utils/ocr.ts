import FormData from 'form-data';
import fetch from 'node-fetch';
import { Readable } from 'stream';

// node-fetch v3 is ESM, so we need dynamic import
async function doFetch(url: string, options: any) {
  const fetch = (await import('node-fetch')).default;
  
  // Create timeout promise
  const timeoutPromise = new Promise((_, reject) => {
    setTimeout(() => reject(new Error('Request timeout')), 600000); // 10 min
  });
  
  // Race between fetch and timeout
  return Promise.race([
    fetch(url, options),
    timeoutPromise
  ]) as Promise<any>;
}

const HF_SPACE_URL = process.env.HUGGINGFACE_SPACE_URL || 'https://profitmonk-real-estate-invoice.hf.space';
const HF_TOKEN = process.env.HUGGINGFACE_API_KEY;

export interface OCRResult {
  text: string;
  confidence?: number;
  pageCount?: number;
}

/**
 * Process invoice with Hugging Face Space
 */
export async function processInvoiceOCR(
  fileBuffer: Buffer,
  fileName: string,
  mimeType: string
): Promise<OCRResult> {
  try {
    console.log(`Starting OCR for file: ${fileName} (${mimeType})`);
    
    if (!HF_TOKEN) {
      throw new Error('HUGGINGFACE_API_KEY not configured');
    }

    // Create form data
    const formData = new FormData();
    
    // Add file as stream
    const fileStream = Readable.from(fileBuffer);
    formData.append('file', fileStream, {
      filename: fileName,
      contentType: mimeType,
    });

    // Add parameters matching your Python script
    formData.append('prompt', 'Extract all text. Tables as HTML; other text as Markdown.');
    formData.append('dpi', '300');
    formData.append('max_new_tokens', '2048');
    formData.append('return_per_page', 'true');

    // Make request to HF Space
    const response = await doFetch(`${HF_SPACE_URL}/predict`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${HF_TOKEN}`,
        ...formData.getHeaders(),
      },
      body: formData,
    });

    console.log(`OCR Response Status: ${response.status}`);

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`HF Space returned ${response.status}: ${errorText}`);
    }

    // Parse response
    const contentType = response.headers.get('content-type') || '';
    let result: any;

    if (contentType.includes('application/json')) {
      result = await response.json();
    } else {
      result = { text: await response.text() };
    }

    console.log(`OCR completed for ${fileName}`);

    // Extract text from result
    let extractedText = '';
    
    if (typeof result === 'string') {
      extractedText = result;
    } else if (result.text) {
      extractedText = result.text;
    } else if (result.output) {
      extractedText = result.output;
    } else if (Array.isArray(result)) {
      // If result is array of pages
      extractedText = result.join('\n\n--- PAGE BREAK ---\n\n');
    } else {
      extractedText = JSON.stringify(result);
    }

    return {
      text: extractedText,
      confidence: result.confidence || undefined,
      pageCount: result.page_count || result.pageCount || undefined,
    };

  } catch (error: any) {
    console.error('OCR processing error:', error);
    throw new Error(`Failed to process OCR: ${error.message}`);
  }
}

/**
 * Download file from GCS
 */
export async function downloadFileFromGCS(fileUrl: string): Promise<Buffer> {
  const response = await doFetch(fileUrl, {});
  try {
    console.log(`Downloading file from: ${fileUrl}`);
    
    const response = await fetch(fileUrl);
    
    if (!response.ok) {
      throw new Error(`Failed to download file: ${response.status} ${response.statusText}`);
    }

    const arrayBuffer = await response.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    
    console.log(`Downloaded ${buffer.length} bytes`);
    
    return buffer;
  } catch (error: any) {
    console.error('Download error:', error);
    throw new Error(`Failed to download file: ${error.message}`);
  }
}
