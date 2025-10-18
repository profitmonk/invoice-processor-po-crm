import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  useQuery,
  getInvoiceById,
  getApprovedPOsWithoutInvoices,
  markInvoicePaid,
  deleteInvoice,
  linkInvoiceToPO,
} from 'wasp/client/operations';
import { useAuth } from 'wasp/client/auth';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Badge } from '../../components/ui/badge';
import { Input } from '../../components/ui/input';
import { Label } from '../../components/ui/label';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../../components/ui/table';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '../../components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '../../components/ui/select';
import { Alert, AlertDescription } from '../../components/ui/alert';
import {
  ArrowLeft,
  FileText,
  CheckCircle,
  Clock,
  Trash2,
  DollarSign,
  Calendar,
  Edit,
  Link as LinkIcon,
  User as UserIcon,
} from 'lucide-react';
import EditInvoiceForm from './EditInvoiceForm';

export default function InvoiceDetailPage() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const { data: user } = useAuth();

  if (!id) {
    navigate('/invoices');
    return null;
  }

  const { data: invoice, isLoading, refetch } = useQuery(getInvoiceById, { id });
  // Debug logging
  console.log('Invoice ID:', id);
  console.log('Is Loading:', isLoading);
  console.log('Invoice Data:', invoice);
  const { data: approvedPOs } = useQuery(getApprovedPOsWithoutInvoices);

  const [isEditing, setIsEditing] = useState(false);
  const [isPaymentDialogOpen, setIsPaymentDialogOpen] = useState(false);
  const [isLinkPODialogOpen, setIsLinkPODialogOpen] = useState(false);
  const [selectedPOId, setSelectedPOId] = useState('');
  const [paidDate, setPaidDate] = useState(new Date().toISOString().split('T')[0]);
  const [paymentMethod, setPaymentMethod] = useState('');
  const [paymentReference, setPaymentReference] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const handleMarkPaid = async () => {
    if (!paidDate) {
      setMessage({ type: 'error', text: 'Payment date is required' });
      return;
    }

    setIsSubmitting(true);
    setMessage(null);

    try {
      await markInvoicePaid({
        id,
        paidDate,
        paymentMethod: paymentMethod || undefined,
        paymentReference: paymentReference || undefined,
      });
      setMessage({ type: 'success', text: 'Invoice marked as paid' });
      setIsPaymentDialogOpen(false);
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to mark invoice as paid' });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleLinkToPO = async () => {
    if (!selectedPOId) {
      setMessage({ type: 'error', text: 'Please select a purchase order' });
      return;
    }

    setIsSubmitting(true);
    setMessage(null);

    try {
      await linkInvoiceToPO({
        invoiceId: id,
        purchaseOrderId: selectedPOId,
      });
      setMessage({ type: 'success', text: 'Invoice linked to PO successfully' });
      setIsLinkPODialogOpen(false);
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to link invoice to PO' });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this invoice? This cannot be undone.')) {
      return;
    }

    try {
      await deleteInvoice({ invoiceId: id });
      setMessage({ type: 'success', text: 'Invoice deleted' });
      setTimeout(() => {
        navigate('/invoices');
      }, 1500);
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to delete invoice' });
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  const formatDate = (date: string | Date) => {
    return new Date(date).toLocaleDateString();
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p>Loading invoice...</p>
      </div>
    );
  }

  if (!invoice) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Card className="w-96">
          <CardHeader>
            <CardTitle>Invoice Not Found</CardTitle>
          </CardHeader>
          <CardContent>
            <Button onClick={() => navigate('/invoices')}>
              Back to Invoices
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  // Permissions
  const isCreator = invoice.userId === user?.id;
  const isAdmin = user?.isAdmin || user?.role === 'ADMIN';
  const canEdit = isCreator || isAdmin;
  const canDelete = isCreator || isAdmin;
  const canMarkPaid = isCreator || isAdmin || user?.role === 'ACCOUNTING';

  const structuredData = (invoice.structuredData as any) || {};
  const isPaid = structuredData.paymentStatus === 'PAID';

  // If editing, show edit form
  if (isEditing) {
    return (
      <EditInvoiceForm
        invoice={invoice}
        onSave={() => {
          setIsEditing(false);
          refetch();
        }}
        onCancel={() => setIsEditing(false)}
      />
    );
  }

  return (
    <div className="py-10 lg:mt-10">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => navigate('/invoices')}>
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <div className="flex items-center gap-3">
                <h1 className="text-3xl font-bold tracking-tight">
                  Invoice #{invoice.invoiceNumber || 'N/A'}
                </h1>
                <Badge variant={isPaid ? 'default' : 'secondary'}>
                  {isPaid ? (
                    <>
                      <CheckCircle className="h-3 w-3 mr-1" />
                      Paid
                    </>
                  ) : (
                    <>
                      <Clock className="h-3 w-3 mr-1" />
                      Pending
                    </>
                  )}
                </Badge>
                <Badge variant={
                  invoice.entryType === 'OCR' ? 'default' :
                  invoice.entryType === 'MANUAL' ? 'secondary' :
                  'outline'
                }>
                  {invoice.entryType === 'OCR' ? '🤖 OCR' :
                   invoice.entryType === 'MANUAL' ? '✍️ Manual' :
                   '✏️ Corrected'}
                </Badge>
              </div>
              <p className="text-muted-foreground mt-2 flex items-center gap-2">
                <UserIcon className="h-4 w-4" />
                Created by {invoice.user?.username || invoice.user?.email} on {formatDate(invoice.createdAt)}
              </p>
            </div>
          </div>
          <div className="flex gap-2">
            {invoice.fileUrl && invoice.fileUrl !== '' && (
              <Button 
                variant="outline" 
                onClick={() => window.open(invoice.fileUrl, '_blank')}
              >
                <FileText className="h-4 w-4 mr-2" />
                View File
              </Button>
            )}
            {!isPaid && canEdit && (
              <Button variant="outline" onClick={() => setIsEditing(true)}>
                <Edit className="h-4 w-4 mr-2" />
                Edit
              </Button>
            )}
            {!isPaid && !invoice.linkedPurchaseOrder && canEdit && (
              <Button variant="outline" onClick={() => setIsLinkPODialogOpen(true)}>
                <LinkIcon className="h-4 w-4 mr-2" />
                Link to PO
              </Button>
            )}
            {!isPaid && canMarkPaid && (
              <Button variant="outline" onClick={() => setIsPaymentDialogOpen(true)}>
                <DollarSign className="h-4 w-4 mr-2" />
                Mark as Paid
              </Button>
            )}
            {!isPaid && canDelete && (
              <Button variant="destructive" onClick={handleDelete}>
                <Trash2 className="h-4 w-4 mr-2" />
                Delete
              </Button>
            )}
          </div>
        </div>

        {message && (
          <Alert variant={message.type === 'error' ? 'destructive' : 'default'} className="mb-6">
            <AlertDescription>{message.text}</AlertDescription>
          </Alert>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Invoice Details</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Vendor</p>
                    <p className="text-lg font-semibold">{invoice.vendorName || 'N/A'}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Invoice Number</p>
                    <p className="text-lg font-mono font-semibold">{invoice.invoiceNumber || 'N/A'}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Invoice Date</p>
                    <p className="text-lg">{invoice.invoiceDate ? formatDate(invoice.invoiceDate) : 'N/A'}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Due Date</p>
                    <p className="text-lg">{structuredData.dueDate ? formatDate(structuredData.dueDate) : 'N/A'}</p>
                  </div>
                </div>

                {structuredData.description && (
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Description</p>
                    <p className="text-base mt-1">{structuredData.description}</p>
                  </div>
                )}
              </CardContent>
            </Card>

            {invoice.lineItems && invoice.lineItems.length > 0 && (
              <Card>
                <CardHeader>
                  <CardTitle>Line Items</CardTitle>
                </CardHeader>
                <CardContent>
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>#</TableHead>
                        <TableHead>Description</TableHead>
                        <TableHead className="text-right">Qty</TableHead>
                        <TableHead className="text-right">Unit Price</TableHead>
                        <TableHead className="text-right">Amount</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {invoice.lineItems.map((item: any, index: number) => (
                        <TableRow key={item.id}>
                          <TableCell>{index + 1}</TableCell>
                          <TableCell>{item.description}</TableCell>
                          <TableCell className="text-right">{item.quantity || '-'}</TableCell>
                          <TableCell className="text-right">
                            {item.unitPrice ? formatCurrency(item.unitPrice) : '-'}
                          </TableCell>
                          <TableCell className="text-right font-semibold">
                            {formatCurrency(item.amount)}
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </CardContent>
              </Card>
            )}

            {isPaid && structuredData.paidDate && (
              <Card>
                <CardHeader>
                  <CardTitle>Payment Information</CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  <div className="flex items-center gap-2">
                    <Calendar className="h-4 w-4 text-muted-foreground" />
                    <div>
                      <p className="text-sm text-muted-foreground">Paid Date</p>
                      <p className="font-medium">{formatDate(structuredData.paidDate)}</p>
                    </div>
                  </div>
                  {structuredData.paymentMethod && (
                    <div>
                      <p className="text-sm text-muted-foreground">Payment Method</p>
                      <p className="font-medium">{structuredData.paymentMethod}</p>
                    </div>
                  )}
                  {structuredData.paymentReference && (
                    <div>
                      <p className="text-sm text-muted-foreground">Reference</p>
                      <p className="font-medium font-mono">{structuredData.paymentReference}</p>
                    </div>
                  )}
                </CardContent>
              </Card>
            )}
          </div>

          <div className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Summary</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Subtotal:</span>
                    <span className="font-medium">
                      {formatCurrency(structuredData.subtotal || 0)}
                    </span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Tax:</span>
                    <span className="font-medium">
                      {formatCurrency(structuredData.taxAmount || 0)}
                    </span>
                  </div>
                  <div className="border-t pt-2 flex justify-between">
                    <span className="font-semibold">Total:</span>
                    <span className="font-bold text-lg">
                      {formatCurrency(invoice.totalAmount || 0)}
                    </span>
                  </div>
                </div>
              </CardContent>
            </Card>

            {invoice.linkedPurchaseOrder && (
              <Card>
                <CardHeader>
                  <CardTitle>Linked Purchase Order</CardTitle>
                </CardHeader>
                <CardContent>
                  <Button
                    variant="outline"
                    className="w-full"
                    onClick={() => navigate(`/purchase-orders/${invoice.linkedPurchaseOrder.id}`)}
                  >
                    <FileText className="h-4 w-4 mr-2" />
                    View PO #{invoice.linkedPurchaseOrder.poNumber}
                  </Button>
                  <div className="mt-4 space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">PO Amount:</span>
                      <span className="font-medium">
                        {formatCurrency(invoice.linkedPurchaseOrder.totalAmount)}
                      </span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Status:</span>
                      <Badge variant="secondary">{invoice.linkedPurchaseOrder.status}</Badge>
                    </div>
                  </div>
                </CardContent>
              </Card>
            )}
          </div>
        </div>

        {/* Mark as Paid Dialog */}
        <Dialog open={isPaymentDialogOpen} onOpenChange={setIsPaymentDialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Mark Invoice as Paid</DialogTitle>
              <DialogDescription>
                Record payment details for invoice #{invoice.invoiceNumber}
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label htmlFor="paidDate">Payment Date *</Label>
                <Input
                  id="paidDate"
                  type="date"
                  value={paidDate}
                  onChange={(e) => setPaidDate(e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="paymentMethod">Payment Method</Label>
                <Select value={paymentMethod} onValueChange={setPaymentMethod}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select method (optional)" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="CHECK">Check</SelectItem>
                    <SelectItem value="ACH">ACH Transfer</SelectItem>
                    <SelectItem value="WIRE">Wire Transfer</SelectItem>
                    <SelectItem value="CREDIT_CARD">Credit Card</SelectItem>
                    <SelectItem value="CASH">Cash</SelectItem>
                    <SelectItem value="OTHER">Other</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="paymentReference">Reference Number</Label>
                <Input
                  id="paymentReference"
                  placeholder="Check #, Transaction ID, etc. (optional)"
                  value={paymentReference}
                  onChange={(e) => setPaymentReference(e.target.value)}
                />
              </div>
            </div>
            <DialogFooter>
              <Button
                variant="outline"
                onClick={() => {
                  setIsPaymentDialogOpen(false);
                  setPaidDate(new Date().toISOString().split('T')[0]);
                  setPaymentMethod('');
                  setPaymentReference('');
                }}
              >
                Cancel
              </Button>
              <Button onClick={handleMarkPaid} disabled={isSubmitting}>
                <CheckCircle className="h-4 w-4 mr-2" />
                {isSubmitting ? 'Processing...' : 'Mark as Paid'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Link to PO Dialog */}
        <Dialog open={isLinkPODialogOpen} onOpenChange={setIsLinkPODialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Link to Purchase Order</DialogTitle>
              <DialogDescription>
                Select an approved purchase order to link to this invoice
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label htmlFor="po">Purchase Order</Label>
                <Select value={selectedPOId} onValueChange={setSelectedPOId}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select PO" />
                  </SelectTrigger>
                  <SelectContent>
                    {approvedPOs && approvedPOs.length > 0 ? (
                      approvedPOs.map((po: any) => (
                        <SelectItem key={po.id} value={po.id}>
                          {po.poNumber} - {po.vendor} - {formatCurrency(po.totalAmount)}
                        </SelectItem>
                      ))
                    ) : (
                      <SelectItem value="none" disabled>
                        No approved POs available
                      </SelectItem>
                    )}
                  </SelectContent>
                </Select>
              </div>
            </div>
            <DialogFooter>
              <Button
                variant="outline"
                onClick={() => {
                  setIsLinkPODialogOpen(false);
                  setSelectedPOId('');
                }}
              >
                Cancel
              </Button>
              <Button onClick={handleLinkToPO} disabled={isSubmitting || !selectedPOId}>
                <LinkIcon className="h-4 w-4 mr-2" />
                {isSubmitting ? 'Linking...' : 'Link to PO'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
}
