import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

export interface InvoiceData {
  vendorName: string | null;
  invoiceNumber: string | null;
  invoiceDate: string | null;
  dueDate: string | null;
  totalAmount: number | null;
  subtotal: number | null;
  taxAmount: number | null;
  currency: string;
  lineItems: LineItem[];
}

export interface LineItem {
  description: string;
  quantity: number | null;
  unitPrice: number | null;
  amount: number;
  category: string | null;
}

export async function extractInvoiceData(ocrText: string): Promise<InvoiceData> {
  try {
    console.log('Calling OpenAI to structure invoice data...');

    const prompt = `You are an expert at extracting structured data from invoice OCR text.
The OCR text may contain errors, misspellings, or be incomplete due to image quality issues.
Use your best judgment to infer missing or unclear information.

IMPORTANT: 
- If you cannot determine an amount for a line item, set amount to null
- If vendor name is unclear, make your best guess based on context
- If dates are malformed, try to parse them reasonably

Extract the following information from this invoice text:
- Vendor/Company name
- Invoice number
- Invoice date
- Due date (if present)
- Line items (description, quantity, unit price, total amount)
- Subtotal
- Tax amount
- Total amount
- Currency

OCR Text:
${ocrText}

Return ONLY a valid JSON object with this structure:
{
  "vendorName": "string or null",
  "invoiceNumber": "string or null",
  "invoiceDate": "YYYY-MM-DD or null",
  "dueDate": "YYYY-MM-DD or null",
  "totalAmount": number or null,
  "subtotal": number or null,
  "taxAmount": number or null,
  "currency": "USD",
  "lineItems": [
    {
      "description": "string",
      "quantity": number or null,
      "unitPrice": number or null,
      "amount": number,
      "category": "string or null"
    }
  ]
}`;

    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: 'You are a precise data extraction assistant. Always return valid JSON.',
        },
        {
          role: 'user',
          content: prompt,
        },
      ],
      temperature: 0,
      response_format: { type: 'json_object' },
    });

    const content = response.choices[0]?.message?.content;
    if (!content) {
      throw new Error('No response from OpenAI');
    }

    const data = JSON.parse(content);
    console.log('Successfully extracted invoice data');

    return data;
  } catch (error: any) {
    console.error('LLM extraction error:', error);
    throw new Error(`Failed to extract data: ${error.message}`);
  }
}
