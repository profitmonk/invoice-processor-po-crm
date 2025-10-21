/*
  Warnings:

  - A unique constraint covering the columns `[twilioPhoneNumber]` on the table `Organization` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[twilioCampaignSid]` on the table `Organization` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateEnum
CREATE TYPE "LeadStatus" AS ENUM ('NEW', 'CONTACTED', 'TOURING_SCHEDULED', 'TOURED', 'APPLIED', 'APPROVED', 'CONVERTED', 'LOST');

-- CreateEnum
CREATE TYPE "LeadSource" AS ENUM ('WEBSITE', 'REFERRAL', 'WALK_IN', 'PHONE', 'EMAIL', 'SOCIAL_MEDIA', 'ADVERTISING', 'OTHER');

-- CreateEnum
CREATE TYPE "LeadPriority" AS ENUM ('HOT', 'WARM', 'COLD');

-- CreateEnum
CREATE TYPE "ResidentStatus" AS ENUM ('ACTIVE', 'NOTICE_GIVEN', 'PAST_RESIDENT');

-- CreateEnum
CREATE TYPE "LeaseType" AS ENUM ('MONTH_TO_MONTH', 'SIX_MONTHS', 'ONE_YEAR', 'TWO_YEARS', 'CUSTOM');

-- CreateEnum
CREATE TYPE "MaintenanceRequestType" AS ENUM ('PLUMBING', 'HVAC', 'ELECTRICAL', 'APPLIANCE', 'GENERAL', 'EMERGENCY', 'PEST_CONTROL', 'LANDSCAPING', 'SECURITY', 'OTHER');

-- CreateEnum
CREATE TYPE "MaintenancePriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'EMERGENCY');

-- CreateEnum
CREATE TYPE "MaintenanceStatus" AS ENUM ('SUBMITTED', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'CLOSED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "MessageType" AS ENUM ('SMS', 'PHONE_CALL', 'EMAIL', 'IN_APP');

-- CreateEnum
CREATE TYPE "MessageStatus" AS ENUM ('SENT', 'DELIVERED', 'READ', 'FAILED');

-- CreateEnum
CREATE TYPE "SenderType" AS ENUM ('RESIDENT', 'LEAD', 'AI_AGENT', 'MANAGER', 'SYSTEM');

-- AlterTable
ALTER TABLE "Organization" ADD COLUMN     "aiAgentEnabled" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "businessHoursEnd" TEXT DEFAULT '17:00',
ADD COLUMN     "businessHoursStart" TEXT DEFAULT '09:00',
ADD COLUMN     "campaignApprovedAt" TIMESTAMP(3),
ADD COLUMN     "campaignDescription" TEXT,
ADD COLUMN     "campaignRegisteredAt" TIMESTAMP(3),
ADD COLUMN     "campaignRejectedAt" TIMESTAMP(3),
ADD COLUMN     "campaignRejectionReason" TEXT,
ADD COLUMN     "campaignStatus" TEXT DEFAULT 'NOT_REGISTERED',
ADD COLUMN     "campaignUseCase" TEXT DEFAULT 'CUSTOMER_CARE',
ADD COLUMN     "communicationSetup" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "dailySMSLimit" INTEGER DEFAULT 2000,
ADD COLUMN     "dailySMSUsed" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "emergencyEmail" TEXT,
ADD COLUMN     "emergencyPhone" TEXT,
ADD COLUMN     "lastSMSResetDate" TIMESTAMP(3),
ADD COLUMN     "monthlySmsCost" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "setupCompletedAt" TIMESTAMP(3),
ADD COLUMN     "smsCreditsLimit" INTEGER,
ADD COLUMN     "smsCreditsUsed" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "smsEnabled" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "timezone" TEXT DEFAULT 'America/Chicago',
ADD COLUMN     "twilioBrandSid" TEXT,
ADD COLUMN     "twilioCampaignSid" TEXT,
ADD COLUMN     "twilioMessagingServiceSid" TEXT,
ADD COLUMN     "twilioPhoneNumber" TEXT,
ADD COLUMN     "twilioPhoneNumberSid" TEXT,
ADD COLUMN     "voiceEnabled" BOOLEAN NOT NULL DEFAULT false;

-- CreateTable
CREATE TABLE "Resident" (
    "id" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phoneNumber" TEXT NOT NULL,
    "propertyId" TEXT NOT NULL,
    "unitNumber" TEXT NOT NULL,
    "moveInDate" TIMESTAMP(3) NOT NULL,
    "monthlyRentAmount" DOUBLE PRECISION NOT NULL,
    "rentDueDay" INTEGER NOT NULL DEFAULT 1,
    "leaseStartDate" TIMESTAMP(3) NOT NULL,
    "leaseEndDate" TIMESTAMP(3) NOT NULL,
    "leaseType" "LeaseType" NOT NULL DEFAULT 'ONE_YEAR',
    "emergencyContactName" TEXT,
    "emergencyContactPhone" TEXT,
    "emergencyContactRelationship" TEXT,
    "status" "ResidentStatus" NOT NULL DEFAULT 'ACTIVE',
    "organizationId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Resident_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Lead" (
    "id" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "email" TEXT,
    "phoneNumber" TEXT NOT NULL,
    "leadSource" "LeadSource" NOT NULL DEFAULT 'OTHER',
    "status" "LeadStatus" NOT NULL DEFAULT 'NEW',
    "priority" "LeadPriority" NOT NULL DEFAULT 'WARM',
    "interestedPropertyId" TEXT,
    "desiredBedrooms" INTEGER,
    "budgetMin" DOUBLE PRECISION,
    "budgetMax" DOUBLE PRECISION,
    "desiredMoveInDate" TIMESTAMP(3),
    "assignedManagerId" TEXT,
    "notes" TEXT,
    "organizationId" TEXT NOT NULL,
    "convertedToResidentId" TEXT,
    "convertedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Lead_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Conversation" (
    "id" TEXT NOT NULL,
    "residentId" TEXT,
    "leadId" TEXT,
    "messageContent" TEXT NOT NULL,
    "messageType" "MessageType" NOT NULL DEFAULT 'SMS',
    "senderType" "SenderType" NOT NULL,
    "senderId" TEXT,
    "aiGenerated" BOOLEAN NOT NULL DEFAULT false,
    "aiModel" TEXT,
    "aiPromptTokens" INTEGER,
    "aiResponseTokens" INTEGER,
    "status" "MessageStatus" NOT NULL DEFAULT 'SENT',
    "twilioMessageSid" TEXT,
    "twilioCallSid" TEXT,
    "twilioStatus" TEXT,
    "errorMessage" TEXT,
    "organizationId" TEXT NOT NULL,
    "sentAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deliveredAt" TIMESTAMP(3),
    "readAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Conversation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MaintenanceRequest" (
    "id" TEXT NOT NULL,
    "residentId" TEXT NOT NULL,
    "propertyId" TEXT NOT NULL,
    "unitNumber" TEXT NOT NULL,
    "requestType" "MaintenanceRequestType" NOT NULL DEFAULT 'GENERAL',
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "priority" "MaintenancePriority" NOT NULL DEFAULT 'MEDIUM',
    "status" "MaintenanceStatus" NOT NULL DEFAULT 'SUBMITTED',
    "assignedToPhone" TEXT,
    "assignedToName" TEXT,
    "assignedManagerId" TEXT,
    "resolutionNotes" TEXT,
    "residentSatisfaction" INTEGER,
    "residentFeedback" TEXT,
    "photoUrls" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "organizationId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "MaintenanceRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TwilioPhoneNumber" (
    "id" TEXT NOT NULL,
    "phoneNumber" TEXT NOT NULL,
    "phoneNumberSid" TEXT NOT NULL,
    "organizationId" TEXT,
    "messagingServiceSid" TEXT,
    "campaignSid" TEXT,
    "status" TEXT NOT NULL DEFAULT 'AVAILABLE',
    "smsEnabled" BOOLEAN NOT NULL DEFAULT true,
    "voiceEnabled" BOOLEAN NOT NULL DEFAULT true,
    "mmsEnabled" BOOLEAN NOT NULL DEFAULT false,
    "friendlyName" TEXT,
    "region" TEXT DEFAULT 'US',
    "monthlyPrice" DOUBLE PRECISION NOT NULL DEFAULT 1.15,
    "purchasedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "assignedAt" TIMESTAMP(3),
    "releasedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TwilioPhoneNumber_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PlatformConfig" (
    "id" TEXT NOT NULL,
    "twilioBrandSid" TEXT,
    "twilioBrandStatus" TEXT DEFAULT 'NOT_REGISTERED',
    "twilioBrandRegisteredAt" TIMESTAMP(3),
    "twilioBrandApprovedAt" TIMESTAMP(3),
    "trustHubProfileSid" TEXT,
    "a2pProfileBundleSid" TEXT,
    "maxOrganizations" INTEGER DEFAULT 100,
    "maxPhoneNumbers" INTEGER DEFAULT 100,
    "campaignAutoApproval" BOOLEAN NOT NULL DEFAULT false,
    "allowSelfServiceOnboarding" BOOLEAN NOT NULL DEFAULT true,
    "lastHealthCheck" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PlatformConfig_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Resident_organizationId_status_idx" ON "Resident"("organizationId", "status");

-- CreateIndex
CREATE INDEX "Resident_propertyId_idx" ON "Resident"("propertyId");

-- CreateIndex
CREATE UNIQUE INDEX "Resident_organizationId_phoneNumber_key" ON "Resident"("organizationId", "phoneNumber");

-- CreateIndex
CREATE UNIQUE INDEX "Lead_convertedToResidentId_key" ON "Lead"("convertedToResidentId");

-- CreateIndex
CREATE INDEX "Lead_organizationId_status_idx" ON "Lead"("organizationId", "status");

-- CreateIndex
CREATE INDEX "Lead_assignedManagerId_idx" ON "Lead"("assignedManagerId");

-- CreateIndex
CREATE INDEX "Lead_interestedPropertyId_idx" ON "Lead"("interestedPropertyId");

-- CreateIndex
CREATE UNIQUE INDEX "Lead_organizationId_phoneNumber_key" ON "Lead"("organizationId", "phoneNumber");

-- CreateIndex
CREATE UNIQUE INDEX "Conversation_twilioMessageSid_key" ON "Conversation"("twilioMessageSid");

-- CreateIndex
CREATE UNIQUE INDEX "Conversation_twilioCallSid_key" ON "Conversation"("twilioCallSid");

-- CreateIndex
CREATE INDEX "Conversation_residentId_idx" ON "Conversation"("residentId");

-- CreateIndex
CREATE INDEX "Conversation_leadId_idx" ON "Conversation"("leadId");

-- CreateIndex
CREATE INDEX "Conversation_organizationId_idx" ON "Conversation"("organizationId");

-- CreateIndex
CREATE INDEX "Conversation_createdAt_idx" ON "Conversation"("createdAt");

-- CreateIndex
CREATE INDEX "MaintenanceRequest_residentId_idx" ON "MaintenanceRequest"("residentId");

-- CreateIndex
CREATE INDEX "MaintenanceRequest_propertyId_idx" ON "MaintenanceRequest"("propertyId");

-- CreateIndex
CREATE INDEX "MaintenanceRequest_organizationId_status_idx" ON "MaintenanceRequest"("organizationId", "status");

-- CreateIndex
CREATE INDEX "MaintenanceRequest_priority_idx" ON "MaintenanceRequest"("priority");

-- CreateIndex
CREATE UNIQUE INDEX "TwilioPhoneNumber_phoneNumber_key" ON "TwilioPhoneNumber"("phoneNumber");

-- CreateIndex
CREATE UNIQUE INDEX "TwilioPhoneNumber_phoneNumberSid_key" ON "TwilioPhoneNumber"("phoneNumberSid");

-- CreateIndex
CREATE UNIQUE INDEX "TwilioPhoneNumber_organizationId_key" ON "TwilioPhoneNumber"("organizationId");

-- CreateIndex
CREATE INDEX "TwilioPhoneNumber_status_idx" ON "TwilioPhoneNumber"("status");

-- CreateIndex
CREATE INDEX "TwilioPhoneNumber_organizationId_idx" ON "TwilioPhoneNumber"("organizationId");

-- CreateIndex
CREATE INDEX "TwilioPhoneNumber_campaignSid_idx" ON "TwilioPhoneNumber"("campaignSid");

-- CreateIndex
CREATE UNIQUE INDEX "PlatformConfig_twilioBrandSid_key" ON "PlatformConfig"("twilioBrandSid");

-- CreateIndex
CREATE UNIQUE INDEX "Organization_twilioPhoneNumber_key" ON "Organization"("twilioPhoneNumber");

-- CreateIndex
CREATE UNIQUE INDEX "Organization_twilioCampaignSid_key" ON "Organization"("twilioCampaignSid");

-- CreateIndex
CREATE INDEX "Organization_twilioPhoneNumber_idx" ON "Organization"("twilioPhoneNumber");

-- CreateIndex
CREATE INDEX "Organization_twilioCampaignSid_idx" ON "Organization"("twilioCampaignSid");

-- CreateIndex
CREATE INDEX "Organization_campaignStatus_idx" ON "Organization"("campaignStatus");

-- CreateIndex
CREATE INDEX "Organization_communicationSetup_idx" ON "Organization"("communicationSetup");

-- AddForeignKey
ALTER TABLE "Resident" ADD CONSTRAINT "Resident_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "Property"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Resident" ADD CONSTRAINT "Resident_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Lead" ADD CONSTRAINT "Lead_interestedPropertyId_fkey" FOREIGN KEY ("interestedPropertyId") REFERENCES "Property"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Lead" ADD CONSTRAINT "Lead_assignedManagerId_fkey" FOREIGN KEY ("assignedManagerId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Lead" ADD CONSTRAINT "Lead_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Conversation" ADD CONSTRAINT "Conversation_residentId_fkey" FOREIGN KEY ("residentId") REFERENCES "Resident"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Conversation" ADD CONSTRAINT "Conversation_leadId_fkey" FOREIGN KEY ("leadId") REFERENCES "Lead"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Conversation" ADD CONSTRAINT "Conversation_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Conversation" ADD CONSTRAINT "Conversation_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MaintenanceRequest" ADD CONSTRAINT "MaintenanceRequest_residentId_fkey" FOREIGN KEY ("residentId") REFERENCES "Resident"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MaintenanceRequest" ADD CONSTRAINT "MaintenanceRequest_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "Property"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MaintenanceRequest" ADD CONSTRAINT "MaintenanceRequest_assignedManagerId_fkey" FOREIGN KEY ("assignedManagerId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MaintenanceRequest" ADD CONSTRAINT "MaintenanceRequest_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TwilioPhoneNumber" ADD CONSTRAINT "TwilioPhoneNumber_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE SET NULL ON UPDATE CASCADE;
