import { getSignedUploadUrl } from 'wasp/client/operations';

export async function uploadToGCS(file: File): Promise<{ url: string }> {
  try {
    // Get signed upload URL from Wasp operation
    const { uploadUrl, fileUrl } = await getSignedUploadUrl({
      fileName: file.name,
      contentType: file.type,
    });

    // Upload file to GCS using signed URL
    const uploadResponse = await fetch(uploadUrl, {
      method: 'PUT',
      headers: {
        'Content-Type': file.type,
      },
      body: file,
    });

    if (!uploadResponse.ok) {
      throw new Error('Failed to upload file to storage');
    }

    return { url: fileUrl };
  } catch (error: any) {
    console.error('Upload error:', error);
    throw new Error(error.message || 'Failed to upload file. Please try again.');
  }
}
