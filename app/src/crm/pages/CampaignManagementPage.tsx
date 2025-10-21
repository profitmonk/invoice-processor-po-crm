// app/src/crm/pages/CampaignManagementPage.tsx

import { useState } from 'react';
import { useQuery } from 'wasp/client/operations';
import { getUserOrganization } from 'wasp/client/operations';
import {
  setupOrganizationCommunication,
  checkCampaignStatus,
  getCampaignLimits,
} from 'wasp/client/operations';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Badge } from '../../components/ui/badge';
import { Alert, AlertDescription } from '../../components/ui/alert';
import {
  Phone,
  MessageSquare,
  CheckCircle,
  XCircle,
  Clock,
  AlertTriangle,
  RefreshCw,
  Zap,
} from 'lucide-react';

const STATUS_CONFIG: Record<string, any> = {
  NOT_REGISTERED: {
    icon: XCircle,
    color: 'text-gray-500',
    bg: 'bg-gray-100',
    label: 'Not Registered',
    variant: 'secondary',
  },
  PENDING: {
    icon: Clock,
    color: 'text-yellow-600',
    bg: 'bg-yellow-100',
    label: 'Pending Approval',
    variant: 'default',
  },
  APPROVED: {
    icon: CheckCircle,
    color: 'text-green-600',
    bg: 'bg-green-100',
    label: 'Approved',
    variant: 'default',
  },
  REJECTED: {
    icon: XCircle,
    color: 'text-red-600',
    bg: 'bg-red-100',
    label: 'Rejected',
    variant: 'destructive',
  },
  SUSPENDED: {
    icon: AlertTriangle,
    color: 'text-orange-600',
    bg: 'bg-orange-100',
    label: 'Suspended',
    variant: 'secondary',
  },
};

