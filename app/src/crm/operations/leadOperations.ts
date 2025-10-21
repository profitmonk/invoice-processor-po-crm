// app/src/crm/operations/leadOperations.ts

import { HttpError } from 'wasp/server';
import type {
  GetLeads,
  GetLeadById,
  CreateLead,
  UpdateLead,
  UpdateLeadStatus,
  AssignLeadToManager,
  ConvertLeadToResident,
  DeleteLead,
} from 'wasp/server/operations';

export const getLeads: GetLeads
  {
    status?: string;
    propertyId?: string;
    assignedManagerId?: string;
    priority?: string;
    searchTerm?: string;
  },
  any
> = async (args, context) => {
  if (!context.user) {
    throw new HttpError(401, 'User not authenticated');
  }

  const user = await context.entities.User.findUnique({
    where: { id: context.user.id },
    include: { organization: true },
  });

  if (!user || !user.organizationId) {
    throw new HttpError(403, 'User must belong to an organization');
  }

  const whereClause: any = {
    organizationId: user.organizationId,
  };

  if (user.role === 'PROPERTY_MANAGER') {
    whereClause.assignedManagerId = user.id;
  }

  if (args.status) {
    whereClause.status = args.status;
  }

  if (args.propertyId) {
    whereClause.interestedPropertyId = args.propertyId;
  }

  if (args.assignedManagerId) {
    whereClause.assignedManagerId = args.assignedManagerId;
  }

  if (args.priority) {
    whereClause.priority = args.priority;
  }

  if (args.searchTerm) {
    whereClause.OR = [
      { firstName: { contains: args.searchTerm, mode: 'insensitive' } },
      { lastName: { contains: args.searchTerm, mode: 'insensitive' } },
      { email: { contains: args.searchTerm, mode: 'insensitive' } },
      { phoneNumber: { contains: args.searchTerm } },
    ];
  }

  const leads = await context.entities.Lead.findMany({
    where: whereClause,
    include: {
      interestedProperty: true,
      assignedManager: {
        select: {
          id: true,
          username: true,
          email: true,
        },
      },
      _count: {
        select: {
          conversations: true,
        },
      },
    },
    orderBy: [
      { priority: 'asc' },
      { createdAt: 'desc' },
    ],
  });

  return leads;
};

