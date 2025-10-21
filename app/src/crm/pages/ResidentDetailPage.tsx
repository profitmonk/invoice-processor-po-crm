// src/crm/pages/ResidentDetailPage.tsx

import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, getResidentById, deleteResident } from 'wasp/client/operations';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Badge } from '../../components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../../components/ui/tabs';
import {
  User as UserIcon,
  Phone,
  Mail,
  Building2,
  Calendar,
  DollarSign,
  AlertCircle,
  MessageSquare,
  Wrench,
  Edit,
  Trash2,
  ArrowLeft,
  FileText,
} from 'lucide-react';
import { Alert, AlertDescription } from '../../components/ui/alert';

const STATUS_COLORS: Record<string, any> = {
  ACTIVE: 'default',
  NOTICE_GIVEN: 'secondary',
  PAST_RESIDENT: 'outline',
};

const MAINTENANCE_STATUS_COLORS: Record<string, any> = {
  SUBMITTED: 'default',
  ASSIGNED: 'secondary',
  IN_PROGRESS: 'default',
  COMPLETED: 'default',
  CLOSED: 'outline',
};

const MAINTENANCE_PRIORITY_COLORS: Record<string, any> = {
  LOW: 'outline',
  MEDIUM: 'default',
  HIGH: 'secondary',
  EMERGENCY: 'destructive',
};

