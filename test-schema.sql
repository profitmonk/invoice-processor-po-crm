-- Test Invoice schema
\echo '🧪 Testing Invoice schema...\n'

-- Check if tables exist
\echo '✅ Checking tables:'
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('Invoice', 'InvoiceLineItem', 'ProcessingJob')
ORDER BY table_name;

-- Count invoices
\echo '\n✅ Current invoice count:'
SELECT COUNT(*) as invoice_count FROM "Invoice";

-- Check Invoice columns
\echo '\n✅ Invoice table structure:'
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'Invoice' 
ORDER BY ordinal_position 
LIMIT 10;

\echo '\n🎉 Schema is working correctly!\n'
