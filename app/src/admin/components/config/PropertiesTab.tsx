import { useState } from 'react';
import { useQuery, createProperty, updateProperty, deleteProperty, getProperties } from 'wasp/client/operations';
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
import { Plus, Edit, Trash2, MapPin } from 'lucide-react';
import { Alert, AlertDescription } from '../../../components/ui/alert';

interface PropertiesTabProps {
  organizationId: string;
}

export function PropertiesTab({ organizationId }: PropertiesTabProps) {
  const { data: properties, isLoading, refetch } = useQuery(getProperties);
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [editingProperty, setEditingProperty] = useState<any>(null);
  const [formData, setFormData] = useState({
    code: '',
    name: '',
    address: '',
  });
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const handleCreate = async () => {
    try {
      await createProperty(formData);
      setMessage({ type: 'success', text: 'Property created successfully!' });
      setIsCreateDialogOpen(false);
      setFormData({ code: '', name: '', address: '' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to create property' });
    }
  };

  const handleUpdate = async () => {
    try {
      await updateProperty({
        id: editingProperty.id,
        ...formData,
      });
      setMessage({ type: 'success', text: 'Property updated successfully!' });
      setEditingProperty(null);
      setFormData({ code: '', name: '', address: '' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to update property' });
    }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!confirm(`Are you sure you want to delete property "${name}"?`)) {
      return;
    }

    try {
      await deleteProperty({ id });
      setMessage({ type: 'success', text: 'Property deleted successfully!' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to delete property' });
    }
  };

  const openEditDialog = (property: any) => {
    setEditingProperty(property);
    setFormData({
      code: property.code,
      name: property.name,
      address: property.address || '',
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
              <CardTitle>Properties</CardTitle>
              <CardDescription>
                Manage property codes and locations for your organization
              </CardDescription>
            </div>
            <Dialog open={isCreateDialogOpen || !!editingProperty} onOpenChange={(open) => {
              setIsCreateDialogOpen(open);
              if (!open) {
                setEditingProperty(null);
                setFormData({ code: '', name: '', address: '' });
              }
            }}>
              <DialogTrigger asChild>
                <Button>
                  <Plus className="h-4 w-4 mr-2" />
                  Add Property
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>
                    {editingProperty ? 'Edit Property' : 'Create New Property'}
                  </DialogTitle>
                  <DialogDescription>
                    {editingProperty ? 'Update property details' : 'Add a new property to your organization'}
                  </DialogDescription>
                </DialogHeader>
                <div className="space-y-4 py-4">
                  <div className="space-y-2">
                    <Label htmlFor="code">Property Code</Label>
                    <Input
                      id="code"
                      placeholder="MW-1007"
                      value={formData.code}
                      onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="name">Property Name</Label>
                    <Input
                      id="name"
                      placeholder="Building A Unit 1007"
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="address">Address (Optional)</Label>
                    <Input
                      id="address"
                      placeholder="123 Main St"
                      value={formData.address}
                      onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                    />
                  </div>
                </div>
                <DialogFooter>
                  <Button
                    variant="outline"
                    onClick={() => {
                      setIsCreateDialogOpen(false);
                      setEditingProperty(null);
                      setFormData({ code: '', name: '', address: '' });
                    }}
                  >
                    Cancel
                  </Button>
                  <Button
                    onClick={editingProperty ? handleUpdate : handleCreate}
                    disabled={!formData.code || !formData.name}
                  >
                    {editingProperty ? 'Update' : 'Create'}
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <p className="text-center py-8 text-muted-foreground">Loading properties...</p>
          ) : properties && properties.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Code</TableHead>
                  <TableHead>Name</TableHead>
                  <TableHead>Address</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {properties.map((property: any) => (
                  <TableRow key={property.id}>
                    <TableCell className="font-mono font-bold">
                      {property.code}
                    </TableCell>
                    <TableCell>{property.name}</TableCell>
                    <TableCell>
                      {property.address ? (
                        <div className="flex items-center gap-2">
                          <MapPin className="h-4 w-4 text-muted-foreground" />
                          {property.address}
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
                          onClick={() => openEditDialog(property)}
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => handleDelete(property.id, property.name)}
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
              No properties yet. Create your first property to get started.
            </p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
