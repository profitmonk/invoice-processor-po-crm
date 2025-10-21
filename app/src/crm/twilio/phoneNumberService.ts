// app/src/crm/twilio/phoneNumberService.ts

import { getTwilioClient } from './client';
import type { PrismaClient } from '@prisma/client';

export async function purchasePhoneNumber(
  areaCode: string = '555',
  prisma: PrismaClient
): Promise<any> {
  const client = getTwilioClient();
  
  try {
    const availableNumbers = await client.availablePhoneNumbers('US')
      .local
      .list({
        areaCode: areaCode,
        smsEnabled: true,
        voiceEnabled: true,
        limit: 5
      });
    
    if (availableNumbers.length === 0) {
      throw new Error(`No available numbers in area code ${areaCode}`);
    }
    
    const selectedNumber = availableNumbers[0];
    const purchasedNumber = await client.incomingPhoneNumbers.create({
      phoneNumber: selectedNumber.phoneNumber,
      smsUrl: `${process.env.WASP_WEB_CLIENT_URL}/api/twilio/sms`,
      smsMethod: 'POST',
      voiceUrl: `${process.env.WASP_WEB_CLIENT_URL}/api/twilio/voice`,
      voiceMethod: 'POST',
      statusCallback: `${process.env.WASP_WEB_CLIENT_URL}/api/twilio/status`,
      statusCallbackMethod: 'POST',
    });
    
    const phoneNumberRecord = await prisma.twilioPhoneNumber.create({
      data: {
        phoneNumber: purchasedNumber.phoneNumber,
        phoneNumberSid: purchasedNumber.sid,
        status: 'AVAILABLE',
        friendlyName: purchasedNumber.friendlyName,
        smsEnabled: true,
        voiceEnabled: true,
        monthlyPrice: 1.15,
      },
    });
    
    console.log(`✅ Purchased phone number: ${purchasedNumber.phoneNumber}`);
    
    return phoneNumberRecord;
  } catch (error: any) {
    console.error('Error purchasing phone number:', error);
    throw new Error(`Failed to purchase phone number: ${error.message}`);
  }
}

export async function assignPhoneNumberToOrganization(
  organizationId: string,
  phoneNumberId: string,
  prisma: PrismaClient
): Promise<any> {
  const existingAssignment = await prisma.twilioPhoneNumber.findFirst({
    where: { organizationId }
  });
  
  if (existingAssignment) {
    throw new Error('Organization already has a phone number assigned');
  }
  
  const phoneNumber = await prisma.twilioPhoneNumber.findUnique({
    where: { id: phoneNumberId }
  });
  
  if (!phoneNumber) {
    throw new Error('Phone number not found');
  }
  
  if (phoneNumber.status !== 'AVAILABLE') {
    throw new Error('Phone number is not available');
  }
  
  const updatedPhoneNumber = await prisma.twilioPhoneNumber.update({
    where: { id: phoneNumberId },
    data: {
      organizationId,
      status: 'ASSIGNED',
      assignedAt: new Date(),
    },
  });
  
  await prisma.organization.update({
    where: { id: organizationId },
    data: {
      twilioPhoneNumber: updatedPhoneNumber.phoneNumber,
      twilioPhoneNumberSid: updatedPhoneNumber.phoneNumberSid,
      communicationSetup: true,
      setupCompletedAt: new Date(),
    },
  });
  
  console.log(`✅ Assigned ${updatedPhoneNumber.phoneNumber} to organization ${organizationId}`);
  
  return updatedPhoneNumber;
}

export async function autoProvisionPhoneNumber(
  organizationId: string,
  areaCode: string = '555',
  prisma: PrismaClient
): Promise<any> {
  const phoneNumber = await purchasePhoneNumber(areaCode, prisma);
  const assignment = await assignPhoneNumberToOrganization(
    organizationId,
    phoneNumber.id,
    prisma
  );
  
  return assignment;
}

export async function releasePhoneNumber(
  organizationId: string,
  prisma: PrismaClient
): Promise<void> {
  const phoneNumber = await prisma.twilioPhoneNumber.findFirst({
    where: { organizationId }
  });
  
  if (!phoneNumber) {
    throw new Error('No phone number assigned to this organization');
  }
  
  await prisma.twilioPhoneNumber.update({
    where: { id: phoneNumber.id },
    data: {
      organizationId: null,
      status: 'AVAILABLE',
      releasedAt: new Date(),
    },
  });
  
  await prisma.organization.update({
    where: { id: organizationId },
    data: {
      twilioPhoneNumber: null,
      twilioPhoneNumberSid: null,
      communicationSetup: false,
    },
  });
  
  console.log(`✅ Released ${phoneNumber.phoneNumber} from organization`);
}

export async function getAvailablePhoneNumbers(prisma: PrismaClient) {
  return prisma.twilioPhoneNumber.findMany({
    where: { status: 'AVAILABLE' },
    orderBy: { purchasedAt: 'asc' },
  });
}

export async function getOrganizationPhoneNumber(
  organizationId: string,
  prisma: PrismaClient
) {
  return prisma.twilioPhoneNumber.findFirst({
    where: { organizationId },
    include: { organization: true },
  });
}
