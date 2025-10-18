import { useState } from 'react';
import { useQuery, createGLAccount, updateGLAccount, deleteGLAccount, getGLAccounts } from 'wasp/client/operations';
import { Button } from '../../../components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../../../components/ui/card';
import { Input } from '../../../components/ui/input';
import { Label } from '../../../components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '../../../components/ui/select';
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
import { Plus, Edit, Trash2, TrendingUp } from 'lucide-react';
import { Alert, AlertDescription } from '../../../components/ui/alert';
import { Badge } from '../../../components/ui/badge';

interface GLAccountsTabProps {
  organizationId: string;
}

const ACCOUNT_TYPES = [
  { value: 'ASSET', label: 'Asset' },
  { value: 'LIABILITY', label: 'Liability' },
  { value: 'EQUITY', label: 'Equity' },
  { value: 'REVENUE', label: 'Revenue' },
  { value: 'EXPENSE', label: 'Expense' },
];

const ACCOUNT_TYPE_COLORS: Record<string, any> = {
  ASSET: 'default',
  LIABILITY: 'destructive',
  EQUITY: 'secondary',
  REVENUE: 'default',
  EXPENSE: 'default',
};

export function GLAccountsTab({ organizationId }: GLAccountsTabProps) {
  const { data: glAccounts, isLoading, refetch } = useQuery(getGLAccounts);
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [editingAccount, setEditingAccount] = useState<any>(null);
  const [formData, setFormData] = useState({
    accountNumber: '',
    name: '',
    accountType: 'EXPENSE',
    annualBudget: '',
  });
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const handleCreate = async () => {
    try {
      await createGLAccount({
        accountNumber: formData.accountNumber,
        name: formData.name,
        accountType: formData.accountType,
        annualBudget: formData.annualBudget ? parseFloat(formData.annualBudget) : undefined,
      });
      setMessage({ type: 'success', text: 'GL Account created successfully!' });
      setIsCreateDialogOpen(false);
      setFormData({ accountNumber: '', name: '', accountType: 'EXPENSE', annualBudget: '' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to create GL account' });
    }
  };

  const handleUpdate = async () => {
    try {
      await updateGLAccount({
        id: editingAccount.id,
        accountNumber: formData.accountNumber,
        name: formData.name,
        accountType: formData.accountType,
        annualBudget: formData.annualBudget ? parseFloat(formData.annualBudget) : undefined,
      });
      setMessage({ type: 'success', text: 'GL Account updated successfully!' });
      setEditingAccount(null);
      setFormData({ accountNumber: '', name: '', accountType: 'EXPENSE', annualBudget: '' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to update GL account' });
    }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!confirm(`Are you sure you want to delete GL account "${name}"?`)) {
      return;
    }

    try {
      await deleteGLAccount({ id });
      setMessage({ type: 'success', text: 'GL Account deleted successfully!' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to delete GL account' });
    }
  };

  const openEditDialog = (account: any) => {
    setEditingAccount(account);
    setFormData({
      accountNumber: account.accountNumber,
      name: account.name,
      accountType: account.accountType,
      annualBudget: account.annualBudget ? account.annualBudget.toString() : '',
    });
  };

  const formatCurrency = (amount: number | null) => {
    if (!amount) return '-';
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
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
              <CardTitle>GL Accounts</CardTitle>
              <CardDescription>
                Manage general ledger accounts and budgets
              </CardDescription>
            </div>
            <Dialog open={isCreateDialogOpen || !!editingAccount} onOpenChange={(open) => {
              setIsCreateDialogOpen(open);
              if (!open) {
                setEditingAccount(null);
                setFormData({ accountNumber: '', name: '', accountType: 'EXPENSE', annualBudget: '' });
              }
            }}>
              <DialogTrigger asChild>
                <Button>
                  <Plus className="h-4 w-4 mr-2" />
                  Add GL Account
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>
                    {editingAccount ? 'Edit GL Account' : 'Create New GL Account'}
                  </DialogTitle>
                  <DialogDescription>
                    {editingAccount ? 'Update GL account details' : 'Add a new GL account to your organization'}
                  </DialogDescription>
                </DialogHeader>
                <div className="space-y-4 py-4">
                  <div className="space-y-2">
                    <Label htmlFor="accountNumber">Account Number</Label>
                    <Input
                      id="accountNumber"
                      placeholder="7556"
                      value={formData.accountNumber}
                      onChange={(e) => setFormData({ ...formData, accountNumber: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="name">Account Name</Label>
                    <Input
                      id="name"
                      placeholder="Paint & Supplies (Expense)"
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="accountType">Account Type</Label>
                    <Select value={formData.accountType} onValueChange={(value) => setFormData({ ...formData, accountType: value })}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        {ACCOUNT_TYPES.map((type) => (
                          <SelectItem key={type.value} value={type.value}>
                            {type.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="annualBudget">Annual Budget (Optional)</Label>
                    <Input
                      id="annualBudget"
                      type="number"
                      placeholder="50000"
                      value={formData.annualBudget}
                      onChange={(e) => setFormData({ ...formData, annualBudget: e.target.value })}
                    />
                  </div>
                </div>
                <DialogFooter>
                  <Button
                    variant="outline"
                    onClick={() => {
                      setIsCreateDialogOpen(false);
                      setEditingAccount(null);
                      setFormData({ accountNumber: '', name: '', accountType: 'EXPENSE', annualBudget: '' });
                    }}
                  >
                    Cancel
                  </Button>
                  <Button
                    onClick={editingAccount ? handleUpdate : handleCreate}
                    disabled={!formData.accountNumber || !formData.name}
                  >
                    {editingAccount ? 'Update' : 'Create'}
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <p className="text-center py-8 text-muted-foreground">Loading GL accounts...</p>
          ) : glAccounts && glAccounts.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Account #</TableHead>
                  <TableHead>Name</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Annual Budget</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {glAccounts.map((account: any) => (
                  <TableRow key={account.id}>
                    <TableCell className="font-mono font-bold">
                      {account.accountNumber}
                    </TableCell>
                    <TableCell>{account.name}</TableCell>
                    <TableCell>
                      <Badge variant={ACCOUNT_TYPE_COLORS[account.accountType]}>
                        {account.accountType}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      {account.annualBudget ? (
                        <div className="flex items-center gap-2">
                          <TrendingUp className="h-4 w-4 text-muted-foreground" />
                          {formatCurrency(account.annualBudget)}
                        </div>
                      ) : (
                        '-'
                      )}
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex items-center justify-end gap-2">
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => openEditDialog(account)}
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => handleDelete(account.id, account.name)}
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
              No GL accounts yet. Create your first GL account to get started.
            </p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
