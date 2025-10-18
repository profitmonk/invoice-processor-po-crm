import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  useQuery,
  createPurchaseOrder,
  getProperties,
  getGLAccounts,
  getExpenseTypes,
  getPurchaseOrderTemplates,
  createPurchaseOrderFromTemplate,
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
import { Plus, Trash2, Save, Send, ArrowLeft, Copy } from 'lucide-react';
import { Checkbox } from '../../components/ui/checkbox';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '../../components/ui/dialog';

interface LineItem {
  id: string;
  description: string;
  propertyId: string;
  glAccountId: string;
  quantity: number;
  unitPrice: number;
  taxAmount: number;
}

export default function CreatePurchaseOrderPage() {
  const navigate = useNavigate();
  const { data: properties } = useQuery(getProperties);
  const { data: glAccounts } = useQuery(getGLAccounts);
  const { data: expenseTypes } = useQuery(getExpenseTypes);
  const { data: templates } = useQuery(getPurchaseOrderTemplates);

  const [vendor, setVendor] = useState('');
  const [description, setDescription] = useState('');
  const [expenseTypeId, setExpenseTypeId] = useState('');
  const [lineItems, setLineItems] = useState<LineItem[]>([
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
  const [isTemplate, setIsTemplate] = useState(false);
  const [templateName, setTemplateName] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [isTemplateDialogOpen, setIsTemplateDialogOpen] = useState(false);

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

  const removeLineItem = (id: string) => {
    if (lineItems.length === 1) {
      setMessage({ type: 'error', text: 'Purchase order must have at least one line item' });
      return;
    }
    setLineItems(lineItems.filter((item) => item.id !== id));
  };

  const updateLineItem = (id: string, field: keyof LineItem, value: any) => {
    setLineItems(
      lineItems.map((item) =>
        item.id === id ? { ...item, [field]: value } : item
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

    if (isTemplate && !templateName.trim()) {
      setMessage({ type: 'error', text: 'Template name is required' });
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

  const handleSaveDraft = async () => {
    if (!validateForm()) return;
  
    setIsSubmitting(true);
    setMessage(null);
  
    try {
      let templateId;
      
      // If template is checked, create template first
      if (isTemplate) {
        const template = await createPurchaseOrder({
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
          isTemplate: true,
          templateName: templateName,
          submitForApproval: false,
        });
        templateId = template.id;
      }
  
      // Always create the actual PO (not as template)
      const po = await createPurchaseOrder({
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
        isTemplate: false,
        submitForApproval: false,
      });
  
      setMessage({ 
        type: 'success', 
        text: isTemplate ? 'Template and PO saved as draft!' : 'Purchase order saved as draft' 
      });
      
      setTimeout(() => {
        navigate(`/purchase-orders/${po.id}`);
      }, 1500);
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to save purchase order' });
    } finally {
      setIsSubmitting(false);
    }
  };
  
  const handleSubmitForApproval = async () => {
    if (!validateForm()) return;
  
    setIsSubmitting(true);
    setMessage(null);
  
    try {
      let templateId;
      
      // If template is checked, create template first
      if (isTemplate) {
        const template = await createPurchaseOrder({
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
          isTemplate: true,
          templateName: templateName,
          submitForApproval: false,
        });
        templateId = template.id;
      }
  
      // Always create the actual PO (not as template) and submit
      const po = await createPurchaseOrder({
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
        isTemplate: false,
        submitForApproval: true,
      });
  
      setMessage({ 
        type: 'success', 
        text: isTemplate ? 'Template saved and PO submitted for approval!' : 'Purchase order submitted for approval' 
      });
      
      setTimeout(() => {
        navigate(`/purchase-orders/${po.id}`);
      }, 1500);
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to submit purchase order' });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleUseTemplate = async (templateId: string) => {
    try {
      const po = await createPurchaseOrderFromTemplate({ templateId });
      setMessage({ type: 'success', text: 'Template loaded successfully' });
      
      // Populate form with template data
      setVendor(po.vendor);
      setDescription(po.description);
      setExpenseTypeId(po.expenseTypeId);
      setLineItems(
        po.lineItems.map((item: any) => ({
          id: crypto.randomUUID(),
          description: item.description,
          propertyId: item.propertyId,
          glAccountId: item.glAccountId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          taxAmount: item.taxAmount,
        }))
      );
      
      setIsTemplateDialogOpen(false);
      
      // Navigate to the new PO
      setTimeout(() => {
        navigate(`/purchase-orders/${po.id}`);
      }, 1000);
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to load template' });
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  return (
    <div className="py-10 lg:mt-10">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => navigate('/purchase-orders')}>
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-3xl font-bold tracking-tight">Create Purchase Order</h1>
              <p className="text-muted-foreground mt-2">
                Fill in the details to create a new purchase order
              </p>
            </div>
          </div>
          {templates && templates.length > 0 && (
            <Dialog open={isTemplateDialogOpen} onOpenChange={setIsTemplateDialogOpen}>
              <DialogTrigger asChild>
                <Button variant="outline">
                  <Copy className="h-4 w-4 mr-2" />
                  Use Template
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Select Template</DialogTitle>
                  <DialogDescription>
                    Choose a template to pre-fill the purchase order
                  </DialogDescription>
                </DialogHeader>
                <div className="space-y-2">
                  {templates.map((template: any) => (
                    <Button
                      key={template.id}
                      variant="outline"
                      className="w-full justify-start"
                      onClick={() => handleUseTemplate(template.id)}
                    >
                      <div className="text-left">
                        <p className="font-semibold">{template.templateName}</p>
                        <p className="text-sm text-muted-foreground">
                          {template.vendor} • {template.lineItems.length} items
                        </p>
                      </div>
                    </Button>
                  ))}
                </div>
              </DialogContent>
            </Dialog>
          )}
        </div>

        {message && (
          <Alert variant={message.type === 'error' ? 'destructive' : 'default'} className="mb-6">
            <AlertDescription>{message.text}</AlertDescription>
          </Alert>
        )}

        <div className="space-y-6">
          {/* Basic Information */}
          <Card>
            <CardHeader>
              <CardTitle>Basic Information</CardTitle>
              <CardDescription>Enter the vendor and purchase order details</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="vendor">Vendor *</Label>
                  <Input
                    id="vendor"
                    placeholder="Fast & Furious Remodeling"
                    value={vendor}
                    onChange={(e) => setVendor(e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="expenseType">Expense Type *</Label>
                  <Select value={expenseTypeId} onValueChange={setExpenseTypeId}>
                    <SelectTrigger>
                      <SelectValue placeholder="Select expense type" />
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
                  placeholder="Unit 1007 Turnover"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  rows={3}
                />
              </div>
              <div className="flex items-center space-x-2">
                <Checkbox
                  id="isTemplate"
                  checked={isTemplate}
                  onCheckedChange={(checked) => setIsTemplate(checked as boolean)}
                />
                <Label htmlFor="isTemplate" className="cursor-pointer">
                  Save as template for future use
                </Label>
              </div>
              {isTemplate && (
                <div className="space-y-2">
                  <Label htmlFor="templateName">Template Name *</Label>
                  <Input
                    id="templateName"
                    placeholder="Unit Turnover Template"
                    value={templateName}
                    onChange={(e) => setTemplateName(e.target.value)}
                  />
                </div>
              )}
            </CardContent>
          </Card>

          {/* Line Items */}
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle>Line Items</CardTitle>
                  <CardDescription>Add items to this purchase order</CardDescription>
                </div>
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
                            placeholder="Item description"
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
                              <SelectValue placeholder="Property" />
                            </SelectTrigger>
                            <SelectContent>
                              {properties?.map((property: any) => (
                                <SelectItem key={property.id} value={property.id}>
                                  {property.code} - {property.name}
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
                              <SelectValue placeholder="GL Account" />
                            </SelectTrigger>
                            <SelectContent>
                              {glAccounts?.map((account: any) => (
                                <SelectItem key={account.id} value={account.id}>
                                  {account.accountNumber} - {account.name}
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

          {/* Summary */}
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

          {/* Actions */}
          <div className="flex gap-3 justify-end">
            <Button variant="outline" onClick={() => navigate('/purchase-orders')}>
              Cancel
            </Button>
            <Button
              variant="secondary"
              onClick={handleSaveDraft}
              disabled={isSubmitting}
            >
              <Save className="h-4 w-4 mr-2" />
              Save Draft
            </Button>
            <Button onClick={handleSubmitForApproval} disabled={isSubmitting}>
              <Send className="h-4 w-4 mr-2" />
              Submit for Approval
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