export default function CampaignManagementPage() {
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [limits, setLimits] = useState<any>(null);

  const { data: organization, isLoading, refetch } = useQuery(getUserOrganization);

  const handleSetupCommunication = async () => {
    if (!organization) return;

    setLoading(true);
    setMessage(null);

    try {
      const result = await setupOrganizationCommunication({
        organizationId: organization.id,
        areaCode: '555',
      });

      setMessage({
        type: 'success',
        text: result.message || 'Communication setup initiated!',
      });
      refetch();
    } catch (error: any) {
      setMessage({
        type: 'error',
        text: error.message || 'Failed to setup communication',
      });
    } finally {
      setLoading(false);
    }
  };

  const handleCheckStatus = async () => {
    if (!organization) return;

    setLoading(true);
    setMessage(null);

    try {
      const result = await checkCampaignStatus({
        organizationId: organization.id,
      });

      setMessage({
        type: 'success',
        text: `Campaign status: ${result.status}`,
      });
      refetch();
    } catch (error: any) {
      setMessage({
        type: 'error',
        text: error.message || 'Failed to check status',
      });
    } finally {
      setLoading(false);
    }
  };

  const handleGetLimits = async () => {
    if (!organization) return;

    setLoading(true);

    try {
      const result = await getCampaignLimits({
        organizationId: organization.id,
      });
      setLimits(result);
    } catch (error: any) {
      setMessage({
        type: 'error',
        text: error.message || 'Failed to get limits',
      });
    } finally {
      setLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p>Loading...</p>
      </div>
    );
  }

  if (!organization) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Card className="w-96">
          <CardHeader>
            <CardTitle>No Organization</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground">
              You must belong to an organization to manage campaigns.
            </p>
          </CardContent>
        </Card>
      </div>
    );
  }

  const statusConfig = STATUS_CONFIG[organization.campaignStatus || 'NOT_REGISTERED'];
  const StatusIcon = statusConfig?.icon || XCircle;

  return (
    <div className="py-10 lg:mt-10">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold tracking-tight">Campaign Management</h1>
          <p className="text-muted-foreground mt-2">
            Manage SMS campaigns for {organization.name}
          </p>
        </div>

        {message && (
          <Alert
            variant={message.type === 'error' ? 'destructive' : 'default'}
            className="mb-6"
          >
            <AlertDescription>{message.text}</AlertDescription>
          </Alert>
        )}

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Campaign Status</p>
                  <Badge variant={statusConfig.variant} className="mt-2">
                    {statusConfig.label}
                  </Badge>
                </div>
                <div className={`p-3 rounded-full ${statusConfig.bg}`}>
                  <StatusIcon className={`h-6 w-6 ${statusConfig.color}`} />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Phone Number</p>
                  <p className="text-lg font-semibold mt-1">
                    {organization.twilioPhoneNumber || 'Not Assigned'}
                  </p>
                </div>
                <div className="p-3 rounded-full bg-blue-100">
                  <Phone className="h-6 w-6 text-blue-600" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">SMS Enabled</p>
                  <p className="text-lg font-semibold mt-1">
                    {organization.smsEnabled ? '✅ Yes' : '❌ No'}
                  </p>
                </div>
                <div className="p-3 rounded-full bg-purple-100">
                  <MessageSquare className="h-6 w-6 text-purple-600" />
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Campaign Details</CardTitle>
            <CardDescription>Twilio A2P 10DLC campaign information</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <p className="text-sm font-medium text-muted-foreground">Campaign SID</p>
                <p className="text-sm font-mono mt-1">
                  {organization.twilioCampaignSid || 'Not created'}
                </p>
              </div>
              <div>
                <p className="text-sm font-medium text-muted-foreground">Use Case</p>
                <p className="text-sm mt-1">
                  {organization.campaignUseCase || 'CUSTOMER_CARE'}
                </p>
              </div>
              <div>
                <p className="text-sm font-medium text-muted-foreground">Registered At</p>
                <p className="text-sm mt-1">
                  {organization.campaignRegisteredAt
                    ? new Date(organization.campaignRegisteredAt).toLocaleString()
                    : 'Not registered'}
                </p>
              </div>
              <div>
                <p className="text-sm font-medium text-muted-foreground">Approved At</p>
                <p className="text-sm mt-1">
                  {organization.campaignApprovedAt
                    ? new Date(organization.campaignApprovedAt).toLocaleString()
                    : 'Pending approval'}
                </p>
              </div>
            </div>

            {organization.campaignRejectionReason && (
              <Alert variant="destructive" className="mt-4">
                <AlertDescription>
                  <strong>Rejection:</strong> {organization.campaignRejectionReason}
                </AlertDescription>
              </Alert>
            )}
          </CardContent>
        </Card>

        {limits && (
          <Card className="mb-6">
            <CardHeader>
              <CardTitle>Daily SMS Limits</CardTitle>
              <CardDescription>Track your daily usage</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-sm font-medium">Daily Usage</span>
                    <span className="text-sm text-muted-foreground">
                      {limits.dailyUsed} / {limits.dailyLimit} messages
                    </span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2.5">
                    <div
                      className={`h-2.5 rounded-full ${
                        limits.percentUsed >= 90
                          ? 'bg-red-600'
                          : limits.percentUsed >= 70
                          ? 'bg-yellow-600'
                          : 'bg-green-600'
                      }`}
                      style={{ width: `${Math.min(limits.percentUsed, 100)}%` }}
                    ></div>
                  </div>
                  <p className="text-xs text-muted-foreground mt-1">
                    {limits.remaining} messages remaining today
                  </p>
                </div>

                <div className="grid grid-cols-2 gap-4 pt-4 border-t">
                  <div>
                    <p className="text-sm text-muted-foreground">Total SMS Sent</p>
                    <p className="text-2xl font-bold">
                      {organization.smsCreditsUsed?.toLocaleString() || 0}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Resets At</p>
                    <p className="text-sm font-medium">
                      Midnight {organization.timezone || 'America/Chicago'}
                    </p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        <Card>
          <CardHeader>
            <CardTitle>Quick Actions</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              {!organization.communicationSetup && (
                <Button
                  onClick={handleSetupCommunication}
                  disabled={loading}
                  className="w-full"
                >
                  <Zap className="h-4 w-4 mr-2" />
                  Setup Communication
                </Button>
              )}

              {organization.twilioCampaignSid && (
                <Button
                  onClick={handleCheckStatus}
                  disabled={loading}
                  variant="outline"
                  className="w-full"
                >
                  <RefreshCw className="h-4 w-4 mr-2" />
                  Check Status
                </Button>
              )}

              {organization.campaignStatus === 'APPROVED' && (
                <Button
                  onClick={handleGetLimits}
                  disabled={loading}
                  variant="outline"
                  className="w-full"
                >
                  <MessageSquare className="h-4 w-4 mr-2" />
                  View Limits
                </Button>
              )}

              <Button
                onClick={() => refetch()}
                variant="ghost"
                className="w-full"
              >
                <RefreshCw className="h-4 w-4 mr-2" />
                Refresh
              </Button>
            </div>
          </CardContent>
        </Card>

        {organization.campaignStatus === 'PENDING' && (
          <Alert className="mt-6">
            <Clock className="h-4 w-4" />
            <AlertDescription>
              <strong>Pending:</strong> Campaign awaiting carrier approval (1-3 days).
              SMS will be enabled automatically once approved.
            </AlertDescription>
          </Alert>
        )}

        {organization.campaignStatus === 'NOT_REGISTERED' && (
          <Alert className="mt-6">
            <AlertTriangle className="h-4 w-4" />
            <AlertDescription>
              <strong>Setup Required:</strong> Click "Setup Communication" to:
              <ol className="list-decimal ml-6 mt-2 space-y-1">
                <li>Get assigned a phone number ($1.15/month)</li>
                <li>Register A2P 10DLC campaign ($10/month)</li>
                <li>Wait for carrier approval (1-3 days)</li>
                <li>Start sending SMS!</li>
              </ol>
            </AlertDescription>
          </Alert>
        )}
      </div>
    </div>
  );
}
