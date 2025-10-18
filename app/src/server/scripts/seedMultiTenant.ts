import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function seedMultiTenantData() {
  console.log('🌱 Seeding multi-tenant data...');

  try {
    // Create demo organization
    const org = await prisma.organization.upsert({
      where: { code: 'DEMO-ORG' },
      update: {},
      create: {
        name: 'Demo Organization',
        code: 'DEMO-ORG',
        poApprovalThreshold: 500,
      },
    });

    console.log('✅ Created organization:', org.name);

    // Create admin user
    const adminUser = await prisma.user.upsert({
      where: { email: 'admin@demo.com' },
      update: {},
      create: {
        email: 'admin@demo.com',
        username: 'admin',
        organizationId: org.id,
        role: 'ADMIN',
        isAdmin: true,
        hasCompletedOnboarding: true,
        credits: 100,
      },
    });

    console.log('✅ Created admin user:', adminUser.email);

    // Create property manager
    const pmUser = await prisma.user.upsert({
      where: { email: 'pm@demo.com' },
      update: {},
      create: {
        email: 'pm@demo.com',
        username: 'propertymanager',
        organizationId: org.id,
        role: 'PROPERTY_MANAGER',
        isAdmin: false,
        hasCompletedOnboarding: true,
        phoneNumber: '+1234567890',
        credits: 10,
      },
    });

    console.log('✅ Created property manager:', pmUser.email);

    // Create accounting user
    const acctUser = await prisma.user.upsert({
      where: { email: 'accounting@demo.com' },
      update: {},
      create: {
        email: 'accounting@demo.com',
        username: 'accounting',
        organizationId: org.id,
        role: 'ACCOUNTING',
        isAdmin: false,
        hasCompletedOnboarding: true,
        phoneNumber: '+1234567891',
        credits: 10,
      },
    });

    console.log('✅ Created accounting user:', acctUser.email);

    // Create corporate user
    const corpUser = await prisma.user.upsert({
      where: { email: 'corporate@demo.com' },
      update: {},
      create: {
        email: 'corporate@demo.com',
        username: 'corporate',
        organizationId: org.id,
        role: 'CORPORATE',
        isAdmin: false,
        hasCompletedOnboarding: true,
        phoneNumber: '+1234567892',
        credits: 10,
      },
    });

    console.log('✅ Created corporate user:', corpUser.email);

    // Create regular user
    const regularUser = await prisma.user.upsert({
      where: { email: 'user@demo.com' },
      update: {},
      create: {
        email: 'user@demo.com',
        username: 'user',
        organizationId: org.id,
        role: 'USER',
        isAdmin: false,
        hasCompletedOnboarding: true,
        credits: 5,
      },
    });

    console.log('✅ Created regular user:', regularUser.email);

    // Create sample properties
    const properties = await Promise.all([
      prisma.property.upsert({
        where: { organizationId_code: { organizationId: org.id, code: 'MW-1007' } },
        update: {},
        create: {
          organizationId: org.id,
          code: 'MW-1007',
          name: 'Maxton West Apartment - Unit 1007',
          address: '123 Main St, Unit 1007',
        },
      }),
      prisma.property.upsert({
        where: { organizationId_code: { organizationId: org.id, code: 'MWA' } },
        update: {},
        create: {
          organizationId: org.id,
          code: 'MWA',
          name: 'Maxton West Apartment - Common Area',
          address: '123 Main St, Common Area',
        },
      }),
    ]);

    console.log(`✅ Created ${properties.length} properties`);

    // Create sample GL Accounts
    const glAccounts = await Promise.all([
      prisma.gLAccount.upsert({
        where: { organizationId_accountNumber: { organizationId: org.id, accountNumber: '7520' } },
        update: {},
        create: {
          organizationId: org.id,
          accountNumber: '7520',
          name: 'Doors Replacement',
          accountType: 'EXPENSE',
          annualBudget: 50000,
        },
      }),
      prisma.gLAccount.upsert({
        where: { organizationId_accountNumber: { organizationId: org.id, accountNumber: '7556' } },
        update: {},
        create: {
          organizationId: org.id,
          accountNumber: '7556',
          name: 'Paint & Sheetrock - Interior',
          accountType: 'EXPENSE',
          annualBudget: 75000,
        },
      }),
      prisma.gLAccount.upsert({
        where: { organizationId_accountNumber: { organizationId: org.id, accountNumber: '7582' } },
        update: {},
        create: {
          organizationId: org.id,
          accountNumber: '7582',
          name: 'Other Interior Replacement',
          accountType: 'EXPENSE',
          annualBudget: 30000,
        },
      }),
      prisma.gLAccount.upsert({
        where: { organizationId_accountNumber: { organizationId: org.id, accountNumber: '7594' } },
        update: {},
        create: {
          organizationId: org.id,
          accountNumber: '7594',
          name: 'Resurface',
          accountType: 'EXPENSE',
          annualBudget: 100000,
        },
      }),
      prisma.gLAccount.upsert({
        where: { organizationId_accountNumber: { organizationId: org.id, accountNumber: '6770' } },
        update: {},
        create: {
          organizationId: org.id,
          accountNumber: '6770',
          name: 'Paint & Supplies (Expense)',
          accountType: 'EXPENSE',
          annualBudget: 25000,
        },
      }),
    ]);

    console.log(`✅ Created ${glAccounts.length} GL accounts`);

    // Create sample expense types
    const expenseTypes = await Promise.all([
      prisma.expenseType.upsert({
        where: { organizationId_code: { organizationId: org.id, code: 'CAPEX' } },
        update: {},
        create: {
          organizationId: org.id,
          name: 'Capital Expense',
          code: 'CAPEX',
        },
      }),
      prisma.expenseType.upsert({
        where: { organizationId_code: { organizationId: org.id, code: 'OPEX' } },
        update: {},
        create: {
          organizationId: org.id,
          name: 'Operating Expense',
          code: 'OPEX',
        },
      }),
      prisma.expenseType.upsert({
        where: { organizationId_code: { organizationId: org.id, code: 'MAINT' } },
        update: {},
        create: {
          organizationId: org.id,
          name: 'Maintenance',
          code: 'MAINT',
        },
      }),
    ]);

    console.log(`✅ Created ${expenseTypes.length} expense types`);

    console.log('🎉 Multi-tenant seed complete!');
    console.log('\n📧 Demo Users:');
    console.log('  Admin:      admin@demo.com');
    console.log('  Prop Mgr:   pm@demo.com');
    console.log('  Accounting: accounting@demo.com');
    console.log('  Corporate:  corporate@demo.com');
    console.log('  User:       user@demo.com');

  } catch (error) {
    console.error('❌ Error seeding data:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}
