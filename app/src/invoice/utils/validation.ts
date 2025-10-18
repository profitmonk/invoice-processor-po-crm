export const ALLOWED_MIME_TYPES = [
  'application/pdf',
  'image/png',
  'image/jpeg',
  'image/jpg',
];

export const MAX_FILE_SIZE = 15 * 1024 * 1024; // 5MB in bytes

export interface ValidationError {
  field: string;
  message: string;
}

export interface ValidationResult {
  isValid: boolean;
  errors: ValidationError[];
}

/**
 * Validate file upload parameters
 */
export function validateFileUpload(
  fileName: string,
  fileSize: number,
  mimeType: string
): ValidationResult {
  const errors: ValidationError[] = [];

  // Check file name
  if (!fileName || fileName.trim().length === 0) {
    errors.push({
      field: 'fileName',
      message: 'File name is required'
    });
  }

  // Check file size
  if (fileSize <= 0) {
    errors.push({
      field: 'fileSize',
      message: 'File size must be greater than 0'
    });
  }

  if (fileSize > MAX_FILE_SIZE) {
    errors.push({
      field: 'fileSize',
      message: `File size must not exceed ${MAX_FILE_SIZE / (1024 * 1024)}MB`
    });
  }

  // Check MIME type
  if (!ALLOWED_MIME_TYPES.includes(mimeType)) {
    errors.push({
      field: 'mimeType',
      message: `File type not allowed. Allowed types: ${ALLOWED_MIME_TYPES.join(', ')}`
    });
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}

/**
 * Get file extension from filename
 */
export function getFileExtension(fileName: string): string {
  const parts = fileName.split('.');
  return parts.length > 1 ? parts[parts.length - 1].toLowerCase() : '';
}

/**
 * Check if file is PDF
 */
export function isPDF(mimeType: string): boolean {
  return mimeType === 'application/pdf';
}

/**
 * Check if file is image
 */
export function isImage(mimeType: string): boolean {
  return mimeType.startsWith('image/');
}