export default function ResidentDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const { data: resident, isLoading, refetch } = useQuery(getResidentById, { id: id! });

  const handleDelete = async () => {
    if (!resident) return;
    
    if (!confirm(`Are you sure you want to delete ${resident.firstName} ${resident.lastName}?`)) {
      return;
    }

    try {
      await deleteResident({ id: resident.id });
      setMessage({ type: 'success', text: 'Resident deleted successfully' });
      setTimeout(() => navigate('/crm/residents'), 1500);
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to delete resident' });
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  const getDaysUntilLeaseEnd = () => {
    if (!resident) return 0;
    const today = new Date();
    const endDate = new Date(resident.leaseEndDate);
    const diffTime = endDate.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  };

  const getLeaseStatus = () => {
    const daysUntil = getDaysUntilLeaseEnd();
    if (daysUntil < 0) {
      return { text: 'Expired', variant: 'destructive' as const };
    } else if (daysUntil <= 30) {
      return { text: `Expires in ${daysUntil} days`, variant: 'secondary' as const };
    } else if (daysUntil <= 60) {
      return { text: `Expires in ${daysUntil} days`, variant: 'outline' as const };
    }
    return { text: `${daysUntil} days remaining`, variant: 'default' as const };
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p>Loading resident details...</p>
      </div>
    );
  }

  if (!resident) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Card className="w-96">
          <CardHeader>
            <CardTitle>Resident Not Found</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground">
              The resident you're looking for doesn't exist or you don't have access.
            </p>
            <Button className="mt-4" onClick={() => navigate('/crm/residents')}>
              Back to Residents
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  const leaseStatus = getLeaseStatus();

  return (
    <div className="py-10 lg:mt-10">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center gap-4">
            <Button variant="ghost" onClick={() => navigate('/crm/residents')}>
              <ArrowLeft className="h-4 w-4 mr-2" />
              Back
            </Button>
            <div>
              <h1 className="text-3xl font-bold tracking-tight">
                {resident.firstName} {resident.lastName}
              </h1>
              <p className="text-muted-foreground mt-1">
                {resident.property.name} - Unit {resident.unitNumber}
              </p>
            </div>
          </div>
          <div className="flex gap-3">
            <Button variant="outline" onClick={() => navigate(`/crm/residents/${id}/edit`)}>
              <Edit className="h-4 w-4 mr-2" />
              Edit
            </Button>
            <Button variant="destructive" onClick={handleDelete}>
              <Trash2 className="h-4 w-4 mr-2" />
              Delete
            </Button>
          </div>
        </div>

        {message && (
          <Alert variant={message.type === 'error' ? 'destructive' : 'default'} className="mb-6">
            <AlertDescription>{message.text}</AlertDescription>
          </Alert>
        )}

        {/* Overview Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Status</p>
                  <Badge variant={STATUS_COLORS[resident.status]} className="mt-2">
                    {resident.status.replace('_', ' ')}
                  </Badge>
                </div>
                <UserIcon className="h-8 w-8 text-primary" />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Monthly Rent</p>
                  <p className="text-xl font-bold mt-1">
                    {formatCurrency(resident.monthlyRentAmount)}
                  </p>
                </div>
                <DollarSign className="h-8 w-8 text-green-600" />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Lease Status</p>
                  <Badge variant={leaseStatus.variant} className="mt-2">
                    {leaseStatus.text}
                  </Badge>
                </div>
                <Calendar className="h-8 w-8 text-orange-600" />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Open Requests</p>
                  <p className="text-xl font-bold mt-1">
                    {resident.maintenanceRequests?.filter(
                      (req: any) => !['COMPLETED', 'CLOSED'].includes(req.status)
                    ).length || 0}
                  </p>
                </div>
                <Wrench className="h-8 w-8 text-blue-600" />
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Tabs */}
        <Tabs defaultValue="details" className="space-y-6">
          <TabsList>
            <TabsTrigger value="details">Details</TabsTrigger>
            <TabsTrigger value="lease">Lease Information</TabsTrigger>
            <TabsTrigger value="maintenance">
              Maintenance ({resident.maintenanceRequests?.length || 0})
            </TabsTrigger>
            <TabsTrigger value="communications">
              Communications ({resident.conversations?.length || 0})
            </TabsTrigger>
          </TabsList>

          {/* Details Tab */}
          <TabsContent value="details">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle>Contact Information</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex items-start gap-3">
                    <Mail className="h-5 w-5 text-muted-foreground mt-0.5" />
                    <div>
                      <p className="text-sm text-muted-foreground">Email</p>
                      <p className="font-medium">{resident.email}</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-3">
                    <Phone className="h-5 w-5 text-muted-foreground mt-0.5" />
                    <div>
                      <p className="text-sm text-muted-foreground">Phone Number</p>
                      <p className="font-medium">{resident.phoneNumber}</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-3">
                    <Building2 className="h-5 w-5 text-muted-foreground mt-0.5" />
                    <div>
                      <p className="text-sm text-muted-foreground">Unit Address</p>
                      <p className="font-medium">{resident.property.name}</p>
                      <p className="text-sm text-muted-foreground">Unit {resident.unitNumber}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Emergency Contact</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  {resident.emergencyContactName ? (
                    <>
                      <div>
                        <p className="text-sm text-muted-foreground">Name</p>
                        <p className="font-medium">{resident.emergencyContactName}</p>
                      </div>
                      <div>
                        <p className="text-sm text-muted-foreground">Phone</p>
                        <p className="font-medium">{resident.emergencyContactPhone}</p>
                      </div>
                      <div>
                        <p className="text-sm text-muted-foreground">Relationship</p>
                        <p className="font-medium">{resident.emergencyContactRelationship}</p>
                      </div>
                    </>
                  ) : (
                    <p className="text-muted-foreground">No emergency contact on file</p>
                  )}
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          {/* Lease Tab */}
          <TabsContent value="lease">
            <Card>
              <CardHeader>
                <CardTitle>Lease Details</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <p className="text-sm text-muted-foreground">Lease Type</p>
                    <p className="font-medium mt-1">
                      {resident.leaseType.replace('_', ' ')}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Monthly Rent</p>
                    <p className="font-medium mt-1">
                      {formatCurrency(resident.monthlyRentAmount)}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Rent Due Day</p>
                    <p className="font-medium mt-1">
                      {resident.rentDueDay}{' '}
                      {resident.rentDueDay === 1 ? 'st' : resident.rentDueDay === 2 ? 'nd' : resident.rentDueDay === 3 ? 'rd' : 'th'} of each month
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Move-in Date</p>
                    <p className="font-medium mt-1">{formatDate(resident.moveInDate)}</p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Lease Start Date</p>
                    <p className="font-medium mt-1">{formatDate(resident.leaseStartDate)}</p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Lease End Date</p>
                    <p className="font-medium mt-1">{formatDate(resident.leaseEndDate)}</p>
                    <Badge variant={leaseStatus.variant} className="mt-2">
                      {leaseStatus.text}
                    </Badge>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Maintenance Tab */}
          <TabsContent value="maintenance">
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <h3 className="text-lg font-semibold">Maintenance Requests</h3>
                <Button onClick={() => navigate('/crm/maintenance/new', { state: { residentId: resident.id } })}>
                  <Wrench className="h-4 w-4 mr-2" />
                  New Request
                </Button>
              </div>

              {resident.maintenanceRequests && resident.maintenanceRequests.length > 0 ? (
                <div className="space-y-3">
                  {resident.maintenanceRequests.map((request: any) => (
                    <Card
                      key={request.id}
                      className="cursor-pointer hover:bg-muted/50"
                      onClick={() => navigate(`/crm/maintenance/${request.id}`)}
                    >
                      <CardContent className="p-4">
                        <div className="flex items-start justify-between">
                          <div className="space-y-2 flex-1">
                            <div className="flex items-center gap-2">
                              <h4 className="font-semibold">{request.title}</h4>
                              <Badge variant={MAINTENANCE_PRIORITY_COLORS[request.priority]}>
                                {request.priority}
                              </Badge>
                              <Badge variant={MAINTENANCE_STATUS_COLORS[request.status]}>
                                {request.status.replace('_', ' ')}
                              </Badge>
                            </div>
                            <p className="text-sm text-muted-foreground line-clamp-2">
                              {request.description}
                            </p>
                            <p className="text-xs text-muted-foreground">
                              {request.requestType.replace('_', ' ')} • {formatDate(request.createdAt)}
                            </p>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              ) : (
                <Card>
                  <CardContent className="py-12 text-center">
                    <Wrench className="mx-auto h-12 w-12 text-muted-foreground" />
                    <h3 className="mt-4 text-lg font-semibold">No maintenance requests</h3>
                    <p className="text-muted-foreground mt-2">
                      This resident hasn't submitted any maintenance requests yet.
                    </p>
                  </CardContent>
                </Card>
              )}
            </div>
          </TabsContent>

          {/* Communications Tab */}
          <TabsContent value="communications">
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <h3 className="text-lg font-semibold">Message History</h3>
                <Button onClick={() => navigate('/crm/communications', { state: { residentId: resident.id } })}>
                  <MessageSquare className="h-4 w-4 mr-2" />
                  Send Message
                </Button>
              </div>

              {resident.conversations && resident.conversations.length > 0 ? (
                <Card>
                  <CardContent className="p-4">
                    <div className="space-y-4">
                      {resident.conversations.map((conv: any) => (
                        <div
                          key={conv.id}
                          className={`flex gap-3 ${
                            conv.senderType === 'RESIDENT' ? 'flex-row' : 'flex-row-reverse'
                          }`}
                        >
                          <div
                            className={`rounded-lg p-3 max-w-[70%] ${
                              conv.senderType === 'RESIDENT'
                                ? 'bg-muted'
                                : 'bg-primary text-primary-foreground'
                            }`}
                          >
                            <p className="text-sm">{conv.messageContent}</p>
                            <div className="flex items-center gap-2 mt-2">
                              <p className="text-xs opacity-70">
                                {new Date(conv.sentAt).toLocaleString()}
                              </p>
                              {conv.aiGenerated && (
                                <Badge variant="outline" className="text-xs">
                                  🤖 AI
                                </Badge>
                              )}
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              ) : (
                <Card>
                  <CardContent className="py-12 text-center">
                    <MessageSquare className="mx-auto h-12 w-12 text-muted-foreground" />
                    <h3 className="mt-4 text-lg font-semibold">No messages yet</h3>
                    <p className="text-muted-foreground mt-2">
                      Start a conversation with this resident.
                    </p>
                  </CardContent>
                </Card>
              )}
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}
