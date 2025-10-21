// app/src/crm/twilio/smsService.ts

import { getTwilioClient } from './client';
import type { Organization } from 'wasp/entities';
import type { PrismaClient } from '@prisma/client';

interface SendSMSParams {
  to: string;
  message: string;
  organization: Organization;
  mediaUrls?: string[];
  prisma: PrismaClient;
}

export async function sendSMS(params: SendSMSParams): Promise<any> {
  const { to, message, organization, mediaUrls, prisma } = params;
  
  if (!organization.twilioPhoneNumber) {
    throw new Error(`Organization does not have a phone number assigned`);
  }
  
  if (organization.campaignStatus !== 'APPROVED') {
    throw new Error(`Campaign not approved. Status: ${organization.campaignStatus}`);
  }
  
  if (!organization.smsEnabled) {
    throw new Error(`SMS is disabled for this organization`);
  }
  
  const client = getTwilioClient();
  
  try {
    const messageData: any = {
      body: message,
      messagingServiceSid: organization.twilioMessagingServiceSid,
      to: to,
      statusCallback: `${process.env.WASP_WEB_CLIENT_URL}/api/twilio/status`,
    };
    
    if (mediaUrls && mediaUrls.length > 0) {
      messageData.mediaUrl = mediaUrls;
    }
    
    const sentMessage = await client.messages.create(messageData);
    
    console.log(`✅ SMS sent: ${sentMessage.sid}`);
    
    return {
      sid: sentMessage.sid,
      status: sentMessage.status,
      to: sentMessage.to,
      from: sentMessage.from,
    };
  } catch (error: any) {
    console.error(`❌ Failed to send SMS:`, error);
    throw new Error(`Failed to send SMS: ${error.message}`);
  }
}

export function formatPhoneNumber(phone: string): string {
  const digits = phone.replace(/\D/g, '');
  if (digits.length === 10) {
    return `+1${digits}`;
  } else if (digits.length === 11 && digits.startsWith('1')) {
    return `+${digits}`;
  }
  return `+${digits}`;
}
