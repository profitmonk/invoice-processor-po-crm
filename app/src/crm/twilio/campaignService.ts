// app/src/crm/twilio/campaignService.ts

import { getTwilioClient } from './client';
import type { PrismaClient } from '@prisma/client';

export async function registerPlatformBrand(prisma: PrismaClient): Promise<string> {
  const client = getTwilioClient();
  
  try {
    let platformConfig = await prisma.platformConfig.findFirst();
    
    if (platformConfig?.twilioBrandSid && platformConfig.twilioBrandStatus === 'APPROVED') {
      console.log('✅ Platform brand already registered and approved:', platformConfig.twilioBrandSid);
      return platformConfig.twilioBrandSid;
    }
    
    const existingBrands = await client.messaging.v1.brandRegistrations.list();
    
    if (existingBrands.length > 0) {
      const brandSid = existingBrands[0].sid;
      console.log('✅ Found existing brand in Twilio:', brandSid);
      
      if (!platformConfig) {
        platformConfig = await prisma.platformConfig.create({
          data: {
            twilioBrandSid: brandSid,
            twilioBrandStatus: 'APPROVED',
            twilioBrandRegisteredAt: new Date(),
            twilioBrandApprovedAt: new Date(),
          },
        });
      } else {
        await prisma.platformConfig.update({
          where: { id: platformConfig.id },
          data: {
            twilioBrandSid: brandSid,
            twilioBrandStatus: 'APPROVED',
          },
        });
      }
      
      return brandSid;
    }
    
    console.log('⚠️  No brand found. You need to:');
    console.log('1. Complete Twilio Trust Hub verification');
    console.log('2. Register your brand in Twilio Console');
    console.log('3. Then run this function again');
    
    throw new Error('Brand registration requires manual Trust Hub setup first');
  } catch (error: any) {
    console.error('❌ Brand registration check failed:', error);
    throw error;
  }
}

async function getPlatformBrandSid(prisma: PrismaClient): Promise<string> {
  const platformConfig = await prisma.platformConfig.findFirst();
  
  if (!platformConfig?.twilioBrandSid) {
    throw new Error('Platform brand not registered. Run registerPlatformBrand() first.');
  }
  
  if (platformConfig.twilioBrandStatus !== 'APPROVED') {
    throw new Error(`Platform brand not approved. Status: ${platformConfig.twilioBrandStatus}`);
  }
  
  return platformConfig.twilioBrandSid;
}

