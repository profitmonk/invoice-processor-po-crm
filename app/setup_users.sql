-- Store org ID in a variable
-- psql -d invoice_processor -f setup_users.sql
DO $$
DECLARE
    org_id TEXT;
BEGIN
    -- Delete existing users
    DELETE FROM "User";
    RAISE NOTICE 'Deleted existing users';
    
    -- Get org ID
    SELECT id INTO org_id FROM "Organization" WHERE code = 'DEMO-ORG';
    RAISE NOTICE 'Organization ID: %', org_id;
    
    -- Verify emails
    UPDATE "AuthIdentity"
    SET "providerData" = jsonb_set(
        "providerData"::jsonb,
        '{isEmailVerified}',
        'true'
    )::text
    WHERE "providerUserId" IN ('admin@demo.com', 'pm@demo.com', 'accounting@demo.com', 'corporate@demo.com');
    RAISE NOTICE 'Verified % emails', FOUND;
    
    -- Assign users to organization
    UPDATE "User" 
    SET "organizationId" = org_id,
        role = 'ADMIN',
        "isAdmin" = true,
        "hasCompletedOnboarding" = true
    WHERE email = 'admin@demo.com';
    RAISE NOTICE 'Updated admin user';
    
    UPDATE "User" 
    SET "organizationId" = org_id,
        role = 'PROPERTY_MANAGER',
        "hasCompletedOnboarding" = true
    WHERE email = 'pm@demo.com';
    RAISE NOTICE 'Updated PM user';
    
    UPDATE "User" 
    SET "organizationId" = org_id,
        role = 'ACCOUNTING',
        "hasCompletedOnboarding" = true
    WHERE email = 'accounting@demo.com';
    RAISE NOTICE 'Updated accounting user';
    
    UPDATE "User" 
    SET "organizationId" = org_id,
        role = 'CORPORATE',
        "hasCompletedOnboarding" = true
    WHERE email = 'corporate@demo.com';
    RAISE NOTICE 'Updated corporate user';
    
END $$;

-- Verify setup
SELECT 
    u.email, 
    u.role, 
    u."isAdmin",
    u."hasCompletedOnboarding",
    ai."providerData"::jsonb->>'isEmailVerified' as verified
FROM "User" u
JOIN "Auth" a ON u.id = a."userId"
JOIN "AuthIdentity" ai ON a.id = ai."authId"
WHERE u.email IN ('admin@demo.com', 'pm@demo.com', 'accounting@demo.com', 'corporate@demo.com')
ORDER BY u.email;
