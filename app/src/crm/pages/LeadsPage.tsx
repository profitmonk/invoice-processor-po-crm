// src/crm/pages/LeadsPage.tsx

import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery, getLeads, updateLeadStatus, deleteLead, getProperties } from 'wasp/client/operations';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { Badge } from '../../components/ui/badge';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '../../components/ui/select';
import {
  UserPlus,
  Search,
  Plus,
  Phone,
  Mail,
  Building2,
  DollarSign,
  Calendar,
  Flame,
  TrendingUp,
  Snowflake,
  Eye,
  Trash2,
  MessageSquare,
} from 'lucide-react';
import { Alert, AlertDescription } from '../../components/ui/alert';

const LEAD_STATUSES = [
  { value: 'NEW', label: 'New', color: 'bg-blue-50 border-blue-200' },
  { value: 'CONTACTED', label: 'Contacted', color: 'bg-purple-50 border-purple-200' },
  { value: 'TOURING_SCHEDULED', label: 'Tour Scheduled', color: 'bg-yellow-50 border-yellow-200' },
  { value: 'TOURED', label: 'Toured', color: 'bg-orange-50 border-orange-200' },
  { value: 'APPLIED', label: 'Applied', color: 'bg-indigo-50 border-indigo-200' },
  { value: 'APPROVED', label: 'Approved', color: 'bg-green-50 border-green-200' },
  { value: 'CONVERTED', label: 'Converted', color: 'bg-emerald-50 border-emerald-200' },
  { value: 'LOST', label: 'Lost', color: 'bg-gray-50 border-gray-200' },
];

const PRIORITY_ICONS: Record<string, any> = {
  HOT: { icon: Flame, color: 'text-red-600', label: '🔥 Hot' },
  WARM: { icon: TrendingUp, color: 'text-orange-600', label: '↗️ Warm' },
  COLD: { icon: Snowflake, color: 'text-blue-600', label: '❄️ Cold' },
};

