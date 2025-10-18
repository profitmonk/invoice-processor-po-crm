import { Storage } from '@google-cloud/storage';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';
import dotenv from 'dotenv';

// Get current directory (ES module equivalent of __dirname)
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load environment variables
dotenv.config({ path: resolve(__dirname, '.env.server') });

const storage = new Storage({
  projectId: process.env.GCS_PROJECT_ID,
  keyFilename: resolve(__dirname, process.env.GCS_KEY_FILE)
});

async function testGCS() {
  console.log('🧪 Testing GCS connection...\n');
  console.log('Project ID:', process.env.GCS_PROJECT_ID);
  console.log('Bucket Name:', process.env.GCS_BUCKET_NAME);
  console.log('Key File:', process.env.GCS_KEY_FILE, '\n');

  try {
    const bucket = storage.bucket(process.env.GCS_BUCKET_NAME);
    const [exists] = await bucket.exists();
    
    if (!exists) {
      console.error('❌ Bucket does not exist:', process.env.GCS_BUCKET_NAME);
      return;
    }
    
    console.log('✅ Successfully connected to GCS bucket:', process.env.GCS_BUCKET_NAME);
    
    // Test upload
    const testFileName = `test-${Date.now()}.txt`;
    const testFile = bucket.file(testFileName);
    await testFile.save('Hello from Invoice Processor! 🚀');
    console.log('✅ Test file uploaded:', testFileName);
    
    // Get public URL
    const publicUrl = `https://storage.googleapis.com/${process.env.GCS_BUCKET_NAME}/${testFileName}`;
    console.log('✅ Public URL:', publicUrl);
    
    // Test download
    const [content] = await testFile.download();
    console.log('✅ Downloaded content:', content.toString());
    
    // Clean up
    await testFile.delete();
    console.log('✅ Test file deleted\n');
    
    console.log('🎉 GCS setup is complete and working perfectly!\n');
  } catch (error) {
    console.error('\n❌ Error testing GCS:');
    console.error('Message:', error.message);
    if (error.code) console.error('Code:', error.code);
    console.error('\n💡 Common fixes:');
    console.error('  - Verify GCS_PROJECT_ID is correct in .env.server');
    console.error('  - Verify GCS_BUCKET_NAME is correct in .env.server');
    console.error('  - Verify gcp-service-account-key.json exists');
    console.error('  - Verify service account has Storage Admin role\n');
  }
}

testGCS();
