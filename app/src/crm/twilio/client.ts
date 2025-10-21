// app/src/crm/twilio/client.ts

import twilio from 'twilio';

let twilioClient: any = null;

export function getTwilioClient() {
  if (!twilioClient) {
    if (!process.env.TWILIO_ACCOUNT_SID || !process.env.TWILIO_AUTH_TOKEN) {
      throw new Error('Twilio credentials not configured');
    }
    
    twilioClient = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN
    );
  }
  
  return twilioClient;
}

export async function verifyTwilioConnection(): Promise<boolean> {
  try {
    const client = getTwilioClient();
    await client.api.accounts(process.env.TWILIO_ACCOUNT_SID!).fetch();
    return true;
  } catch (error) {
    console.error('Twilio connection failed:', error);
    return false;
  }
}
