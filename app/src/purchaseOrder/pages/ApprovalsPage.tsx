import { useState } from 'react';
import { useQuery, getPendingApprovals, approvePurchaseOrder, rejectPurchaseOrder } from 'wasp/client/operations';
import { useNavigate } from 'react-router-dom';
import { useAuth } from 'wasp/client/auth';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../components/ui/card';
import { Badge } from '../../components/ui/badge';
import { Textarea } from '../../components/ui/textarea';
import { Label } from '../../components/ui/label';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '../../components/ui/dialog';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../../components/ui/table';
import { Alert, AlertDescription } from '../../components/ui/alert';
import { CheckCircle, XCircle, Eye, Clock, User as UserIcon } from 'lucide-react';

export default function ApprovalsPage() {
  const navigate = useNavigate();
  const { data: user } = useAuth();
  const { data: pendingPOs, isLoading, refetch } = useQuery(getPendingApprovals);
  
  const [selectedPO, setSelectedPO] = useState<any>(null);
  const [isApproveDialogOpen, setIsApproveDialogOpen] = useState(false);
  const [isRejectDialogOpen, setIsRejectDialogOpen] = useState(false);
  const [comment, setComment] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const handleApprove = async () => {
    if (!selectedPO) return;

    setIsSubmitting(true);
    setMessage(null);

    try {
      await approvePurchaseOrder({
        purchaseOrderId: selectedPO.id,
        comment: comment || undefined,
      });
      setMessage({ type: 'success', text: 'Purchase order approved successfully' });
      setIsApproveDialogOpen(false);
      setComment('');
      setSelectedPO(null);
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to approve purchase order' });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleReject = async () => {
    if (!selectedPO) return;

    if (!comment.trim()) {
      setMessage({ type: 'error', text: 'Please provide a reason for rejection' });
      return;
    }

    setIsSubmitting(true);
    setMessage(null);

    try {
      await rejectPurchaseOrder({
        purchaseOrderId: selectedPO.id,
        comment,
      });
      setMessage({ type: 'success', text: 'Purchase order rejected' });
      setIsRejectDialogOpen(false);
      setComment('');
      setSelectedPO(null);
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to reject purchase order' });
    } finally {
      setIsSubmitting(false);
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString();
  };

  const getRoleStepName = (role: string) => {
    switch (role) {
      case 'PROPERTY_MANAGER':
        return 'Property Manager';
      case 'ACCOUNTING':
        return 'Accounting';
      case 'CORPORATE':
        return 'Corporate';
      case 'ADMIN':
        return 'Admin';
      default:
        return role;
    }
  };

  return (
    <div className="py-10 lg:mt-10">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold tracking-tight">Pending Approvals</h1>
          <p className="text-muted-foreground mt-2">
            Review and approve purchase orders awaiting your approval
          </p>
        </div>

        {message && (
          <Alert variant={message.type === 'error' ? 'destructive' : 'default'} className="mb-6">
            <AlertDescription>{message.text}</AlertDescription>
          </Alert>
        )}

        {user && (
          <Card className="mb-6">
            <CardContent className="pt-6">
              <div className="flex items-center gap-4">
                <div className="p-3 rounded-full bg-primary/10">
                  <UserIcon className="h-6 w-6 text-primary" />
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Your Role</p>
                  <p className="text-lg font-semibold">{getRoleStepName(user.role)}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        <Card>
          <CardHeader>
            <CardTitle>
              Purchase Orders Awaiting Approval ({pendingPOs?.length || 0})
            </CardTitle>
            <CardDescription>
              {user?.role === 'ADMIN' 
                ? 'As admin, you can approve any pending step'
                : `These purchase orders require your approval as ${getRoleStepName(user?.role || '')}`}
            </CardDescription>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <p className="text-center py-8 text-muted-foreground">Loading approvals...</p>
            ) : pendingPOs && pendingPOs.length > 0 ? (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>PO #</TableHead>
                    <TableHead>Created</TableHead>
                    <TableHead>Vendor</TableHead>
                    <TableHead>Amount</TableHead>
                    <TableHead>Step</TableHead>
                    <TableHead>Created By</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {pendingPOs.map((po: any) => (
                    <TableRow 
                      key={po.id}
                      className="cursor-pointer hover:bg-muted/50"
                      onClick={() => navigate(`/purchase-orders/${po.id}`)}
                    >
                      <TableCell className="font-mono font-bold">
                        {po.poNumber}
                      </TableCell>
                      <TableCell>{formatDate(po.createdAt)}</TableCell>
                      <TableCell>{po.vendor}</TableCell>
                      <TableCell className="font-semibold">
                        {formatCurrency(po.totalAmount)}
                      </TableCell>
                      <TableCell>
                        <Badge variant="secondary">
                          <Clock className="h-3 w-3 mr-1" />
                          Step {po.currentApprovalStep}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        {po.createdBy.email}
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-2">
                          <Button
                            size="sm"
                            variant="ghost"
                            onClick={(e) => {
                              e.stopPropagation(); // Prevent row click
                              navigate(`/purchase-orders/${po.id}`);
                            }}
                          >
                            <Eye className="h-4 w-4" />
                          </Button>
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={(e) => {
                              e.stopPropagation(); // Prevent row click
                              setSelectedPO(po);
                              setIsRejectDialogOpen(true);
                            }}
                          >
                            <XCircle className="h-4 w-4 mr-1" />
                            Reject
                          </Button>
                          <Button
                            size="sm"
                            onClick={(e) => {
                              e.stopPropagation(); // Prevent row click
                              setSelectedPO(po);
                              setIsApproveDialogOpen(true);
                            }}
                          >
                            <CheckCircle className="h-4 w-4 mr-1" />
                            Approve
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            ) : (
              <div className="text-center py-12">
                <CheckCircle className="mx-auto h-12 w-12 text-muted-foreground" />
                <h3 className="mt-4 text-lg font-semibold">No Pending Approvals</h3>
                <p className="text-muted-foreground mt-2">
                  All purchase orders requiring your approval have been processed
                </p>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Approve Dialog */}
        <Dialog open={isApproveDialogOpen} onOpenChange={setIsApproveDialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Approve Purchase Order</DialogTitle>
              <DialogDescription>
                Approve PO #{selectedPO?.poNumber} for {formatCurrency(selectedPO?.totalAmount || 0)}
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label htmlFor="approve-comment">Comment (Optional)</Label>
                <Textarea
                  id="approve-comment"
                  placeholder="Add any notes about this approval..."
                  value={comment}
                  onChange={(e) => setComment(e.target.value)}
                  rows={3}
                />
              </div>
            </div>
            <DialogFooter>
              <Button
                variant="outline"
                onClick={() => {
                  setIsApproveDialogOpen(false);
                  setComment('');
                  setSelectedPO(null);
                }}
              >
                Cancel
              </Button>
              <Button onClick={handleApprove} disabled={isSubmitting}>
                <CheckCircle className="h-4 w-4 mr-2" />
                {isSubmitting ? 'Approving...' : 'Approve'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Reject Dialog */}
        <Dialog open={isRejectDialogOpen} onOpenChange={setIsRejectDialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Reject Purchase Order</DialogTitle>
              <DialogDescription>
                Reject PO #{selectedPO?.poNumber} - Please provide a reason
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label htmlFor="reject-comment">Reason for Rejection *</Label>
                <Textarea
                  id="reject-comment"
                  placeholder="Please explain why this PO is being rejected..."
                  value={comment}
                  onChange={(e) => setComment(e.target.value)}
                  rows={4}
                />
              </div>
            </div>
            <DialogFooter>
              <Button
                variant="outline"
                onClick={() => {
                  setIsRejectDialogOpen(false);
                  setComment('');
                  setSelectedPO(null);
                }}
              >
                Cancel
              </Button>
              <Button 
                variant="destructive" 
                onClick={handleReject} 
                disabled={isSubmitting || !comment.trim()}
              >
                <XCircle className="h-4 w-4 mr-2" />
                {isSubmitting ? 'Rejecting...' : 'Reject'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
}
