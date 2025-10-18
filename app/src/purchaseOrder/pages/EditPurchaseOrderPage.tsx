import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  useQuery,
  getPurchaseOrder,
  updatePurchaseOrder,
  getProperties,
  getGLAccounts,
  getExpenseTypes,
} from 'wasp/client/operations';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../components/ui/card';
import { Input } from '../../components/ui/input';
import { Label } from '../../components/ui/label';
import { Textarea } from '../../components/ui/textarea';
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
import { Alert, AlertDescription } from '../../components/ui/alert';
import { Plus, Trash2, Save, ArrowLeft } from 'lucide-react';

interface LineItem {
  id: string;
  description: string;
  propertyId: string;
  glAccountId: string;
  quantity: number;
  unitPrice: number;
  taxAmount: number;
}

export default function EditPurchaseOrderPage() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  
  if (!id) {
    navigate('/purchase-orders');
    return null;
  }

  const { data: purchaseOrder, isLoading: isLoadingPO } = useQuery(getPurchaseOrder, { id });
  const { data: properties } = useQuery(getProperties);
  const { data: glAccounts } = useQuery(getGLAccounts);
  const { data: expenseTypes } = useQuery(getExpenseTypes);

  const [vendor, setVendor] = useState('');
  const [description, setDescription] = useState('');
  const [expenseTypeId, setExpenseTypeId] = useState('');
  const [lineItems, setLineItems] = useState<LineItem[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    if (purchaseOrder) {
      setVendor(purchaseOrder.vendor);
      setDescription(purchaseOrder.description);
      setExpenseTypeId(purchaseOrder.expenseTypeId);
      setLineItems(
        purchaseOrder.lineItems.map((item: any) => ({
          id: item.id,
          description: item.description,
          propertyId: item.propertyId,
          glAccountId: item.glAccountId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          taxAmount: item.taxAmount,
        }))
      );
    }
  }, [purchaseOrder]);

  const addLineItem = () => {
    setLineItems([
      ...lineItems,
      {
        id: crypto.randomUUID(),
        description: '',
        propertyId: '',
        glAccountId: '',
        quantity: 1,
        unitPrice: 0,
        taxAmount: 0,
      },
    ]);
  };

  const removeLineItem = (itemId: string) => {
    if (lineItems.length === 1) {
      setMessage({ type: 'error', text: 'Purchase order must have at least one line item' });
      return;
    }
    setLineItems(lineItems.filter((item) => item.id !== itemId));
  };

  const updateLineItem = (itemId: string, field: keyof LineItem, value: any) => {
    setLineItems(
      lineItems.map((item) =>
        item.id === itemId ? { ...item, [field]: value } : item
      )
    );
  };

  const calculateLineTotal = (item: LineItem) => {
    return item.quantity * item.unitPrice + item.taxAmount;
  };

  const calculateSubtotal = () => {
    return lineItems.reduce((sum, item) => sum + item.quantity * item.unitPrice, 0);
  };

  const calculateTotalTax = () => {
    return lineItems.reduce((sum, item) => sum + item.taxAmount, 0);
  };

  const calculateTotal = () => {
    return calculateSubtotal() + calculateTotalTax();
  };

  const validateForm = () => {
    if (!vendor.trim()) {
      setMessage({ type: 'error', text: 'Vendor name is required' });
      return false;
    }

    if (!description.trim()) {
      setMessage({ type: 'error', text: 'Description is required' });
      return false;
    }

    if (!expenseTypeId) {
      setMessage({ type: 'error', text: 'Expense type is required' });
      return false;
    }

    for (const item of lineItems) {
      if (!item.description.trim()) {
        setMessage({ type: 'error', text: 'All line items must have a description' });
        return false;
      }
      if (!item.propertyId) {
        setMessage({ type: 'error', text: 'All line items must have a property' });
        return false;
      }
      if (!item.glAccountId) {
        setMessage({ type: 'error', text: 'All line items must have a GL account' });
        return false;
      }
      if (item.quantity <= 0) {
        setMessage({ type: 'error', text: 'Quantity must be greater than 0' });
        return false;
      }
      if (item.unitPrice < 0) {
        setMessage({ type: 'error', text: 'Unit price cannot be negative' });
        return false;
      }
    }

    return true;
  };

  const handleSave = async () => {
    if (!validateForm()) return;

    setIsSubmitting(true);
    setMessage(null);

    try {
      await updatePurchaseOrder({
        id,
        vendor,
        description,
        expenseTypeId,
        lineItems: lineItems.map((item) => ({
          description: item.description,
          propertyId: item.propertyId,
          glAccountId: item.glAccountId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          taxAmount: item.taxAmount,
        })),
      });

      setMessage({ type: 'success', text: 'Purchase order updated successfully' });
      setTimeout(() => {
        navigate(`/purchase-orders/${id}`);
      }, 1500);
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to update purchase order' });
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

  if (isLoadingPO) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p>Loading...</p>
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
            <Button onClick={() => navigate('/purchase-orders')}>
              Back to Purchase Orders
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (purchaseOrder.status !== 'DRAFT') {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Card className="w-96">
          <CardHeader>
            <CardTitle>Cannot Edit</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground mb-4">
              Only draft purchase orders can be edited.
            </p>
            <Button onClick={() => navigate(`/purchase-orders/${id}`)}>
              View Purchase Order
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="py-10 lg:mt-10">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => navigate(`/purchase-orders/${id}`)}>
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-3xl font-bold tracking-tight">Edit Purchase Order #{purchaseOrder.poNumber}</h1>
              <p className="text-muted-foreground mt-2">
                Update the purchase order details
              </p>
            </div>
          </div>
        </div>

        {message && (
          <Alert variant={message.type === 'error' ? 'destructive' : 'default'} className="mb-6">
            <AlertDescription>{message.text}</AlertDescription>
          </Alert>
        )}

        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Basic Information</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="vendor">Vendor *</Label>
                  <Input
                    id="vendor"
                    value={vendor}
                    onChange={(e) => setVendor(e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="expenseType">Expense Type *</Label>
                  <Select value={expenseTypeId} onValueChange={setExpenseTypeId}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {expenseTypes?.map((type: any) => (
                        <SelectItem key={type.id} value={type.id}>
                          {type.name} ({type.code})
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>
              <div className="space-y-2">
                <Label htmlFor="description">Description *</Label>
                <Textarea
                  id="description"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  rows={3}
                />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>Line Items</CardTitle>
                <Button onClick={addLineItem} size="sm">
                  <Plus className="h-4 w-4 mr-2" />
                  Add Line Item
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead className="w-[50px]">#</TableHead>
                      <TableHead>Description *</TableHead>
                      <TableHead>Property *</TableHead>
                      <TableHead>GL Account *</TableHead>
                      <TableHead className="w-[100px]">Qty *</TableHead>
                      <TableHead className="w-[120px]">Unit Price *</TableHead>
                      <TableHead className="w-[120px]">Tax</TableHead>
                      <TableHead className="w-[120px]">Total</TableHead>
                      <TableHead className="w-[50px]"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {lineItems.map((item, index) => (
                      <TableRow key={item.id}>
                        <TableCell>{index + 1}</TableCell>
                        <TableCell>
                          <Input
                            value={item.description}
                            onChange={(e) =>
                              updateLineItem(item.id, 'description', e.target.value)
                            }
                          />
                        </TableCell>
                        <TableCell>
                          <Select
                            value={item.propertyId}
                            onValueChange={(value) =>
                              updateLineItem(item.id, 'propertyId', value)
                            }
                          >
                            <SelectTrigger>
                              <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                              {properties?.map((property: any) => (
                                <SelectItem key={property.id} value={property.id}>
                                  {property.code}
                                </SelectItem>
                              ))}
                            </SelectContent>
                          </Select>
                        </TableCell>
                        <TableCell>
                          <Select
                            value={item.glAccountId}
                            onValueChange={(value) =>
                              updateLineItem(item.id, 'glAccountId', value)
                            }
                          >
                            <SelectTrigger>
                              <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                              {glAccounts?.map((account: any) => (
                                <SelectItem key={account.id} value={account.id}>
                                  {account.accountNumber}
                                </SelectItem>
                              ))}
                            </SelectContent>
                          </Select>
                        </TableCell>
                        <TableCell>
                          <Input
                            type="number"
                            min="0"
                            step="0.01"
                            value={item.quantity}
                            onChange={(e) =>
                              updateLineItem(item.id, 'quantity', parseFloat(e.target.value) || 0)
                            }
                          />
                        </TableCell>
                        <TableCell>
                          <Input
                            type="number"
                            min="0"
                            step="0.01"
                            value={item.unitPrice}
                            onChange={(e) =>
                              updateLineItem(item.id, 'unitPrice', parseFloat(e.target.value) || 0)
                            }
                          />
                        </TableCell>
                        <TableCell>
                          <Input
                            type="number"
                            min="0"
                            step="0.01"
                            value={item.taxAmount}
                            onChange={(e) =>
                              updateLineItem(item.id, 'taxAmount', parseFloat(e.target.value) || 0)
                            }
                          />
                        </TableCell>
                        <TableCell className="font-semibold">
                          {formatCurrency(calculateLineTotal(item))}
                        </TableCell>
                        <TableCell>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => removeLineItem(item.id)}
                            disabled={lineItems.length === 1}
                          >
                            <Trash2 className="h-4 w-4 text-destructive" />
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Summary</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Subtotal:</span>
                  <span className="font-medium">{formatCurrency(calculateSubtotal())}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Tax:</span>
                  <span className="font-medium">{formatCurrency(calculateTotalTax())}</span>
                </div>
                <div className="border-t pt-2 flex justify-between">
                  <span className="font-semibold">Total:</span>
                  <span className="font-bold text-lg">{formatCurrency(calculateTotal())}</span>
                </div>
              </div>
            </CardContent>
          </Card>

          <div className="flex gap-3 justify-end">
            <Button variant="outline" onClick={() => navigate(`/purchase-orders/${id}`)}>
              Cancel
            </Button>
            <Button onClick={handleSave} disabled={isSubmitting}>
              <Save className="h-4 w-4 mr-2" />
              {isSubmitting ? 'Saving...' : 'Save Changes'}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
