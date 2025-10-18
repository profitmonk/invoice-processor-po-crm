import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { InvoiceUpload } from '../components/InvoiceUpload';
import { CreditsDisplay } from '../components/CreditsDisplay';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { Badge } from '../../components/ui/badge';
import { 
  processPendingInvoice, 
  deleteInvoice, 
  getAllInvoices,
  buyCredits, 
  useQuery 
} from 'wasp/client/operations';
import { useAuth } from 'wasp/client/auth';
import { 
  FileText, 
  Clock, 
  CheckCircle, 
  XCircle, 
  Search,
  Plus,
  User as UserIcon,
} from 'lucide-react';

type FilterType = 'all' | 'ocr' | 'manual' | 'corrected';

export default function InvoicesPage() {
  const navigate = useNavigate();
  const [processingId, setProcessingId] = useState<string>('');
  const [searchTerm, setSearchTerm] = useState('');
  const [filter, setFilter] = useState<FilterType>('all');
  const [message, setMessage] = useState<string>('');

  const { data: user } = useAuth();
  const { data: invoices, isLoading, refetch } = useQuery(getAllInvoices, { filter });

  const handleUploadSuccess = () => {
    setMessage('Upload successful!');
    refetch();
  };

  const handleProcess = async (invoiceId: string) => {
    setProcessingId(invoiceId);
    setMessage('Processing...');

    try {
      await processPendingInvoice({ invoiceId });
      setMessage('Processing complete!');
      refetch();
    } catch (error: any) {
      setMessage(`Error: ${error.message}`);
    } finally {
      setProcessingId('');
    }
  };

  const handleProcessAll = async () => {
    if (!invoices || invoices.length === 0) return;
    
    const uploadedInvoices = invoices.filter(
      (inv: any) => inv.status === 'UPLOADED'
    );
    
    if (uploadedInvoices.length === 0) {
      setMessage('No invoices to process');
      return;
    }
    
    setMessage(`Processing ${uploadedInvoices.length} invoices...`);
    
    for (const invoice of uploadedInvoices) {
      try {
        setProcessingId(invoice.id);
        await processPendingInvoice({ invoiceId: invoice.id });
        setMessage(`Processed ${invoice.fileName}`);
        await new Promise(resolve => setTimeout(resolve, 1000));
      } catch (error: any) {
        console.error(`Failed to process ${invoice.fileName}:`, error);
        setMessage(`Error on ${invoice.fileName}: ${error.message}`);
      }
    }
    
    setProcessingId('');
    setMessage('Batch processing complete');
    refetch();
  };

  const handleBuyCredits = async () => {
    try {
      const priceId = 'price_1SE0MIFBSzh5QawRRrB6fj5g';
      const { checkoutUrl } = await buyCredits({ priceId });
      window.location.href = checkoutUrl;
    } catch (error: any) {
      setMessage(`Error: ${error.message}`);
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'COMPLETED':
        return <CheckCircle className="h-5 w-5 text-green-500" />;
      case 'FAILED':
        return <XCircle className="h-5 w-5 text-red-500" />;
      case 'PROCESSING_OCR':
      case 'PROCESSING_LLM':
        return <Clock className="h-5 w-5 text-blue-500" />;
      default:
        return <FileText className="h-5 w-5 text-gray-400" />;
    }
  };

  const getEntryTypeBadge = (entryType: string) => {
    switch (entryType) {
      case 'OCR':
        return <Badge variant="default">🤖 OCR</Badge>;
      case 'MANUAL':
        return <Badge variant="secondary">✍️ Manual</Badge>;
      case 'OCR_CORRECTED':
        return <Badge variant="outline">✏️ Corrected</Badge>;
      default:
        return null;
    }
  };

  const getPaymentBadge = (invoice: any) => {
    const structuredData = invoice.structuredData || {};
    if (structuredData.paymentStatus === 'PAID') {
      return <Badge className="bg-green-600">💰 Paid</Badge>;
    }
    return <Badge variant="outline">⏳ Pending</Badge>;
  };

  const filteredInvoices = invoices?.filter((inv: any) => {
    const searchLower = searchTerm.toLowerCase();
    return (
      inv.fileName?.toLowerCase().includes(searchLower) ||
      inv.vendorName?.toLowerCase().includes(searchLower) ||
      inv.invoiceNumber?.toLowerCase().includes(searchLower)
    );
  });

  return (
    <div className="py-10 lg:mt-10">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="mx-auto max-w-4xl text-center">
          <h2 className="text-foreground mt-2 text-4xl font-bold tracking-tight sm:text-5xl">
            <span className="text-primary">Invoice</span> Management
          </h2>
        </div>
        <p className="text-muted-foreground mx-auto mt-6 max-w-2xl text-center text-lg leading-8">
          Upload invoices for AI-powered OCR or create them manually
        </p>

        <div className="mx-auto mt-8 max-w-3xl space-y-6">
          {user && (
            <CreditsDisplay 
              credits={user.credits || 0} 
              onBuyCredits={handleBuyCredits}
            />
          )}
          
          <InvoiceUpload onUploadSuccess={handleUploadSuccess} />
          
          <div className="flex justify-center">
            <Button
              onClick={() => navigate('/invoices/new')}
              variant="outline"
              size="lg"
            >
              <Plus className="h-5 w-5 mr-2" />
              Create Manual Invoice
            </Button>
          </div>
        </div>

        {message && (
          <p className="text-center mt-4 text-sm font-medium">{message}</p>
        )}

        <Card className="mx-auto mt-8 max-w-6xl">
          <CardHeader>
            <div className="flex flex-col gap-4">
              <div className="flex items-center justify-between">
                <CardTitle>All Invoices</CardTitle>
                <div className="flex gap-3 items-center">
                  {invoices && invoices.filter((i: any) => i.status === 'UPLOADED').length > 0 && (
                    <Button 
                      onClick={handleProcessAll}
                      disabled={!!processingId}
                      size="sm"
                    >
                      Process All
                    </Button>
                  )}
                  <div className="relative w-64">
                    <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      placeholder="Search invoices..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-8"
                    />
                  </div>
                </div>
              </div>

              {/* Filter Tabs */}
              <div className="flex gap-2">
                <Button 
                  variant={filter === 'all' ? 'default' : 'outline'}
                  onClick={() => setFilter('all')}
                  size="sm"
                >
                  All
                </Button>
                <Button 
                  variant={filter === 'ocr' ? 'default' : 'outline'}
                  onClick={() => setFilter('ocr')}
                  size="sm"
                >
                  🤖 OCR
                </Button>
                <Button 
                  variant={filter === 'manual' ? 'default' : 'outline'}
                  onClick={() => setFilter('manual')}
                  size="sm"
                >
                  ✍️ Manual
                </Button>
                <Button 
                  variant={filter === 'corrected' ? 'default' : 'outline'}
                  onClick={() => setFilter('corrected')}
                  size="sm"
                >
                  ✏️ Corrected
                </Button>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <p className="text-muted-foreground text-center py-8">Loading...</p>
            ) : filteredInvoices && filteredInvoices.length > 0 ? (
              <div className="space-y-3">
                {filteredInvoices.map((invoice: any) => (
                  <Card
                    key={invoice.id}
                    className="p-4 cursor-pointer hover:bg-muted/50 transition-colors"
                    onClick={() => navigate(`/invoices/${invoice.id}`)}
                  >
                    <div className="flex items-start justify-between gap-4">
                      <div className="flex items-start gap-3 flex-1">
                        {getStatusIcon(invoice.status)}
                        <div className="flex-1 space-y-1">
                          <div className="flex items-center gap-2">
                            <p className="font-medium">{invoice.fileName}</p>
                            {getEntryTypeBadge(invoice.entryType)}
                            {getPaymentBadge(invoice)}
                          </div>
                          
                          {invoice.vendorName && (
                            <p className="text-sm text-muted-foreground">
                              Vendor: {invoice.vendorName}
                            </p>
                          )}
                          
                          {invoice.invoiceNumber && (
                            <p className="text-sm text-muted-foreground">
                              Invoice #: {invoice.invoiceNumber}
                            </p>
                          )}

                          {invoice.linkedPurchaseOrder && (
                            <p className="text-sm text-blue-600">
                              🔗 Linked to PO #{invoice.linkedPurchaseOrder.poNumber}
                            </p>
                          )}

                          <div className="flex items-center gap-4 text-xs text-muted-foreground">
                            <span className="flex items-center gap-1">
                              <UserIcon className="h-3 w-3" />
                              {invoice.user?.username || invoice.user?.email}
                            </span>
                            <span>
                              {invoice.status} • {invoice.totalAmount ? `$${invoice.totalAmount.toFixed(2)}` : 'Processing...'}
                            </span>
                          </div>
                        </div>
                      </div>
                      {invoice.status === 'UPLOADED' && (
                        <Button
                          size="sm"
                          onClick={(e) => {
                            e.stopPropagation();
                            handleProcess(invoice.id);
                          }}
                          disabled={processingId === invoice.id}
                        >
                          {processingId === invoice.id ? 'Processing...' : 'Process'}
                        </Button>
                      )}
                    </div>
                  </Card>
                ))}
              </div>
            ) : (
              <p className="text-muted-foreground text-center py-8">
                {searchTerm ? 'No invoices found' : 'No invoices yet'}
              </p>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
