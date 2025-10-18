import { useState } from 'react';
import { useQuery, createExpenseType, updateExpenseType, deleteExpenseType, getExpenseTypes } from 'wasp/client/operations';
import { Button } from '../../../components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../../../components/ui/card';
import { Input } from '../../../components/ui/input';
import { Label } from '../../../components/ui/label';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '../../../components/ui/dialog';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../../../components/ui/table';
import { Plus, Edit, Trash2, Tag } from 'lucide-react';
import { Alert, AlertDescription } from '../../../components/ui/alert';
import { Badge } from '../../../components/ui/badge';

interface ExpenseTypesTabProps {
  organizationId: string;
}

export function ExpenseTypesTab({ organizationId }: ExpenseTypesTabProps) {
  const { data: expenseTypes, isLoading, refetch } = useQuery(getExpenseTypes);
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [editingType, setEditingType] = useState<any>(null);
  const [formData, setFormData] = useState({
    name: '',
    code: '',
  });
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const handleCreate = async () => {
    try {
      await createExpenseType(formData);
      setMessage({ type: 'success', text: 'Expense type created successfully!' });
      setIsCreateDialogOpen(false);
      setFormData({ name: '', code: '' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to create expense type' });
    }
  };

  const handleUpdate = async () => {
    try {
      await updateExpenseType({
        id: editingType.id,
        ...formData,
      });
      setMessage({ type: 'success', text: 'Expense type updated successfully!' });
      setEditingType(null);
      setFormData({ name: '', code: '' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to update expense type' });
    }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!confirm(`Are you sure you want to delete expense type "${name}"?`)) {
      return;
    }

    try {
      await deleteExpenseType({ id });
      setMessage({ type: 'success', text: 'Expense type deleted successfully!' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to delete expense type' });
    }
  };

  const openEditDialog = (type: any) => {
    setEditingType(type);
    setFormData({
      name: type.name,
      code: type.code,
    });
  };

  return (
    <div className="space-y-6">
      {message && (
        <Alert variant={message.type === 'error' ? 'destructive' : 'default'}>
          <AlertDescription>{message.text}</AlertDescription>
        </Alert>
      )}

      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Expense Types</CardTitle>
              <CardDescription>
                Manage expense type categories for purchase orders
              </CardDescription>
            </div>
            <Dialog open={isCreateDialogOpen || !!editingType} onOpenChange={(open) => {
              setIsCreateDialogOpen(open);
              if (!open) {
                setEditingType(null);
                setFormData({ name: '', code: '' });
              }
            }}>
              <DialogTrigger asChild>
                <Button>
                  <Plus className="h-4 w-4 mr-2" />
                  Add Expense Type
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>
                    {editingType ? 'Edit Expense Type' : 'Create New Expense Type'}
                  </DialogTitle>
                  <DialogDescription>
                    {editingType ? 'Update expense type details' : 'Add a new expense type to your organization'}
                  </DialogDescription>
                </DialogHeader>
                <div className="space-y-4 py-4">
                  <div className="space-y-2">
                    <Label htmlFor="name">Name</Label>
                    <Input
                      id="name"
                      placeholder="Capital Expense"
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="code">Code</Label>
                    <Input
                      id="code"
                      placeholder="CAPEX"
                      value={formData.code}
                      onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
                    />
                  </div>
                </div>
                <DialogFooter>
                  <Button
                    variant="outline"
                    onClick={() => {
                      setIsCreateDialogOpen(false);
                      setEditingType(null);
                      setFormData({ name: '', code: '' });
                    }}
                  >
                    Cancel
                  </Button>
                  <Button
                    onClick={editingType ? handleUpdate : handleCreate}
                    disabled={!formData.name || !formData.code}
                  >
                    {editingType ? 'Update' : 'Create'}
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <p className="text-center py-8 text-muted-foreground">Loading expense types...</p>
          ) : expenseTypes && expenseTypes.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Code</TableHead>
                  <TableHead>Name</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {expenseTypes.map((type: any) => (
                  <TableRow key={type.id}>
                    <TableCell>
                      <Badge variant="secondary" className="font-mono">
                        {type.code}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Tag className="h-4 w-4 text-muted-foreground" />
                        {type.name}
                      </div>
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex items-center justify-end gap-2">
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => openEditDialog(type)}
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => handleDelete(type.id, type.name)}
                        >
                          <Trash2 className="h-4 w-4 text-destructive" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <p className="text-center py-8 text-muted-foreground">
              No expense types yet. Create your first expense type to get started.
            </p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
