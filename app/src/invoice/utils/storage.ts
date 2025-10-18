import { Storage } from '@google-cloud/storage';
import path from 'path';

// Initialize GCS client
let storage: Storage;

try {
  const keyBase64 = process.env.GCS_KEY_BASE64;
  
  if (keyBase64) {
    // Production: decode from base64 environment variable
    const keyJson = Buffer.from(keyBase64, 'base64').toString('utf-8');
    const credentials = JSON.parse(keyJson);
    
    storage = new Storage({
      projectId: process.env.GCS_PROJECT_ID,
      credentials: credentials,
    });
    
    console.log('GCS Storage initialized (production mode)');
  } else {
    // Local development: use absolute path to key file
    const keyFilePath = path.resolve(process.cwd(), '../../../gcp-service-account-key.json');
    console.log('DEBUG: Looking for GCS key at:', keyFilePath);
    console.log('DEBUG: process.cwd() is:', process.cwd());
    
    storage = new Storage({
      projectId: process.env.GCS_PROJECT_ID,
      keyFilename: keyFilePath,
    });
    
    console.log('GCS Storage initialized (local mode) from:', keyFilePath);
  }
} catch (error) {
  console.error('Failed to initialize GCS Storage:', error);
  throw error;
}
const bucketName = process.env.GCS_BUCKET_NAME || 'invoice-processor-uploads';
const bucket = storage.bucket(bucketName);

export interface UploadResult {
  fileName: string;
  fileUrl: string;
  fileSize: number;
  mimeType: string;
}
/**
 * Generate a signed URL for uploading a file directly from browser
 */
export async function generateUploadUrl(
  fileName: string,
  contentType: string,
  expiresInMinutes: number = 15
): Promise<{ uploadUrl: string; publicUrl: string; fileName: string }> {
  try {
    // Create unique filename with timestamp
    const timestamp = Date.now();
    const sanitizedName = fileName.replace(/[^a-zA-Z0-9.-]/g, '_');
    const uniqueFileName = `invoices/${timestamp}-${sanitizedName}`;

    const file = bucket.file(uniqueFileName);

    // Generate signed URL for upload
    const [uploadUrl] = await file.getSignedUrl({
      version: 'v4',
      action: 'write',
      expires: Date.now() + expiresInMinutes * 60 * 1000,
      contentType: contentType,
    });

    // Public URL after upload
    const publicUrl = `https://storage.googleapis.com/${bucketName}/${uniqueFileName}`;

    return {
      uploadUrl,
      publicUrl,
      fileName: uniqueFileName
    };
  } catch (error: unknown) {
    console.error('Error generating upload URL:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    throw new Error(`Failed to generate upload URL: ${errorMessage}`);
  }
}

/**
 * Upload file directly from server (for testing or small files)
 */
export async function uploadFile(
  fileBuffer: Buffer,
  fileName: string,
  contentType: string
): Promise<UploadResult> {
  try {
    const timestamp = Date.now();
    const sanitizedName = fileName.replace(/[^a-zA-Z0-9.-]/g, '_');
    const uniqueFileName = `invoices/${timestamp}-${sanitizedName}`;

    const file = bucket.file(uniqueFileName);

    await file.save(fileBuffer, {
      contentType: contentType,
      metadata: {
        contentType: contentType,
      },
    });

    // Make file publicly readable
    await file.makePublic();

    const fileUrl = `https://storage.googleapis.com/${bucketName}/${uniqueFileName}`;

    return {
      fileName: uniqueFileName,
      fileUrl: fileUrl,
      fileSize: fileBuffer.length,
      mimeType: contentType
    };
  } catch (error: unknown) {
    console.error('Error uploading file:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    throw new Error(`Failed to upload file: ${errorMessage}`);
  }
}

/**
 * Delete file from GCS
 */
export async function deleteFile(fileName: string): Promise<void> {
  try {
    const file = bucket.file(fileName);
    await file.delete();
    console.log(`File ${fileName} deleted successfully`);
  } catch (error: unknown) {
    console.error('Error deleting file:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    throw new Error(`Failed to delete file: ${errorMessage}`);
  }
}

/**
 * Check if file exists in GCS
 */
export async function fileExists(fileName: string): Promise<boolean> {
  try {
    const file = bucket.file(fileName);
    const [exists] = await file.exists();
    return exists;
  } catch (error: unknown) {
    console.error('Error checking file existence:', error);
    return false;
  }
}
