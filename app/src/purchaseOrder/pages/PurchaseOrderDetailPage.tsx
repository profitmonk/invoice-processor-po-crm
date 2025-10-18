import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  useQuery,
  getPurchaseOrder,
  submitPurchaseOrderForApproval,
  cancelPurchaseOrder,
  deletePurchaseOrder,
} from 'wasp/client/operations';
import { useAuth } from 'wasp/client/auth';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../components/ui/card';
import { Badge } from '../../components/ui/badge';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../../components/ui/table';
import { Alert, AlertDescription } from '../../components/ui/alert';
import {
  ArrowLeft,
  Send,
  XCircle,
  Trash2,
  Edit,
  FileText,
  Calendar,
  DollarSign,
  Building2,
  User,
  CheckCircle,
  Clock,
  AlertCircle,
} from 'lucide-react';
import { Separator } from '../../components/ui/separator';

const STATUS_COLORS: Record<string, any> = {
  DRAFT: 'secondary',
  PENDING_APPROVAL: 'default',
  APPROVED: 'default',
  REJECTED: 'destructive',
  CANCELLED: 'secondary',
  INVOICED: 'default',
};

const STATUS_ICONS: Record<string, any> = {
  DRAFT: FileText,
  PENDING_APPROVAL: Clock,
  APPROVED: CheckCircle,
  REJECTED: XCircle,
  CANCELLED: XCircle,
  INVOICED: CheckCircle,
};