export async function createCampaignForOrganization(
  organizationId: string,
  prisma: PrismaClient
): Promise<any> {
  const client = getTwilioClient();
  
  const organization = await prisma.organization.findUnique({
    where: { id: organizationId },
    include: { assignedPhoneNumber: true },
  });
  
  if (!organization) {
    throw new Error('Organization not found');
  }
  
  if (organization.twilioCampaignSid) {
    throw new Error(`Organization already has a campaign: ${organization.twilioCampaignSid}`);
  }
  
  if (!organization.twilioPhoneNumber) {
    throw new Error('Organization must have a phone number assigned first');
  }
  
  const brandSid = await getPlatformBrandSid(prisma);
  
  try {
    console.log(`🚀 Creating campaign for ${organization.name}...`);
    
    const messagingService = await client.messaging.v1.services.create({
      friendlyName: `${organization.name} - Tenant Communications`,
      inboundRequestUrl: `${process.env.WASP_WEB_CLIENT_URL}/api/twilio/sms`,
      inboundMethod: 'POST',
      statusCallback: `${process.env.WASP_WEB_CLIENT_URL}/api/twilio/status`,
      usecase: 'notifications',
      validityPeriod: 14400,
    });
    
    console.log(`✅ Messaging service created: ${messagingService.sid}`);
    
    if (organization.twilioPhoneNumberSid) {
      await client.messaging.v1.services(messagingService.sid)
        .phoneNumbers
        .create({
          phoneNumberSid: organization.twilioPhoneNumberSid,
        });
      
      console.log(`✅ Phone number ${organization.twilioPhoneNumber} linked to messaging service`);
    }
    
    const campaign = await client.messaging.v1.services(messagingService.sid)
      .usAppToPerson
      .create({
        description: `Tenant and prospect communication for ${organization.name}. Automated notifications for maintenance requests, lease renewals, rent reminders, and property inquiries. Two-way SMS communication between residents and property management.`,
        
        messageFlow: `Residents/prospects text ${organization.twilioPhoneNumber} to:
1. Report maintenance issues (AI creates tickets)
2. Ask property questions (AI responds)
3. Schedule tours (AI coordinates)
4. Receive rent reminders and lease notifications
Property managers can send announcements and updates.`,
        
        brandRegistrationSid: brandSid,
        usAppToPersonUsecase: 'CUSTOMER_CARE',
        
        hasEmbeddedLinks: true,
        hasEmbeddedPhone: true,
        
        subscriberOptIn: true,
        ageGated: false,
        directLending: false,
        
        messageVolume: '1000-10000',
        
        optInMessage: `Welcome to ${organization.name} text notifications! Reply YES to confirm. Msg&data rates may apply. Reply STOP to opt out.`,
        optOutMessage: `You've been unsubscribed from ${organization.name} texts. Reply START to rejoin.`,
        helpMessage: `${organization.name} - Text HELP for support, STOP to opt out. Contact: ${organization.emergencyPhone || 'office'}`,
        
        optInKeywords: ['START', 'YES', 'UNSTOP', 'SUBSCRIBE'],
        optOutKeywords: ['STOP', 'END', 'CANCEL', 'UNSUBSCRIBE', 'QUIT'],
        helpKeywords: ['HELP', 'INFO', 'SUPPORT', 'ASSISTANCE'],
      });
    
    console.log(`✅ A2P Campaign created: ${campaign.sid}`);
    console.log(`   Status: ${campaign.campaignStatus}`);
    
    await prisma.organization.update({
      where: { id: organizationId },
      data: {
        twilioBrandSid: brandSid,
        twilioCampaignSid: campaign.sid,
        twilioMessagingServiceSid: messagingService.sid,
        campaignStatus: 'PENDING',
        campaignUseCase: 'CUSTOMER_CARE',
        campaignDescription: campaign.description,
        campaignRegisteredAt: new Date(),
        dailySMSLimit: 2000,
        smsEnabled: false,
      },
    });
    
    if (organization.assignedPhoneNumber) {
      await prisma.twilioPhoneNumber.update({
        where: { id: organization.assignedPhoneNumber.id },
        data: {
          messagingServiceSid: messagingService.sid,
          campaignSid: campaign.sid,
        },
      });
    }
    
    console.log(`✅ Campaign registration complete for ${organization.name}`);
    console.log(`⏳ Campaign pending carrier approval (1-3 business days)`);
    
    return {
      campaignSid: campaign.sid,
      messagingServiceSid: messagingService.sid,
      status: 'PENDING',
      message: 'Campaign created and pending carrier approval',
    };
  } catch (error: any) {
    console.error(`❌ Campaign creation failed for ${organization.name}:`, error);
    
    await prisma.organization.update({
      where: { id: organizationId },
      data: {
        campaignStatus: 'FAILED',
        campaignRejectionReason: error.message,
      },
    });
    
    throw new Error(`Campaign creation failed: ${error.message}`);
  }
}

export async function checkCampaignStatus(
  organizationId: string,
  prisma: PrismaClient
): Promise<string> {
  const organization = await prisma.organization.findUnique({
    where: { id: organizationId },
  });
  
  if (!organization?.twilioCampaignSid || !organization.twilioMessagingServiceSid) {
    return 'NOT_REGISTERED';
  }
  
  const client = getTwilioClient();
  
  try {
    const campaigns = await client.messaging.v1
      .services(organization.twilioMessagingServiceSid)
      .usAppToPerson
      .list();
    
    const campaign = campaigns.find(c => c.sid === organization.twilioCampaignSid);
    
    if (!campaign) {
      console.log(`⚠️  Campaign not found in Twilio for ${organization.name}`);
      return 'NOT_FOUND';
    }
    
    const status = campaign.campaignStatus;
    console.log(`Campaign status for ${organization.name}: ${status}`);
    
    const updateData: any = {
      campaignStatus: status,
    };
    
    if (status === 'APPROVED' && !organization.campaignApprovedAt) {
      updateData.campaignApprovedAt = new Date();
      updateData.smsEnabled = true;
      updateData.communicationSetup = true;
      updateData.setupCompletedAt = new Date();
      console.log(`✅ Campaign APPROVED for ${organization.name} - SMS enabled!`);
    }
    
    if (status === 'REJECTED') {
      updateData.campaignRejectedAt = new Date();
      updateData.smsEnabled = false;
      console.log(`❌ Campaign REJECTED for ${organization.name}`);
    }
    
    await prisma.organization.update({
      where: { id: organizationId },
      data: updateData,
    });
    
    return status;
  } catch (error: any) {
    console.error(`Error checking campaign status for ${organization.name}:`, error);
    return 'ERROR';
  }
}

