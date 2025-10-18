import { useState } from 'react';
import { useQuery, inviteUserToOrganization, updateUserRole, removeUserFromOrganization, getUserOrganization } from 'wasp/client/operations';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Input } from '../../components/ui/input';
import { Label } from '../../components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '../../components/ui/select';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '../../components/ui/dialog';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../../components/ui/table';
import { Badge } from '../../components/ui/badge';
import { UserPlus, Mail, Phone, Trash2, Edit, Shield } from 'lucide-react';
import { Alert, AlertDescription } from '../../components/ui/alert';
import NavBar from '../../client/components/NavBar/NavBar';

const ROLE_LABELS = {
  USER: 'User',
  PROPERTY_MANAGER: 'Property Manager',
  ACCOUNTING: 'Accounting',
  CORPORATE: 'Corporate',
  ADMIN: 'Admin',
};

const ROLE_COLORS = {
  USER: 'default',
  PROPERTY_MANAGER: 'secondary',
  ACCOUNTING: 'default',
  CORPORATE: 'default',
  ADMIN: 'destructive',
} as const;

export default function UserManagementPage() {
  const { data: organization, isLoading, refetch } = useQuery(getUserOrganization);
  const [isInviteDialogOpen, setIsInviteDialogOpen] = useState(false);
  const [inviteEmail, setInviteEmail] = useState('');
  const [inviteRole, setInviteRole] = useState<string>('USER');
  const [invitePhone, setInvitePhone] = useState('');
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [editingUserId, setEditingUserId] = useState<string | null>(null);
  const [editRole, setEditRole] = useState<string>('USER');

  const handleInviteUser = async () => {
    try {
      await inviteUserToOrganization({
        email: inviteEmail,
        role: inviteRole as any,
        phoneNumber: invitePhone || undefined,
      });
      setMessage({ type: 'success', text: 'Invitation sent successfully!' });
      setIsInviteDialogOpen(false);
      setInviteEmail('');
      setInviteRole('USER');
      setInvitePhone('');
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to invite user' });
    }
  };

  const handleUpdateRole = async (userId: string) => {
    try {
      await updateUserRole({ userId, role: editRole as any });
      setMessage({ type: 'success', text: 'User role updated successfully!' });
      setEditingUserId(null);
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to update role' });
    }
  };

  const handleRemoveUser = async (userId: string, userEmail: string) => {
    if (!confirm(`Are you sure you want to remove ${userEmail} from the organization?`)) {
      return;
    }

    try {
      await removeUserFromOrganization({ userId });
      setMessage({ type: 'success', text: 'User removed successfully!' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to remove user' });
    }
  };

  if (isLoading) {
    return (
      <><NavBar />
      <div className="flex items-center justify-center min-h-screen">
        <p>Loading...</p>
      </div>
      </>
    );
  }

  if (!organization) {
    return (
      <><NavBar />
      <div className="flex items-center justify-center min-h-screen">
        <Card className="w-96">
          <CardHeader>
            <CardTitle>No Organization</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground">
              You must belong to an organization to manage users.
            </p>
          </CardContent>
        </Card>
      </div>
      </>
    );
  }

  return (
      <><NavBar />
    <div className="py-10 lg:mt-10">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">{organization.name}</h1>
            <p className="text-muted-foreground mt-2">
              Manage users and their roles in your organization
            </p>
          </div>
          <Dialog open={isInviteDialogOpen} onOpenChange={setIsInviteDialogOpen}>
            <DialogTrigger asChild>
              <Button>
                <UserPlus className="h-4 w-4 mr-2" />
                Invite User
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Invite User to Organization</DialogTitle>
                <DialogDescription>
                  Send an invitation email to add a new user to your organization.
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4 py-4">
                <div className="space-y-2">
                  <Label htmlFor="email">Email Address</Label>
                  <Input
                    id="email"
                    type="email"
                    placeholder="user@example.com"
                    value={inviteEmail}
                    onChange={(e) => setInviteEmail(e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="phone">Phone Number (Optional)</Label>
                  <Input
                    id="phone"
                    type="tel"
                    placeholder="+1234567890"
                    value={invitePhone}
                    onChange={(e) => setInvitePhone(e.target.value)}
                  />
                  <p className="text-xs text-muted-foreground">
                    Required for SMS notifications
                  </p>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="role">Role</Label>
                  <Select value={inviteRole} onValueChange={setInviteRole}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="USER">User</SelectItem>
                      <SelectItem value="PROPERTY_MANAGER">Property Manager</SelectItem>
                      <SelectItem value="ACCOUNTING">Accounting</SelectItem>
                      <SelectItem value="CORPORATE">Corporate</SelectItem>
                      <SelectItem value="ADMIN">Admin</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
              <DialogFooter>
                <Button variant="outline" onClick={() => setIsInviteDialogOpen(false)}>
                  Cancel
                </Button>
                <Button onClick={handleInviteUser} disabled={!inviteEmail}>
                  Send Invitation
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>

        {message && (
          <Alert variant={message.type === 'error' ? 'destructive' : 'default'} className="mb-6">
            <AlertDescription>{message.text}</AlertDescription>
          </Alert>
        )}

        <Card>
          <CardHeader>
            <CardTitle>Organization Users ({organization.users?.length || 0})</CardTitle>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Email</TableHead>
                  <TableHead>Username</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead>Phone</TableHead>
                  <TableHead>Joined</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {organization.users?.map((user: any) => (
                  <TableRow key={user.id}>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Mail className="h-4 w-4 text-muted-foreground" />
                        {user.email}
                        {user.isAdmin && (
                          <Shield className="h-4 w-4 text-primary" />
                        )}
                      </div>
                    </TableCell>
                    <TableCell>{user.username || '-'}</TableCell>
                    <TableCell>
                      {editingUserId === user.id ? (
                        <div className="flex items-center gap-2">
                          <Select value={editRole} onValueChange={setEditRole}>
                            <SelectTrigger className="w-48">
                              <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="USER">User</SelectItem>
                              <SelectItem value="PROPERTY_MANAGER">Property Manager</SelectItem>
                              <SelectItem value="ACCOUNTING">Accounting</SelectItem>
                              <SelectItem value="CORPORATE">Corporate</SelectItem>
                              <SelectItem value="ADMIN">Admin</SelectItem>
                            </SelectContent>
                          </Select>
                          <Button
                            size="sm"
                            onClick={() => handleUpdateRole(user.id)}
                          >
                            Save
                          </Button>
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={() => setEditingUserId(null)}
                          >
                            Cancel
                          </Button>
                        </div>
                      ) : (
                        <Badge variant={ROLE_COLORS[user.role as keyof typeof ROLE_COLORS]}>
                          {ROLE_LABELS[user.role as keyof typeof ROLE_LABELS]}
                        </Badge>
                      )}
                    </TableCell>
                    <TableCell>
                      {user.phoneNumber ? (
                        <div className="flex items-center gap-2">
                          <Phone className="h-4 w-4 text-muted-foreground" />
                          {user.phoneNumber}
                        </div>
                      ) : (
                        '-'
                      )}
                    </TableCell>
                    <TableCell>
                      {new Date(user.createdAt).toLocaleDateString()}
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex items-center justify-end gap-2">
                        {editingUserId !== user.id && (
                          <Button
                            size="sm"
                            variant="ghost"
                            onClick={() => {
                              setEditingUserId(user.id);
                              setEditRole(user.role);
                            }}
                          >
                            <Edit className="h-4 w-4" />
                          </Button>
                        )}
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => handleRemoveUser(user.id, user.email)}
                        >
                          <Trash2 className="h-4 w-4 text-destructive" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>
    </div>
      </>
  );
}