export default function PurchaseOrderDetailPage() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const { data: user } = useAuth();

  // IMPORTANT: This check must come BEFORE useQuery
  if (!id) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Card className="w-96">
          <CardHeader>
            <CardTitle>Invalid Purchase Order</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground">
              No purchase order ID provided.
            </p>
            <Button className="mt-4" onClick={() => navigate('/purchase-orders')}>
              Back to Purchase Orders
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }
  const { data: purchaseOrder, isLoading, refetch } = useQuery(getPurchaseOrder, { id });
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmitForApproval = async () => {
    setIsSubmitting(true);
    setMessage(null);

    try {
      await submitPurchaseOrderForApproval({ id });
      setMessage({ type: 'success', text: 'Purchase order submitted for approval' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to submit for approval' });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleCancel = async () => {
    if (!confirm('Are you sure you want to cancel this purchase order?')) {
      return;
    }

    try {
      await cancelPurchaseOrder({ id });
      setMessage({ type: 'success', text: 'Purchase order cancelled' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to cancel purchase order' });
    }
  };

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this purchase order? This cannot be undone.')) {
      return;
    }

    try {
      await deletePurchaseOrder({ id });
      setMessage({ type: 'success', text: 'Purchase order deleted' });
      setTimeout(() => {
        navigate('/purchase-orders');
      }, 1500);
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to delete purchase order' });
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p>Loading purchase order...</p>
      </div>
    );
  }

  if (!purchaseOrder) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Card className="w-96">
          <CardHeader>
            <CardTitle>Purchase Order Not Found</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground">
              The purchase order you're looking for doesn't exist.
            </p>
            <Button className="mt-4" onClick={() => navigate('/purchase-orders')}>
              Back to Purchase Orders
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  const StatusIcon = STATUS_ICONS[purchaseOrder.status];
  const canEdit = user?.id === purchaseOrder.createdById && purchaseOrder.status === 'DRAFT';
  const canSubmit = user?.id === purchaseOrder.createdById && 
                    purchaseOrder.status === 'DRAFT' && 
                    purchaseOrder.requiresApproval;
  const canCancelOrDelete = user?.id === purchaseOrder.createdById || user?.isAdmin;

  return (
    <div className="py-10 lg:mt-10">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => navigate('/purchase-orders')}>
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <div className="flex items-center gap-3">
                <h1 className="text-3xl font-bold tracking-tight">
                  PO #{purchaseOrder.poNumber}
                </h1>
                <Badge variant={STATUS_COLORS[purchaseOrder.status]} className="flex items-center gap-1">
                  <StatusIcon className="h-3 w-3" />
                  {purchaseOrder.status.replace('_', ' ')}
                </Badge>
              </div>
              <p className="text-muted-foreground mt-2">
                Created {formatDate(purchaseOrder.createdAt)} by {purchaseOrder.createdBy.email}
              </p>
            </div>
          </div>
          <div className="flex gap-2">
            {canEdit && (
              <Button variant="outline" onClick={() => navigate(`/purchase-orders/${id}/edit`)}>
                <Edit className="h-4 w-4 mr-2" />
                Edit
              </Button>
            )}
            {canSubmit && (
              <Button onClick={handleSubmitForApproval} disabled={isSubmitting}>
                <Send className="h-4 w-4 mr-2" />
                Submit for Approval
              </Button>
            )}
            {canCancelOrDelete && purchaseOrder.status === 'DRAFT' && (
              <Button variant="destructive" onClick={handleDelete}>
                <Trash2 className="h-4 w-4 mr-2" />
                Delete
              </Button>
            )}
            {canCancelOrDelete && (purchaseOrder.status === 'PENDING_APPROVAL' || purchaseOrder.status === 'APPROVED') && (
              <Button variant="outline" onClick={handleCancel}>
                <XCircle className="h-4 w-4 mr-2" />
                Cancel
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
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Basic Information */}
            <Card>
              <CardHeader>
                <CardTitle>Purchase Order Details</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Vendor</p>
                    <p className="text-lg font-semibold">{purchaseOrder.vendor}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Expense Type</p>
                    <Badge variant="secondary">
                      {purchaseOrder.expenseType.name} ({purchaseOrder.expenseType.code})
                    </Badge>
                  </div>
                </div>
                <Separator />
                <div>
                  <p className="text-sm font-medium text-muted-foreground mb-2">Description</p>
                  <p className="text-base">{purchaseOrder.description}</p>
                </div>
                <Separator />
                <div className="flex items-center gap-2 text-sm text-muted-foreground">
                  <Calendar className="h-4 w-4" />
                  <span>PO Date: {formatDate(purchaseOrder.poDate)}</span>
                </div>
              </CardContent>
            </Card>

            {/* Line Items */}
            <Card>
              <CardHeader>
                <CardTitle>Line Items ({purchaseOrder.lineItems.length})</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="overflow-x-auto">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead className="w-[50px]">#</TableHead>
                        <TableHead>Description</TableHead>
                        <TableHead>Property</TableHead>
                        <TableHead>GL Account</TableHead>
                        <TableHead className="text-right">Qty</TableHead>
                        <TableHead className="text-right">Unit Price</TableHead>
                        <TableHead className="text-right">Tax</TableHead>
                        <TableHead className="text-right">Total</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {purchaseOrder.lineItems.map((item: any) => (
                        <TableRow key={item.id}>
                          <TableCell>{item.lineNumber}</TableCell>
                          <TableCell>{item.description}</TableCell>
                          <TableCell>
                            <div className="flex items-center gap-2">
                              <Building2 className="h-4 w-4 text-muted-foreground" />
                              <span className="font-mono text-sm">{item.property.code}</span>
                            </div>
                          </TableCell>
                          <TableCell>
                            <div className="text-sm">
                              <div className="font-mono">{item.glAccount.accountNumber}</div>
                              <div className="text-muted-foreground">{item.glAccount.name}</div>
                            </div>
                          </TableCell>
                          <TableCell className="text-right">{item.quantity}</TableCell>
                          <TableCell className="text-right">{formatCurrency(item.unitPrice)}</TableCell>
                          <TableCell className="text-right">{formatCurrency(item.taxAmount)}</TableCell>
                          <TableCell className="text-right font-semibold">
                            {formatCurrency(item.totalAmount)}
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>

                <Separator className="my-4" />

                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Subtotal:</span>
                    <span className="font-medium">{formatCurrency(purchaseOrder.subtotal)}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Tax:</span>
                    <span className="font-medium">{formatCurrency(purchaseOrder.taxAmount)}</span>
                  </div>
                  <div className="border-t pt-2 flex justify-between">
                    <span className="font-semibold">Total:</span>
                    <span className="font-bold text-lg">{formatCurrency(purchaseOrder.totalAmount)}</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Approval Steps */}
            {purchaseOrder.approvalSteps && purchaseOrder.approvalSteps.length > 0 && (
              <Card>
                <CardHeader>
                  <CardTitle>Approval Process</CardTitle>
                  <CardDescription>
                    {purchaseOrder.requiresApproval
                      ? 'This PO requires approval'
                      : 'This PO does not require approval'}
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {purchaseOrder.approvalSteps.map((step: any) => (
                      <div key={step.id} className="flex items-start gap-4">
                        <div className="flex-shrink-0">
                          {step.status === 'APPROVED' ? (
                            <div className="h-8 w-8 rounded-full bg-green-100 flex items-center justify-center">
                              <CheckCircle className="h-5 w-5 text-green-600" />
                            </div>
                          ) : step.status === 'REJECTED' ? (
                            <div className="h-8 w-8 rounded-full bg-red-100 flex items-center justify-center">
                              <XCircle className="h-5 w-5 text-red-600" />
                            </div>
                          ) : step.status === 'PENDING' && step.stepNumber === purchaseOrder.currentApprovalStep ? (
                            <div className="h-8 w-8 rounded-full bg-blue-100 flex items-center justify-center">
                              <Clock className="h-5 w-5 text-blue-600" />
                            </div>
                          ) : (
                            <div className="h-8 w-8 rounded-full bg-gray-100 flex items-center justify-center">
                              <Clock className="h-5 w-5 text-gray-400" />
                            </div>
                          )}
                        </div>
                        <div className="flex-1">
                          <div className="flex items-center gap-2">
                            <p className="font-semibold">Step {step.stepNumber}: {step.stepName}</p>
                            <Badge variant={
                              step.status === 'APPROVED' ? 'default' :
                              step.status === 'REJECTED' ? 'destructive' :
                              'secondary'
                            }>
                              {step.status}
                            </Badge>
                          </div>
                          {step.approvedBy && (
                            <div className="mt-1 text-sm text-muted-foreground">
                              <div className="flex items-center gap-2">
                                <User className="h-3 w-3" />
                                {step.approvedBy.email}
                              </div>
                              {step.approvedAt && (
                                <div className="flex items-center gap-2 mt-1">
                                  <Calendar className="h-3 w-3" />
                                  {formatDate(step.approvedAt)}
                                </div>
                              )}
                            </div>
                          )}
                          {step.comment && (
                            <div className="mt-2 p-2 bg-muted rounded text-sm">
                              {step.comment}
                            </div>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            )}
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Quick Info</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <div className="flex items-center gap-2 text-sm text-muted-foreground mb-1">
                    <DollarSign className="h-4 w-4" />
                    <span>Total Amount</span>
                  </div>
                  <p className="text-2xl font-bold">{formatCurrency(purchaseOrder.totalAmount)}</p>
                </div>
                <Separator />
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Requires Approval</p>
                  <Badge variant={purchaseOrder.requiresApproval ? 'default' : 'secondary'}>
                    {purchaseOrder.requiresApproval ? 'Yes' : 'No'}
                  </Badge>
                </div>
                {purchaseOrder.requiresApproval && purchaseOrder.currentApprovalStep && (
                  <>
                    <Separator />
                    <div>
                      <p className="text-sm text-muted-foreground mb-1">Current Step</p>
                      <p className="font-semibold">Step {purchaseOrder.currentApprovalStep} of 3</p>
                    </div>
                  </>
                )}
                <Separator />
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Created By</p>
                  <div className="flex items-center gap-2">
                    <User className="h-4 w-4" />
                    <span className="text-sm">{purchaseOrder.createdBy.email}</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            {purchaseOrder.linkedInvoice && (
              <Card>
                <CardHeader>
                  <CardTitle>Linked Invoice</CardTitle>
                </CardHeader>
                <CardContent>
                  <Button
                    variant="outline"
                    className="w-full"
                    onClick={() => navigate(`/invoices/manual/${purchaseOrder.linkedInvoice.id}`)}
                  >
                    <FileText className="h-4 w-4 mr-2" />
                    View Invoice
                  </Button>
                </CardContent>
              </Card>
            )}

            {purchaseOrder.isTemplate && (
              <Card>
                <CardHeader>
                  <CardTitle>Template</CardTitle>
                </CardHeader>
                <CardContent>
                  <Alert>
                    <AlertCircle className="h-4 w-4" />
                    <AlertDescription>
                      This is saved as a template: <strong>{purchaseOrder.templateName}</strong>
                    </AlertDescription>
                  </Alert>
                </CardContent>
              </Card>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
