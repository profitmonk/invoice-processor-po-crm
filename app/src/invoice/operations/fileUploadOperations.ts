import { HttpError } from "wasp/server";
import { generateUploadUrl } from '../utils/storage';

// ============================================
// GENERATE SIGNED UPLOAD URL
// ============================================

type GetSignedUploadUrlInput = {
  fileName: string;
  contentType: string;
};

type GetSignedUploadUrlOutput = {
  uploadUrl: string;
  fileUrl: string;
  fileName: string;
};

export const getSignedUploadUrl = async (
  args: GetSignedUploadUrlInput,
  context: any
): Promise<GetSignedUploadUrlOutput> => {
  if (!context.user) {
    throw new HttpError(401, 'Not authenticated');
  }

  const { fileName, contentType } = args;

  // Validate file type
  const allowedTypes = ['application/pdf', 'image/jpeg', 'image/jpg', 'image/png'];
  if (!allowedTypes.includes(contentType)) {
    throw new HttpError(400, 'Invalid file type. Only PDF, JPEG, and PNG are allowed.');
  }

  try {
    // Use existing storage utility
    const result = await generateUploadUrl(fileName, contentType, 15);

    return {
      uploadUrl: result.uploadUrl,
      fileUrl: result.publicUrl,
      fileName: result.fileName,
    };
  } catch (error: any) {
    console.error('Error generating signed URL:', error);
    throw new HttpError(500, error.message || 'Failed to generate upload URL');
  }
};