export default function LeadsPage() {
  const navigate = useNavigate();
  const [searchTerm, setSearchTerm] = useState('');
  const [propertyFilter, setPropertyFilter] = useState<string>('ALL');
  const [priorityFilter, setPriorityFilter] = useState<string>('ALL');
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [draggedLeadId, setDraggedLeadId] = useState<string | null>(null);

  const { data: leads, isLoading, refetch } = useQuery(getLeads, {
    propertyId: propertyFilter === 'ALL' ? undefined : propertyFilter,
    priority: priorityFilter === 'ALL' ? undefined : priorityFilter,
    searchTerm: searchTerm || undefined,
  });

  const { data: properties } = useQuery(getProperties);

  const handleStatusChange = async (leadId: string, newStatus: string) => {
    try {
      await updateLeadStatus({ id: leadId, status: newStatus });
      refetch();
      setMessage({ type: 'success', text: 'Lead status updated' });
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to update status' });
    }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!confirm(`Are you sure you want to delete lead ${name}?`)) {
      return;
    }

    try {
      await deleteLead({ id });
      setMessage({ type: 'success', text: 'Lead deleted successfully' });
      refetch();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Failed to delete lead' });
    }
  };

  const handleDragStart = (leadId: string) => {
    setDraggedLeadId(leadId);
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
  };

  const handleDrop = async (e: React.DragEvent, newStatus: string) => {
    e.preventDefault();
    if (draggedLeadId) {
      await handleStatusChange(draggedLeadId, newStatus);
      setDraggedLeadId(null);
    }
  };

  const getLeadsByStatus = (status: string) => {
    return leads?.filter((lead: any) => lead.status === status) || [];
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(amount);
  };

  const getPriorityIcon = (priority: string) => {
    const config = PRIORITY_ICONS[priority];
    if (!config) return null;
    const Icon = config.icon;
    return <Icon className={`h-4 w-4 ${config.color}`} />;
  };

  return (
    <div className="py-10 lg:mt-10">
      <div className="mx-auto max-w-[1600px] px-6 lg:px-8">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Leads Pipeline</h1>
            <p className="text-muted-foreground mt-2">
              Manage and track your prospective residents
            </p>
          </div>
          <Button onClick={() => navigate('/crm/leads/new')}>
            <Plus className="h-4 w-4 mr-2" />
            Add Lead
          </Button>
        </div>

        {message && (
          <Alert variant={message.type === 'error' ? 'destructive' : 'default'} className="mb-6">
            <AlertDescription>{message.text}</AlertDescription>
          </Alert>
        )}

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Total Leads</p>
                  <p className="text-2xl font-bold">{leads?.length || 0}</p>
                </div>
                <UserPlus className="h-8 w-8 text-primary" />
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Hot Leads</p>
                  <p className="text-2xl font-bold">
                    {leads?.filter((l: any) => l.priority === 'HOT').length || 0}
                  </p>
                </div>
                <Flame className="h-8 w-8 text-red-600" />
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Tours Scheduled</p>
                  <p className="text-2xl font-bold">
                    {leads?.filter((l: any) => l.status === 'TOURING_SCHEDULED').length || 0}
                  </p>
                </div>
                <Calendar className="h-8 w-8 text-yellow-600" />
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Converted</p>
                  <p className="text-2xl font-bold">
                    {leads?.filter((l: any) => l.status === 'CONVERTED').length || 0}
                  </p>
                </div>
                <TrendingUp className="h-8 w-8 text-green-600" />
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Filters */}
        <Card className="mb-6">
          <CardContent className="pt-6">
            <div className="flex gap-3 flex-wrap">
              <div className="relative flex-1 min-w-64">
                <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search leads..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-8"
                />
              </div>
              <Select value={propertyFilter} onValueChange={setPropertyFilter}>
                <SelectTrigger className="w-48">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="ALL">All Properties</SelectItem>
                  {properties?.map((prop: any) => (
                    <SelectItem key={prop.id} value={prop.id}>
                      {prop.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <Select value={priorityFilter} onValueChange={setPriorityFilter}>
                <SelectTrigger className="w-40">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="ALL">All Priority</SelectItem>
                  <SelectItem value="HOT">🔥 Hot</SelectItem>
                  <SelectItem value="WARM">↗️ Warm</SelectItem>
                  <SelectItem value="COLD">❄️ Cold</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardContent>
        </Card>

        {/* Kanban Board */}
        {isLoading ? (
          <p className="text-center py-8 text-muted-foreground">Loading leads...</p>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-4 xl:grid-cols-8 gap-4">
            {LEAD_STATUSES.map((status) => {
              const statusLeads = getLeadsByStatus(status.value);
              return (
                <div
                  key={status.value}
                  className="min-w-80"
                  onDragOver={handleDragOver}
                  onDrop={(e) => handleDrop(e, status.value)}
                >
                  <Card className={`${status.color} border-2`}>
                    <CardHeader className="pb-3">
                      <CardTitle className="text-sm font-semibold flex items-center justify-between">
                        <span>{status.label}</span>
                        <Badge variant="secondary">{statusLeads.length}</Badge>
                      </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-3 max-h-[600px] overflow-y-auto">
                      {statusLeads.length > 0 ? (
                        statusLeads.map((lead: any) => (
                          <Card
                            key={lead.id}
                            draggable
                            onDragStart={() => handleDragStart(lead.id)}
                            className="cursor-move hover:shadow-md transition-shadow bg-white"
                          >
                            <CardContent className="p-4 space-y-3">
                              <div className="flex items-start justify-between gap-2">
                                <div className="flex-1">
                                  <div className="flex items-center gap-2 mb-1">
                                    <h4 className="font-semibold text-sm">
                                      {lead.firstName} {lead.lastName}
                                    </h4>
                                    {getPriorityIcon(lead.priority)}
                                  </div>
                                  {lead.interestedProperty && (
                                    <div className="flex items-center gap-1 text-xs text-muted-foreground">
                                      <Building2 className="h-3 w-3" />
                                      <span className="truncate">{lead.interestedProperty.name}</span>
                                    </div>
                                  )}
                                </div>
                              </div>

                              <div className="space-y-1.5 text-xs">
                                {lead.email && (
                                  <div className="flex items-center gap-1 text-muted-foreground">
                                    <Mail className="h-3 w-3" />
                                    <span className="truncate">{lead.email}</span>
                                  </div>
                                )}
                                <div className="flex items-center gap-1 text-muted-foreground">
                                  <Phone className="h-3 w-3" />
                                  <span>{lead.phoneNumber}</span>
                                </div>
                                {(lead.budgetMin || lead.budgetMax) && (
                                  <div className="flex items-center gap-1 text-muted-foreground">
                                    <DollarSign className="h-3 w-3" />
                                    <span>
                                      {lead.budgetMin && formatCurrency(lead.budgetMin)}
                                      {lead.budgetMin && lead.budgetMax && ' - '}
                                      {lead.budgetMax && formatCurrency(lead.budgetMax)}
                                    </span>
                                  </div>
                                )}
                                {lead.desiredBedrooms && (
                                  <div className="text-muted-foreground">
                                    🛏️ {lead.desiredBedrooms} bed{lead.desiredBedrooms > 1 ? 's' : ''}
                                  </div>
                                )}
                                {lead.assignedManager && (
                                  <div className="text-xs text-blue-600">
                                    👤 {lead.assignedManager.username || lead.assignedManager.email}
                                  </div>
                                )}
                              </div>

                              <div className="flex items-center justify-between pt-2 border-t">
                                <div className="flex gap-1">
                                  <Button
                                    size="sm"
                                    variant="ghost"
                                    className="h-7 px-2"
                                    onClick={() => navigate(`/crm/leads/${lead.id}`)}
                                  >
                                    <Eye className="h-3 w-3" />
                                  </Button>
                                  <Button
                                    size="sm"
                                    variant="ghost"
                                    className="h-7 px-2"
                                    onClick={() => navigate('/crm/communications', { state: { leadId: lead.id } })}
                                  >
                                    <MessageSquare className="h-3 w-3" />
                                  </Button>
                                </div>
                                <Button
                                  size="sm"
                                  variant="ghost"
                                  className="h-7 px-2"
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    handleDelete(lead.id, `${lead.firstName} ${lead.lastName}`);
                                  }}
                                >
                                  <Trash2 className="h-3 w-3 text-destructive" />
                                </Button>
                              </div>

                              {lead._count?.conversations > 0 && (
                                <div className="text-xs text-muted-foreground pt-1">
                                  💬 {lead._count.conversations} message{lead._count.conversations !== 1 ? 's' : ''}
                                </div>
                              )}
                            </CardContent>
                          </Card>
                        ))
                      ) : (
                        <div className="text-center py-8 text-sm text-muted-foreground">
                          No leads
                        </div>
                      )}
                    </CardContent>
                  </Card>
                </div>
              );
            })}
          </div>
        )}

        {!isLoading && (!leads || leads.length === 0) && (
          <Card className="mt-6">
            <CardContent className="py-12 text-center">
              <UserPlus className="mx-auto h-12 w-12 text-muted-foreground" />
              <h3 className="mt-4 text-lg font-semibold">No leads yet</h3>
              <p className="text-muted-foreground mt-2">
                Get started by adding your first lead
              </p>
              <Button className="mt-4" onClick={() => navigate('/crm/leads/new')}>
                <Plus className="h-4 w-4 mr-2" />
                Add Lead
              </Button>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
}
