import { Storage } from '@google-cloud/storage';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const storage = new Storage({
  projectId: process.env.GCS_PROJECT_ID,
  keyFilename: path.resolve(__dirname, '.wasp/out/server/gcp-service-account-key.json')
});

async function testSignedUrl() {
  try {
    console.log('Testing signed URL generation...');
    
    const bucket = storage.bucket(process.env.GCS_BUCKET_NAME);
    const file = bucket.file('test-upload.txt');
    
    const [url] = await file.getSignedUrl({
      version: 'v4',
      action: 'write',
      expires: Date.now() + 15 * 60 * 1000,
      contentType: 'text/plain',
    });
    
    console.log('✅ Signed URL generated successfully');
    console.log('URL:', url.substring(0, 100) + '...');
    
    // Test upload to signed URL
    console.log('\nTesting upload to signed URL...');
    const response = await fetch(url, {
      method: 'PUT',
      headers: { 'Content-Type': 'text/plain' },
      body: 'test content'
    });
    
    console.log('Upload response status:', response.status);
    if (response.ok) {
      console.log('✅ Upload successful');
    } else {
      console.log('❌ Upload failed:', await response.text());
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

testSignedUrl();
