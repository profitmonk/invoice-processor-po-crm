import { useQuery } from 'wasp/client/operations';
import { getUserOrganization } from 'wasp/client/operations';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../../components/ui/card';
import { AdminLayout } from '../components/AdminLayout';
import { Users, Building2, DollarSign, FileText, TrendingUp } from 'lucide-react';
import { useAuth } from 'wasp/client/auth';
import { Link } from 'react-router-dom';

export default function AdminDashboardPage() {
  const { data: user } = useAuth();
  const { data: organization, isLoading } = useQuery(getUserOrganization);

  if (isLoading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-screen">
          <p>Loading dashboard...</p>
        </div>
      </AdminLayout>
    );
  }

  if (!organization) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-screen">
          <Card className="w-96">
            <CardHeader>
              <CardTitle>No Organization</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground">
                You must belong to an organization to access the admin dashboard.
              </p>
            </CardContent>
          </Card>
        </div>
      </AdminLayout>
    );
  }

  const stats = [
    {
      name: 'Total Users',
      value: organization.users?.length || 0,
      icon: Users,
      description: 'Active users in organization',
      color: 'text-blue-600',
      bgColor: 'bg-blue-100',
    },
    {
      name: 'Properties',
      value: organization.properties?.length || 0,
      icon: Building2,
      description: 'Managed properties',
      color: 'text-green-600',
      bgColor: 'bg-green-100',
    },
    {
      name: 'GL Accounts',
      value: organization.glAccounts?.length || 0,
      icon: DollarSign,
      description: 'General ledger accounts',
      color: 'text-purple-600',
      bgColor: 'bg-purple-100',
    },
    {
      name: 'Expense Types',
      value: organization.expenseTypes?.length || 0,
      icon: FileText,
      description: 'Expense categories',
      color: 'text-orange-600',
      bgColor: 'bg-orange-100',
    },
  ];

  const totalBudget = organization.glAccounts?.reduce(
    (sum: number, account: any) => sum + (account.annualBudget || 0),
    0
  ) || 0;

  return (
    <AdminLayout>
      <div className="py-10 px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold tracking-tight">
            Welcome back, {user?.username || user?.email}
          </h1>
          <p className="text-muted-foreground mt-2">
            Here is an overview of {organization.name}
          </p>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4 mb-8">
          {stats.map((stat) => {
            const Icon = stat.icon;
            return (
              <Card key={stat.name}>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-muted-foreground">
                        {stat.name}
                      </p>
                      <p className="text-3xl font-bold mt-2">{stat.value}</p>
                      <p className="text-xs text-muted-foreground mt-1">
                        {stat.description}
                      </p>
                    </div>
                    <div className={`p-3 rounded-full ${stat.bgColor}`}>
                      <Icon className={`h-6 w-6 ${stat.color}`} />
                    </div>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <Card>
            <CardHeader>
              <CardTitle>Organization Details</CardTitle>
              <CardDescription>
                Basic information about your organization
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <p className="text-sm font-medium text-muted-foreground">Name</p>
                <p className="text-lg font-semibold">{organization.name}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-muted-foreground">Code</p>
                <p className="text-lg font-semibold font-mono">{organization.code}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-muted-foreground">
                  PO Approval Threshold
                </p>
                <p className="text-lg font-semibold">
                  ${organization.poApprovalThreshold?.toLocaleString()}
                </p>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Budget Overview</CardTitle>
              <CardDescription>
                Total annual budgets across all GL accounts
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-muted-foreground">
                    Total Annual Budget
                  </p>
                  <p className="text-3xl font-bold mt-2">
                    ${totalBudget.toLocaleString()}
                  </p>
                </div>
                <div className="p-3 rounded-full bg-green-100">
                  <TrendingUp className="h-6 w-6 text-green-600" />
                </div>
              </div>
              <div className="mt-6 space-y-2">
                <p className="text-sm text-muted-foreground">
                  Accounts with budgets: {organization.glAccounts?.filter((acc: any) => acc.annualBudget).length || 0}
                </p>
              </div>
            </CardContent>
          </Card>
        </div>

        <Card className="mt-6">
          <CardHeader>
            <CardTitle>Quick Actions</CardTitle>
            <CardDescription>
              Common administrative tasks
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <Link
                to="/admin/users"
                className="p-4 rounded-lg border hover:bg-muted transition-colors cursor-pointer"
              >
                <Users className="h-6 w-6 text-primary mb-2" />
                <p className="font-medium">Manage Users</p>
                <p className="text-sm text-muted-foreground">Invite and manage team members</p>
              </Link>
              <Link
                to="/admin/configuration"
                className="p-4 rounded-lg border hover:bg-muted transition-colors cursor-pointer"
              >
                <Building2 className="h-6 w-6 text-primary mb-2" />
                <p className="font-medium">Configuration</p>
                <p className="text-sm text-muted-foreground">Set up properties and accounts</p>
              </Link>
              <Link
                to="/purchase-orders"
                className="p-4 rounded-lg border hover:bg-muted transition-colors cursor-pointer"
              >
                <FileText className="h-6 w-6 text-primary mb-2" />
                <p className="font-medium">Purchase Orders</p>
                <p className="text-sm text-muted-foreground">Create and manage POs</p>
              </Link>
              <Link
                to="/invoices"
                className="p-4 rounded-lg border hover:bg-muted transition-colors cursor-pointer"
              >
                <FileText className="h-6 w-6 text-primary mb-2" />
                <p className="font-medium">Invoices</p>
                <p className="text-sm text-muted-foreground">Process and track invoices</p>
              </Link>
            </div>
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  );
}
