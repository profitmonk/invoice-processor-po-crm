import { HttpError } from 'wasp/server';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_KEY!);

type BuyCreditsInput = {
  priceId: string;
};

export const buyCredits = async (
  args: BuyCreditsInput,
  context: any
): Promise<{ checkoutUrl: string }> => {
  if (!context.user) {
    throw new HttpError(401, 'Unauthorized');
  }

  const { priceId } = args;

  try {
    const session = await stripe.checkout.sessions.create({
      customer_email: context.user.email,
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      mode: 'payment',
      success_url: `${process.env.WASP_WEB_CLIENT_URL}/invoices?payment=success`,
      cancel_url: `${process.env.WASP_WEB_CLIENT_URL}/invoices?payment=cancelled`,
      metadata: {
        userId: context.user.id,
        type: 'invoice_credits',
      },
    });

    if (!session.url) {
      throw new Error('Failed to create checkout session');
    }

    return { checkoutUrl: session.url };
  } catch (error: any) {
    console.error('Stripe checkout error:', error);
    throw new HttpError(500, `Failed to create checkout: ${error.message}`);
  }
};
