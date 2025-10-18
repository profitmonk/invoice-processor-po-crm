import { type GetUploadUrl } from 'wasp/server/operations';
import { HttpError } from 'wasp/server';
import { generateUploadUrl } from '../utils/storage';
import { validateFileUpload } from '../utils/validation';

type GetUploadUrlInput = {
  fileName: string;
  fileSize: number;
  mimeType: string;
};

type GetUploadUrlOutput = {
  uploadUrl: string;
  publicUrl: string;
  fileName: string;
};

export const getUploadUrl: GetUploadUrl<GetUploadUrlInput, GetUploadUrlOutput> = async (
  { fileName, fileSize, mimeType },
  context
) => {
  // Check if user is authenticated
  if (!context.user) {
    throw new HttpError(401, 'You must be logged in to upload invoices');
  }

  // Validate file parameters
  const validation = validateFileUpload(fileName, fileSize, mimeType);
  if (!validation.isValid) {
    throw new HttpError(400, validation.errors.map(e => e.message).join(', '));
  }

  // Check user credits (we'll implement credit checking later)
  // For now, just allow uploads
  
  try {
    // Generate signed upload URL
    const result = await generateUploadUrl(fileName, mimeType);
    
    return result;
  } catch (error: any) {
    console.error('Error generating upload URL:', error);
    throw new HttpError(500, `Failed to generate upload URL: ${error.message}`);
  }
};