export async function checkAllPendingCampaigns(prisma: PrismaClient): Promise<any> {
  const pendingOrgs = await prisma.organization.findMany({
    where: {
      campaignStatus: 'PENDING',
    },
  });
  
  console.log(`🔍 Checking ${pendingOrgs.length} pending campaigns...`);
  
  const results = [];
  
  for (const org of pendingOrgs) {
    try {
      const status = await checkCampaignStatus(org.id, prisma);
      results.push({
        organizationId: org.id,
        organizationName: org.name,
        status,
      });
    } catch (error: any) {
      results.push({
        organizationId: org.id,
        organizationName: org.name,
        status: 'ERROR',
        error: error.message,
      });
    }
  }
  
  return results;
}

export async function getCampaignLimits(
  organizationId: string,
  prisma: PrismaClient
): Promise<any> {
  const organization = await prisma.organization.findUnique({
    where: { id: organizationId },
  });
  
  if (!organization) {
    throw new Error('Organization not found');
  }
  
  if (!organization.twilioCampaignSid) {
    throw new Error('No campaign registered');
  }
  
  const today = new Date().toDateString();
  const lastReset = organization.lastSMSResetDate?.toDateString();
  
  let dailyUsed = organization.dailySMSUsed || 0;
  if (today !== lastReset) {
    dailyUsed = 0;
  }
  
  const dailyLimit = organization.dailySMSLimit || 2000;
  const remaining = Math.max(0, dailyLimit - dailyUsed);
  const percentUsed = dailyLimit > 0 ? (dailyUsed / dailyLimit) * 100 : 0;
  
  return {
    dailyLimit,
    dailyUsed,
    remaining,
    percentUsed: Math.round(percentUsed),
    resetTime: today !== lastReset ? new Date() : organization.lastSMSResetDate,
    status: organization.campaignStatus,
    smsEnabled: organization.smsEnabled,
  };
}

export async function trackSMSUsage(
  organizationId: string,
  count: number = 1,
  prisma: PrismaClient
): Promise<void> {
  const organization = await prisma.organization.findUnique({
    where: { id: organizationId },
  });
  
  if (!organization) return;
  
  const today = new Date().toDateString();
  const lastReset = organization.lastSMSResetDate?.toDateString();
  
  if (today !== lastReset) {
    await prisma.organization.update({
      where: { id: organizationId },
      data: {
        dailySMSUsed: count,
        lastSMSResetDate: new Date(),
      },
    });
  } else {
    await prisma.organization.update({
      where: { id: organizationId },
      data: {
        dailySMSUsed: { increment: count },
        smsCreditsUsed: { increment: count },
      },
    });
  }
}

export async function suspendCampaign(
  organizationId: string,
  reason: string,
  prisma: PrismaClient
): Promise<void> {
  await prisma.organization.update({
    where: { id: organizationId },
    data: {
      campaignStatus: 'SUSPENDED',
      smsEnabled: false,
      campaignRejectionReason: `Suspended: ${reason}`,
    },
  });
  
  console.log(`⛔ Campaign suspended for organization ${organizationId}: ${reason}`);
}

export async function reactivateCampaign(
  organizationId: string,
  prisma: PrismaClient
): Promise<void> {
  const organization = await prisma.organization.findUnique({
    where: { id: organizationId },
  });
  
  if (!organization?.twilioCampaignSid) {
    throw new Error('No campaign to reactivate');
  }
  
  const status = await checkCampaignStatus(organizationId, prisma);
  
  if (status === 'APPROVED') {
    await prisma.organization.update({
      where: { id: organizationId },
      data: {
        campaignStatus: 'APPROVED',
        smsEnabled: true,
        campaignRejectionReason: null,
      },
    });
    console.log(`✅ Campaign reactivated for organization ${organizationId}`);
  } else {
    throw new Error(`Cannot reactivate. Campaign status: ${status}`);
  }
}
