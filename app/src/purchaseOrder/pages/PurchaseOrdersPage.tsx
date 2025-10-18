import { useState } from 'react';
import { useQuery, getPurchaseOrders, deletePurchaseOrder, cancelPurchaseOrder } from 'wasp/client/operations';
import { useNavigate } from 'react-router-dom';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Input } from '../../components/ui/input';
import { Badge } from '../../components/ui/badge';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '../../components/ui/select';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../../components/ui/table';
import { Plus, Search, FileText, Trash2, XCircle, Eye } from 'lucide-react';
import { Alert, AlertDescription } from '../../components/ui/alert';

const STATUS_COLORS: Record<string, any> = {
  DRAFT: 'secondary',
  PENDING_APPROVAL: 'default',
  APPROVED: 'default',
  REJECTED: 'destructive',
  CANCELLED: 'secondary',
  INVOICED: 'default',
};

const STATUS_LABELS: Record<string, string> = {
  DRAFT: 'Draft',
  PENDING_APPROVAL: 'Pending Approval',
  APPROVED: 'Approved',
  REJECTED: 'Rejected',
  CANCELLED: 'Cancelled',
  INVOICED: 'Invoiced',
};

export default function PurchaseOrdersPage() {
  const navigate = useNavigate();
  const [statusFilter, setStatusFilter] = useState<string>('ALL');
  const [searchTerm, setSearchTerm] = useState('');
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const { data: purchaseOrders, isLoading, refetch } = useQuery(getPurchaseOrders, {
    status: statusFilter === 'ALL' ? undefined : statusFilter,
    isTemplate: false,
  });

  const handleDelete = async (id: string, poNumber: string) => {
    if (!confirm(`Are you sure you want to delete PO ${poNumber}?`)) {
      return;
    }

    try {
      await deletePurchaseOrder({ id });
      setMessage({ type: 'success', text: 'Purchase order deleted successfully' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to delete purchase order' });
    }
  };

  const handleCancel = async (id: string, poNumber: string) => {
    if (!confirm(`Are you sure you want to cancel PO ${poNumber}?`)) {
      return;
    }

    try {
      await cancelPurchaseOrder({ id });
      setMessage({ type: 'success', text: 'Purchase order cancelled successfully' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to cancel purchase order' });
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

  const filteredPOs = purchaseOrders?.filter((po: any) => {
    const matchesSearch =
      po.poNumber.toLowerCase().includes(searchTerm.toLowerCase()) ||
      po.vendor.toLowerCase().includes(searchTerm.toLowerCase()) ||
      po.description.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesSearch;
  });

  return (
    <div className="py-10 lg:mt-10">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Purchase Orders</h1>
            <p className="text-muted-foreground mt-2">
              Create and manage purchase orders for your organization
            </p>
          </div>
          <Button onClick={() => navigate('/purchase-orders/new')}>
            <Plus className="h-4 w-4 mr-2" />
            Create PO
          </Button>
        </div>

        {message && (
          <Alert variant={message.type === 'error' ? 'destructive' : 'default'} className="mb-6">
            <AlertDescription>{message.text}</AlertDescription>
          </Alert>
        )}

        <Card>
          <CardHeader>
            <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between">
              <CardTitle>All Purchase Orders</CardTitle>
              <div className="flex gap-3 w-full sm:w-auto">
                <div className="relative flex-1 sm:flex-none sm:w-64">
                  <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                  <Input
                    placeholder="Search POs..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-8"
                  />
                </div>
                <Select value={statusFilter} onValueChange={setStatusFilter}>
                  <SelectTrigger className="w-40">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="ALL">All Status</SelectItem>
                    <SelectItem value="DRAFT">Draft</SelectItem>
                    <SelectItem value="PENDING_APPROVAL">Pending</SelectItem>
                    <SelectItem value="APPROVED">Approved</SelectItem>
                    <SelectItem value="REJECTED">Rejected</SelectItem>
                    <SelectItem value="CANCELLED">Cancelled</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <p className="text-center py-8 text-muted-foreground">Loading purchase orders...</p>
            ) : filteredPOs && filteredPOs.length > 0 ? (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>PO #</TableHead>
                    <TableHead>Date</TableHead>
                    <TableHead>Vendor</TableHead>
                    <TableHead>Description</TableHead>
                    <TableHead>Amount</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredPOs.map((po: any) => (
                    <TableRow key={po.id} className="cursor-pointer hover:bg-muted/50">
                      <TableCell
                        className="font-mono font-bold"
                        onClick={() => navigate(`/purchase-orders/${po.id}`)}
                      >
                        {po.poNumber}
                      </TableCell>
                      <TableCell onClick={() => navigate(`/purchase-orders/${po.id}`)}>
                        {formatDate(po.poDate)}
                      </TableCell>
                      <TableCell onClick={() => navigate(`/purchase-orders/${po.id}`)}>
                        {po.vendor}
                      </TableCell>
                      <TableCell onClick={() => navigate(`/purchase-orders/${po.id}`)}>
                        <div className="max-w-xs truncate">{po.description}</div>
                      </TableCell>
                      <TableCell onClick={() => navigate(`/purchase-orders/${po.id}`)}>
                        <div className="font-semibold">{formatCurrency(po.totalAmount)}</div>
                      </TableCell>
                      <TableCell onClick={() => navigate(`/purchase-orders/${po.id}`)}>
                        <Badge variant={STATUS_COLORS[po.status]}>
                          {STATUS_LABELS[po.status]}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-2">
                          <Button
                            size="sm"
                            variant="ghost"
                            onClick={() => navigate(`/purchase-orders/${po.id}`)}
                          >
                            <Eye className="h-4 w-4" />
                          </Button>
                          {po.status === 'DRAFT' && (
                            <Button
                              size="sm"
                              variant="ghost"
                              onClick={(e) => {
                                e.stopPropagation();
                                handleDelete(po.id, po.poNumber);
                              }}
                            >
                              <Trash2 className="h-4 w-4 text-destructive" />
                            </Button>
                          )}
                          {(po.status === 'PENDING_APPROVAL' || po.status === 'APPROVED') && (
                            <Button
                              size="sm"
                              variant="ghost"
                              onClick={(e) => {
                                e.stopPropagation();
                                handleCancel(po.id, po.poNumber);
                              }}
                            >
                              <XCircle className="h-4 w-4 text-destructive" />
                            </Button>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            ) : (
              <div className="text-center py-12">
                <FileText className="mx-auto h-12 w-12 text-muted-foreground" />
                <h3 className="mt-4 text-lg font-semibold">No purchase orders found</h3>
                <p className="text-muted-foreground mt-2">
                  {searchTerm || statusFilter !== 'ALL'
                    ? 'Try adjusting your filters'
                    : 'Get started by creating your first purchase order'}
                </p>
                {!searchTerm && statusFilter === 'ALL' && (
                  <Button className="mt-4" onClick={() => navigate('/purchase-orders/new')}>
                    <Plus className="h-4 w-4 mr-2" />
                    Create Purchase Order
                  </Button>
                )}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
