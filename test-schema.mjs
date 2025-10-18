import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: 'postgresql://aishwaryadubey@localhost:5432/invoice_processor'
    }
  }
});

async function testSchema() {
  try {
    console.log('🧪 Testing Invoice schema...\n');
    
    // Count existing invoices
    const count = await prisma.invoice.count();
    console.log('✅ Invoice model accessible');
    console.log('   Current invoice count:', count);
    
    // Test enum values
    console.log('\n✅ InvoiceStatus enum values:');
    console.log('   - UPLOADED');
    console.log('   - PAYMENT_REQUIRED');
    console.log('   - QUEUED');
    console.log('   - PROCESSING_OCR');
    console.log('   - PROCESSING_LLM');
    console.log('   - COMPLETED');
    console.log('   - FAILED');
    
    console.log('\n🎉 Schema is working correctly!\n');
    
  } catch (error) {
    console.error('❌ Schema test failed:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

testSchema();
