// app/src/crm/twilio/webhooks.ts

import twilio from 'twilio';
import type { MiddlewareConfigFn } from 'wasp/server';

export const twilioMiddlewareConfigFn: MiddlewareConfigFn = (middlewareConfig) => {
  middlewareConfig.set('csrf', { ignoredRoutes: ['/api/twilio/*'] });
  return middlewareConfig;
};

function verifyTwilioSignature(req: any): boolean {
  if (process.env.NODE_ENV === 'development') {
    return true;
  }

  const signature = req.headers['x-twilio-signature'];
  const url = `https://${req.headers.host}${req.url}`;
  
  return twilio.validateRequest(
    process.env.TWILIO_AUTH_TOKEN!,
    signature,
    url,
    req.body
  );
}

export const handleIncomingSMS = async (req: any, res: any, context: any) => {
  try {
    if (!verifyTwilioSignature(req)) {
      console.error('❌ Invalid Twilio signature');
      return res.status(403).json({ error: 'Invalid signature' });
    }

    const { From, To, Body, MessageSid } = req.body;
    
    console.log(`📱 Incoming SMS: From=${From}, To=${To}`);

    // Find which organization this number belongs to
    const organization = await context.entities.Organization.findFirst({
      where: { twilioPhoneNumber: To },
      include: { properties: true },
    });

    if (!organization) {
      console.error(`❌ No organization found for number: ${To}`);
      const twiml = new twilio.twiml.MessagingResponse();
      twiml.message('This number is not configured. Please contact support.');
      return res.type('text/xml').send(twiml.toString());
    }

    console.log(`✅ Message for organization: ${organization.name}`);

    const fromNumber = From.startsWith('+') ? From : `+${From}`;

    // Find resident or lead within THIS organization
    const resident = await context.entities.Resident.findFirst({
      where: { 
        phoneNumber: fromNumber,
        organizationId: organization.id
      },
      include: { property: true },
    });

    const lead = !resident ? await context.entities.Lead.findFirst({
      where: { 
        phoneNumber: fromNumber,
        organizationId: organization.id
      },
      include: { interestedProperty: true },
    }) : null;

    // Save incoming message
    await context.entities.Conversation.create({
      data: {
        residentId: resident?.id,
        leadId: lead?.id,
        messageContent: Body,
        messageType: 'SMS',
        senderType: resident ? 'RESIDENT' : lead ? 'LEAD' : 'SYSTEM',
        status: 'DELIVERED',
        twilioMessageSid: MessageSid,
        organizationId: organization.id,
      },
    });

    // Process with AI if enabled
    let responseMessage = '';
    
    if (organization.aiAgentEnabled && process.env.AI_AGENT_ENABLED === 'true') {
      try {
        const { processIncomingMessage } = await import('../ai/aiAgent');
        
        const aiResponse = await processIncomingMessage({
          messageContent: Body,
          residentId: resident?.id,
          leadId: lead?.id,
          organization,
          conversationHistory: [],
          context,
        });
        
        responseMessage = aiResponse.message;
        
        // Save AI response
        await context.entities.Conversation.create({
          data: {
            residentId: resident?.id,
            leadId: lead?.id,
            messageContent: responseMessage,
            messageType: 'SMS',
            senderType: 'AI_AGENT',
            aiGenerated: true,
            aiModel: aiResponse.model,
            status: 'SENT',
            organizationId: organization.id,
          },
        });
      } catch (error) {
        console.error('AI processing error:', error);
        responseMessage = resident 
          ? 'Thank you for your message. A property manager will respond shortly.'
          : 'Thank you for your interest! A leasing agent will contact you soon.';
      }
    } else {
      responseMessage = resident
        ? `Thank you for contacting ${organization.name}. A property manager will respond shortly.`
        : `Thank you for your interest in ${organization.name}! A leasing agent will contact you soon.`;
    }

    // Send response via TwiML
    const twiml = new twilio.twiml.MessagingResponse();
    twiml.message(responseMessage);
    
    return res.type('text/xml').send(twiml.toString());
    
  } catch (error: any) {
    console.error('❌ Error handling incoming SMS:', error);
    
    const errorResponse = new twilio.twiml.MessagingResponse();
    errorResponse.message('We encountered an error. Please try again later.');
    
    return res.type('text/xml').send(errorResponse.toString());
  }
};

export const handleIncomingVoiceCall = async (req: any, res: any, context: any) => {
  try {
    if (!verifyTwilioSignature(req)) {
      return res.status(403).json({ error: 'Invalid signature' });
    }

    const { From, To, CallSid } = req.body;
    console.log(`📞 Incoming Call: From=${From}, To=${To}`);

    const organization = await context.entities.Organization.findFirst({
      where: { twilioPhoneNumber: To },
    });

    if (!organization) {
      const twiml = new twilio.twiml.VoiceResponse();
      twiml.say('This number is not configured. Goodbye.');
      return res.type('text/xml').send(twiml.toString());
    }

    const twiml = new twilio.twiml.VoiceResponse();
    twiml.say(`Thank you for calling ${organization.name}. Please hold while we connect you.`);
    
    if (organization.emergencyPhone) {
      twiml.dial(organization.emergencyPhone);
    } else {
      twiml.say('We are unable to connect your call at this time. Please try again later.');
    }

    return res.type('text/xml').send(twiml.toString());
  } catch (error) {
    console.error('Error handling voice call:', error);
    const errorResponse = new twilio.twiml.VoiceResponse();
    errorResponse.say('We apologize. Please try again later.');
    return res.type('text/xml').send(errorResponse.toString());
  }
};

export const handleStatusCallback = async (req: any, res: any, context: any) => {
  try {
    const { MessageSid, MessageStatus, ErrorCode } = req.body;
    
    await context.entities.Conversation.updateMany({
      where: { twilioMessageSid: MessageSid },
      data: {
        status: MessageStatus === 'delivered' ? 'DELIVERED' : 
               MessageStatus === 'failed' ? 'FAILED' : 'SENT',
        deliveredAt: MessageStatus === 'delivered' ? new Date() : undefined,
        errorMessage: ErrorCode ? `Error ${ErrorCode}` : undefined,
      },
    });

    return res.status(200).json({ success: true });
  } catch (error) {
    console.error('Error handling status callback:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
