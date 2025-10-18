import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Badge } from '../../components/ui/badge';
import { FileText, Download, Trash2, Edit } from 'lucide-react';

interface InvoiceDetailProps {
  invoice: any;
  onClose: () => void;
  onDelete: (id: string) => void;
}

export function InvoiceDetail({ invoice, onClose, onDelete }: InvoiceDetailProps) {
  const formatDate = (date: string | null) => {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString();
  };

  const formatCurrency = (amount: number | null, currency: string = 'USD') => {
    if (amount === null) return 'N/A';
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: currency,
    }).format(amount);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <FileText className="h-6 w-6" />
          <div>
            <h2 className="text-2xl font-bold">{invoice.fileName}</h2>
            <p className="text-sm text-muted-foreground">
              Uploaded {formatDate(invoice.createdAt)}
            </p>
          </div>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" size="sm" onClick={onClose}>
            Close
          </Button>
          <Button
            variant="destructive"
            size="sm"
            onClick={() => onDelete(invoice.id)}
          >
            <Trash2 className="h-4 w-4 mr-2" />
            Delete
          </Button>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Invoice Information</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-sm font-medium text-muted-foreground">Vendor</p>
              <p className="text-lg">{invoice.vendorName || 'N/A'}</p>
            </div>
            <div>
              <p className="text-sm font-medium text-muted-foreground">Invoice Number</p>
              <p className="text-lg">{invoice.invoiceNumber || 'N/A'}</p>
            </div>
            <div>
              <p className="text-sm font-medium text-muted-foreground">Invoice Date</p>
              <p className="text-lg">{formatDate(invoice.invoiceDate)}</p>
            </div>
            <div>
              <p className="text-sm font-medium text-muted-foreground">Total Amount</p>
              <p className="text-lg font-bold">
                {formatCurrency(invoice.totalAmount, invoice.currency)}
              </p>
            </div>
          </div>

          <div>
            <p className="text-sm font-medium text-muted-foreground mb-2">Status</p>
            <Badge variant={invoice.status === 'COMPLETED' ? 'default' : 'secondary'}>
              {invoice.status}
            </Badge>
          </div>
        </CardContent>
      </Card>

      {invoice.lineItems && invoice.lineItems.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Line Items</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b">
                    <th className="text-left p-2 font-medium">#</th>
                    <th className="text-left p-2 font-medium">Description</th>
                    <th className="text-right p-2 font-medium">Qty</th>
                    <th className="text-right p-2 font-medium">Unit Price</th>
                    <th className="text-right p-2 font-medium">Amount</th>
                  </tr>
                </thead>
                <tbody>
                  {invoice.lineItems.map((item: any, index: number) => (
                    <tr key={item.id} className="border-b">
                      <td className="p-2">{index + 1}</td>
                      <td className="p-2">{item.description}</td>
                      <td className="p-2 text-right">{item.quantity || '-'}</td>
                      <td className="p-2 text-right">
                        {formatCurrency(item.unitPrice, invoice.currency)}
                      </td>
                      <td className="p-2 text-right font-medium">
                        {formatCurrency(item.amount, invoice.currency)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>
      )}

      {invoice.ocrText && (
        <Card>
          <CardHeader>
            <CardTitle>Raw OCR Text</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="bg-muted p-4 rounded-md max-h-96 overflow-y-auto">
              <pre className="text-sm whitespace-pre-wrap">{invoice.ocrText}</pre>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
