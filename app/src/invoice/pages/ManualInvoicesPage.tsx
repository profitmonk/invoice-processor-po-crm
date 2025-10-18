import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  useQuery,
  getAllInvoices,
  deleteManualInvoice,
  markInvoicePaid,
} from 'wasp/client/operations';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Badge } from '../../components/ui/badge';
import { Input } from '../../components/ui/input';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../../components/ui/table';
import { 
  FileText, 
  Plus, 
  Search,
  CheckCircle,
  Clock,
  User as UserIcon,
} from 'lucide-react';

export default function ManualInvoicesPage() {
  const navigate = useNavigate();
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState<string | undefined>(undefined);

  const { data: invoices, isLoading, refetch } = useQuery(getAllInvoices, { 
    filter: 'manual',
    paymentStatus: filterStatus,
  });

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  const formatDate = (date: string | Date) => {
    return new Date(date).toLocaleDateString();
  };

  const getPaymentBadge = (invoice: any) => {
    const structuredData = invoice.structuredData || {};
    if (structuredData.paymentStatus === 'PAID') {
      return (
        <Badge className="bg-green-600">
          <CheckCircle className="h-3 w-3 mr-1" />
          Paid
        </Badge>
      );
    }
    return (
      <Badge variant="outline">
        <Clock className="h-3 w-3 mr-1" />
        Pending
      </Badge>
    );
  };

  const filteredInvoices = invoices?.filter((inv: any) => {
    const searchLower = searchTerm.toLowerCase();
    return (
      inv.vendorName?.toLowerCase().includes(searchLower) ||
      inv.invoiceNumber?.toLowerCase().includes(searchLower)
    );
  });

  return (
    <div className="py-10 lg:mt-10">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Manual Invoices</h1>
            <p className="text-muted-foreground mt-2">
              Manage manually created invoices
            </p>
          </div>
          <Button onClick={() => navigate('/invoices/new')}>
            <Plus className="h-4 w-4 mr-2" />
            Create Invoice
          </Button>
        </div>

        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>All Manual Invoices</CardTitle>
              <div className="flex gap-3 items-center">
                <div className="flex gap-2">
                  <Button
                    variant={!filterStatus ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setFilterStatus(undefined)}
                  >
                    All
                  </Button>
                  <Button
                    variant={filterStatus === 'PENDING' ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setFilterStatus('PENDING')}
                  >
                    Pending
                  </Button>
                  <Button
                    variant={filterStatus === 'PAID' ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setFilterStatus('PAID')}
                  >
                    Paid
                  </Button>
                </div>
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
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <p className="text-center py-8 text-muted-foreground">Loading...</p>
            ) : filteredInvoices && filteredInvoices.length > 0 ? (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Invoice #</TableHead>
                    <TableHead>Vendor</TableHead>
                    <TableHead>Date</TableHead>
                    <TableHead>Amount</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Created By</TableHead>
                    <TableHead>PO Link</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredInvoices.map((invoice: any) => (
                    <TableRow 
                      key={invoice.id}
                      className="cursor-pointer hover:bg-muted/50"
                      onClick={() => navigate(`/invoices/${invoice.id}`)}
                    >
                      <TableCell className="font-mono font-medium">
                        {invoice.invoiceNumber}
                      </TableCell>
                      <TableCell>{invoice.vendorName}</TableCell>
                      <TableCell>
                        {invoice.invoiceDate ? formatDate(invoice.invoiceDate) : 'N/A'}
                      </TableCell>
                      <TableCell className="font-semibold">
                        {formatCurrency(invoice.totalAmount || 0)}
                      </TableCell>
                      <TableCell>{getPaymentBadge(invoice)}</TableCell>
                      <TableCell>
                        <div className="flex items-center gap-1 text-sm text-muted-foreground">
                          <UserIcon className="h-3 w-3" />
                          {invoice.user?.username || invoice.user?.email}
                        </div>
                      </TableCell>
                      <TableCell>
                        {invoice.linkedPurchaseOrder ? (
                          <Badge variant="secondary" className="text-xs">
                            PO #{invoice.linkedPurchaseOrder.poNumber}
                          </Badge>
                        ) : (
                          <span className="text-xs text-muted-foreground">No PO</span>
                        )}
                      </TableCell>
                      <TableCell className="text-right">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={(e) => {
                            e.stopPropagation();
                            navigate(`/invoices/${invoice.id}`);
                          }}
                        >
                          <FileText className="h-4 w-4" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            ) : (
              <p className="text-center py-8 text-muted-foreground">
                {searchTerm ? 'No invoices found' : 'No manual invoices yet'}
              </p>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