export const getLeadById: GetLeadById<{ id: string }, any> = async (
  args,
  context
) => {
  if (!context.user) {
    throw new HttpError(401, 'User not authenticated');
  }

  const user = await context.entities.User.findUnique({
    where: { id: context.user.id },
    include: { organization: true },
  });

  if (!user || !user.organizationId) {
    throw new HttpError(403, 'User must belong to an organization');
  }

  const lead = await context.entities.Lead.findUnique({
    where: { id: args.id },
    include: {
      interestedProperty: true,
      assignedManager: {
        select: {
          id: true,
          username: true,
          email: true,
        },
      },
      conversations: {
        include: {
          sender: {
            select: {
              id: true,
              username: true,
              email: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
        take: 50,
      },
    },
  });

  if (!lead) {
    throw new HttpError(404, 'Lead not found');
  }

  if (lead.organizationId !== user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  if (user.role === 'PROPERTY_MANAGER' && lead.assignedManagerId !== user.id) {
    throw new HttpError(403, 'Access denied');
  }

  return lead;
};

export const createLead: CreateLead
  {
    firstName: string;
    lastName: string;
    email?: string;
    phoneNumber: string;
    leadSource?: string;
    priority?: string;
    interestedPropertyId?: string;
    desiredBedrooms?: number;
    budgetMin?: number;
    budgetMax?: number;
    desiredMoveInDate?: string;
    assignedManagerId?: string;
    notes?: string;
  },
  any
> = async (args, context) => {
  if (!context.user) {
    throw new HttpError(401, 'User not authenticated');
  }

  const user = await context.entities.User.findUnique({
    where: { id: context.user.id },
    include: { organization: true },
  });

  if (!user || !user.organizationId) {
    throw new HttpError(403, 'User must belong to an organization');
  }

  const existingLead = await context.entities.Lead.findUnique({
    where: {
      organizationId_phoneNumber: {
        organizationId: user.organizationId,
        phoneNumber: args.phoneNumber,
      },
    },
  });

  if (existingLead) {
    throw new HttpError(400, 'A lead with this phone number already exists');
  }

  if (args.interestedPropertyId) {
    const property = await context.entities.Property.findUnique({
      where: { id: args.interestedPropertyId },
    });

    if (!property || property.organizationId !== user.organizationId) {
      throw new HttpError(403, 'Invalid property');
    }
  }

  if (args.assignedManagerId) {
    const manager = await context.entities.User.findUnique({
      where: { id: args.assignedManagerId },
    });

    if (!manager || manager.organizationId !== user.organizationId) {
      throw new HttpError(403, 'Invalid manager');
    }
  }

  const lead = await context.entities.Lead.create({
    data: {
      firstName: args.firstName,
      lastName: args.lastName,
      email: args.email,
      phoneNumber: args.phoneNumber,
      leadSource: args.leadSource || 'OTHER',
      priority: args.priority || 'WARM',
      status: 'NEW',
      interestedPropertyId: args.interestedPropertyId,
      desiredBedrooms: args.desiredBedrooms,
      budgetMin: args.budgetMin,
      budgetMax: args.budgetMax,
      desiredMoveInDate: args.desiredMoveInDate ? new Date(args.desiredMoveInDate) : null,
      assignedManagerId: args.assignedManagerId,
      notes: args.notes,
      organizationId: user.organizationId,
    },
    include: {
      interestedProperty: true,
      assignedManager: {
        select: {
          id: true,
          username: true,
          email: true,
        },
      },
    },
  });

  return lead;
};

export const updateLead: UpdateLead
  {
    id: string;
    firstName?: string;
    lastName?: string;
    email?: string;
    phoneNumber?: string;
    leadSource?: string;
    priority?: string;
    interestedPropertyId?: string;
    desiredBedrooms?: number;
    budgetMin?: number;
    budgetMax?: number;
    desiredMoveInDate?: string;
    notes?: string;
  },
  any
> = async (args, context) => {
  if (!context.user) {
    throw new HttpError(401, 'User not authenticated');
  }

  const user = await context.entities.User.findUnique({
    where: { id: context.user.id },
  });

  if (!user || !user.organizationId) {
    throw new HttpError(403, 'User must belong to an organization');
  }

  const lead = await context.entities.Lead.findUnique({
    where: { id: args.id },
  });

  if (!lead) {
    throw new HttpError(404, 'Lead not found');
  }

  if (lead.organizationId !== user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  const { id, ...updateData } = args;

  const processedData: any = { ...updateData };
  if (updateData.desiredMoveInDate) {
    processedData.desiredMoveInDate = new Date(updateData.desiredMoveInDate);
  }

  const updatedLead = await context.entities.Lead.update({
    where: { id },
    data: processedData,
    include: {
      interestedProperty: true,
      assignedManager: {
        select: {
          id: true,
          username: true,
          email: true,
        },
      },
    },
  });

  return updatedLead;
};

export const updateLeadStatus: UpdateLeadStatus
  {
    id: string;
    status: string;
    notes?: string;
  },
  any
> = async (args, context) => {
  if (!context.user) {
    throw new HttpError(401, 'User not authenticated');
  }

  const lead = await context.entities.Lead.findUnique({
    where: { id: args.id },
  });

  if (!lead) {
    throw new HttpError(404, 'Lead not found');
  }

  const user = await context.entities.User.findUnique({
    where: { id: context.user.id },
  });

  if (!user || lead.organizationId !== user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  const updatedNotes = args.notes
    ? `${lead.notes || ''}\n\n[${new Date().toLocaleString()}] Status changed to ${args.status}: ${args.notes}`
    : lead.notes;

  const updatedLead = await context.entities.Lead.update({
    where: { id: args.id },
    data: {
      status: args.status,
      notes: updatedNotes,
    },
    include: {
      interestedProperty: true,
      assignedManager: {
        select: {
          id: true,
          username: true,
          email: true,
        },
      },
    },
  });

  await context.entities.Conversation.create({
    data: {
      leadId: lead.id,
      messageContent: `Lead status changed to ${args.status}${args.notes ? `: ${args.notes}` : ''}`,
      messageType: 'IN_APP',
      senderType: 'SYSTEM',
      senderId: context.user.id,
      status: 'SENT',
      organizationId: lead.organizationId,
    },
  });

  return updatedLead;
};

export const assignLeadToManager: AssignLeadToManager
  {
    leadId: string;
    managerId: string;
  },
  any
> = async (args, context) => {
  if (!context.user) {
    throw new HttpError(401, 'User not authenticated');
  }

  const user = await context.entities.User.findUnique({
    where: { id: context.user.id },
  });

  if (!user || !user.organizationId) {
    throw new HttpError(403, 'User must belong to an organization');
  }

  const lead = await context.entities.Lead.findUnique({
    where: { id: args.leadId },
  });

  if (!lead) {
    throw new HttpError(404, 'Lead not found');
  }

  if (lead.organizationId !== user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  const manager = await context.entities.User.findUnique({
    where: { id: args.managerId },
  });

  if (!manager || manager.organizationId !== user.organizationId) {
    throw new HttpError(403, 'Invalid manager');
  }

  const updatedLead = await context.entities.Lead.update({
    where: { id: args.leadId },
    data: {
      assignedManagerId: args.managerId,
    },
    include: {
      interestedProperty: true,
      assignedManager: {
        select: {
          id: true,
          username: true,
          email: true,
        },
      },
    },
  });

  return updatedLead;
};

export const convertLeadToResident: ConvertLeadToResident
  {
    leadId: string;
    propertyId: string;
    unitNumber: string;
    moveInDate: string;
    monthlyRentAmount: number;
    leaseStartDate: string;
    leaseEndDate: string;
    leaseType?: string;
  },
  any
> = async (args, context) => {
  if (!context.user) {
    throw new HttpError(401, 'User not authenticated');
  }

  const user = await context.entities.User.findUnique({
    where: { id: context.user.id },
  });

  if (!user || !user.organizationId) {
    throw new HttpError(403, 'User must belong to an organization');
  }

  const lead = await context.entities.Lead.findUnique({
    where: { id: args.leadId },
  });

  if (!lead) {
    throw new HttpError(404, 'Lead not found');
  }

  if (lead.organizationId !== user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  if (lead.convertedToResidentId) {
    throw new HttpError(400, 'Lead has already been converted');
  }

  const property = await context.entities.Property.findUnique({
    where: { id: args.propertyId },
  });

  if (!property || property.organizationId !== user.organizationId) {
    throw new HttpError(403, 'Invalid property');
  }

  const existingResident = await context.entities.Resident.findUnique({
    where: {
      organizationId_phoneNumber: {
        organizationId: user.organizationId,
        phoneNumber: lead.phoneNumber,
      },
    },
  });

  if (existingResident) {
    throw new HttpError(400, 'A resident with this phone number already exists');
  }

  const resident = await context.entities.Resident.create({
    data: {
      firstName: lead.firstName,
      lastName: lead.lastName,
      email: lead.email || '',
      phoneNumber: lead.phoneNumber,
      propertyId: args.propertyId,
      unitNumber: args.unitNumber,
      moveInDate: new Date(args.moveInDate),
      monthlyRentAmount: args.monthlyRentAmount,
      leaseStartDate: new Date(args.leaseStartDate),
      leaseEndDate: new Date(args.leaseEndDate),
      leaseType: args.leaseType || 'ONE_YEAR',
      status: 'ACTIVE',
      organizationId: user.organizationId,
    },
  });

  await context.entities.Lead.update({
    where: { id: args.leadId },
    data: {
      status: 'CONVERTED',
      convertedToResidentId: resident.id,
      convertedAt: new Date(),
    },
  });

  await context.entities.Conversation.updateMany({
    where: { leadId: args.leadId },
    data: {
      residentId: resident.id,
      leadId: null,
    },
  });

  return resident;
};

export const deleteLead: DeleteLead<{ id: string }, any> = async (
  args,
  context
) => {
  if (!context.user) {
    throw new HttpError(401, 'User not authenticated');
  }

  const user = await context.entities.User.findUnique({
    where: { id: context.user.id },
  });

  if (!user || !user.organizationId) {
    throw new HttpError(403, 'User must belong to an organization');
  }

  const lead = await context.entities.Lead.findUnique({
    where: { id: args.id },
  });

  if (!lead) {
    throw new HttpError(404, 'Lead not found');
  }

  if (lead.organizationId !== user.organizationId) {
    throw new HttpError(403, 'Access denied');
  }

  await context.entities.Lead.delete({
    where: { id: args.id },
  });

  return { success: true };
};
