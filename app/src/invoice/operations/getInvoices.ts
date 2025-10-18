import { HttpError } from 'wasp/server';

// Helper function to check authentication
const checkAuth = (user: any) => {
  if (!user) {
    throw new HttpError(401, 'Unauthorized');
  }
};

// Helper function to check organization
const checkOrganization = (user: any) => {
  if (!user.organizationId) {
    throw new HttpError(403, 'User must belong to an organization');
  }
};

export const getUserInvoices = async (args: any, context: any) => {
  checkAuth(context.user);
  checkOrganization(context.user);

  const invoices = await context.entities.Invoice.findMany({
    where: {
      user: {
        organizationId: context.user.organizationId,  // ✅ Org-wide access
      },
    },
    include: {
      user: true,  // Include user info to show who created it
      lineItems: {
        orderBy: { lineNumber: 'asc' },
      },
      linkedPurchaseOrder: {
        select: {
          id: true,
          poNumber: true,
          vendor: true,
          totalAmount: true,
          status: true,
        },
      },
    },
    orderBy: { createdAt: 'desc' },
    take: 50,
  });

  return invoices;
};
