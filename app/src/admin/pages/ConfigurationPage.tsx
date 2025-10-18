import { useState } from 'react';
import { useQuery } from 'wasp/client/operations';
import { getUserOrganization } from 'wasp/client/operations';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../../components/ui/tabs';
import { PropertiesTab } from '../components/config/PropertiesTab';
import { GLAccountsTab } from '../components/config/GLAccountsTab';
import { ExpenseTypesTab } from '../components/config/ExpenseTypesTab';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../../components/ui/card';
import { Building2, DollarSign, Tag } from 'lucide-react';
import NavBar from '../../client/components/NavBar/NavBar';

export default function ConfigurationPage() {
  const { data: organization, isLoading } = useQuery(getUserOrganization);
  const [activeTab, setActiveTab] = useState('properties');

  if (isLoading) {
    return (
    <><NavBar />
      <div className="flex items-center justify-center min-h-screen">
        <p>Loading configuration...</p>
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
              You must belong to an organization to manage configuration.
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
        <div className="mb-8">
          <h1 className="text-3xl font-bold tracking-tight">Organization Configuration</h1>
          <p className="text-muted-foreground mt-2">
            Manage properties, GL accounts, and expense types for {organization.name}
          </p>
        </div>

        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="grid w-full grid-cols-3 lg:w-[600px]">
            <TabsTrigger value="properties" className="flex items-center gap-2">
              <Building2 className="h-4 w-4" />
              Properties
            </TabsTrigger>
            <TabsTrigger value="glaccounts" className="flex items-center gap-2">
              <DollarSign className="h-4 w-4" />
              GL Accounts
            </TabsTrigger>
            <TabsTrigger value="expensetypes" className="flex items-center gap-2">
              <Tag className="h-4 w-4" />
              Expense Types
            </TabsTrigger>
          </TabsList>

          <TabsContent value="properties" className="mt-6">
            <PropertiesTab organizationId={organization.id} />
          </TabsContent>

          <TabsContent value="glaccounts" className="mt-6">
            <GLAccountsTab organizationId={organization.id} />
          </TabsContent>

          <TabsContent value="expensetypes" className="mt-6">
            <ExpenseTypesTab organizationId={organization.id} />
          </TabsContent>
        </Tabs>
      </div>
    </div>
    </>
  );
}
