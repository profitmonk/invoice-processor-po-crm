import { useQuery } from 'wasp/client/operations';
import { useState } from 'react';
import { InvoiceUpload } from '../components/InvoiceUpload';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { processPendingInvoice } from 'wasp/client/operations';

export default function InvoicesPage() {
  const [lastInvoiceId, setLastInvoiceId] = useState<string>('');
  const [isProcessing, setIsProcessing] = useState(false);
  const [message, setMessage] = useState<string>('');

  const handleUploadSuccess = () => {
    console.log('Invoice uploaded successfully!');
    setMessage('Upload successful! Enter invoice ID below to process.');
  };

  const handleProcess = async () => {
    if (!lastInvoiceId) {
      setMessage('Please enter an invoice ID');
      return;
    }

    setIsProcessing(true);
    setMessage('Processing...');

    try {
      const result = await processPendingInvoice({ invoiceId: lastInvoiceId });
      setMessage(`Success: ${result.message}`);
    } catch (error: any) {
      setMessage(`Error: ${error.message}`);
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div className="py-10 lg:mt-10">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="mx-auto max-w-4xl text-center">
          <h2 className="text-foreground mt-2 text-4xl font-bold tracking-tight sm:text-5xl">
            <span className="text-primary">Invoice</span> Processing
          </h2>
        </div>
        <p className="text-muted-foreground mx-auto mt-6 max-w-2xl text-center text-lg leading-8">
          Upload your invoices for AI-powered OCR and data extraction.
        </p>

        <div className="mx-auto mt-8 max-w-3xl">
          <InvoiceUpload onUploadSuccess={handleUploadSuccess} />
        </div>

        <Card className="mx-auto mt-8 max-w-3xl">
          <CardHeader>
            <CardTitle>Test OCR Processing</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-2">Invoice ID</label>
              <input
                type="text"
                value={lastInvoiceId}
                onChange={(e) => setLastInvoiceId(e.target.value)}
                placeholder="Paste invoice ID here"
                className="w-full px-3 py-2 border rounded-md"
              />
            </div>
            <Button 
              onClick={handleProcess} 
              disabled={isProcessing || !lastInvoiceId}
              className="w-full"
            >
              {isProcessing ? 'Processing...' : 'Process Invoice'}
            </Button>
            {message && (
              <p className="text-sm text-center">{message}</p>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
