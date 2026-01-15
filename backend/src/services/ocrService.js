const Tesseract = require('tesseract.js');
const fs = require('fs');
const path = require('path');

/**
 * Extracts text from an image using Tesseract OCR
 * @param {string} imagePath - Path to the image file
 * @returns {Promise<Object>} - Extracted text and confidence
 */
exports.extractText = async (imagePath) => {
    try {
        console.log('[OCR] Starting text extraction from:', imagePath);
        
        if (!fs.existsSync(imagePath)) {
            throw new Error('Image file not found at path: ' + imagePath);
        }

        // Check if trained data exists
        const trainedDataPath = path.join(__dirname, '../../eng.traineddata');
        console.log('[OCR] Checking for trained data at:', trainedDataPath);

        const result = await Tesseract.recognize(
            imagePath,
            'eng',
            {
                logger: m => {
                    if (m.status === 'recognizing text') {
                        console.log(`[OCR] Progress: ${parseInt(m.progress * 100)}%`);
                    }
                }
            }
        );

        console.log('[OCR] Extraction complete. Confidence:', result.data.confidence);
        console.log('[OCR] Extracted text preview:', result.data.text.substring(0, 100));

        return {
            text: result.data.text,
            confidence: result.data.confidence
        };
    } catch (error) {
        console.error('[OCR] Error:', error.message);
        throw new Error('Failed to extract text from document: ' + error.message);
    }
};

/**
 * Basic validation of document ID based on type
 * @param {string} type - Document type (aadhaar, pan, etc)
 * @param {string} text - OCR extracted text
 * @returns {boolean} - True if it looks valid
 */
exports.validateDocument = (type, text) => {
    const cleanText = text.replace(/\s/g, '').toUpperCase();
    console.log('[OCR] Validating document type:', type);

    if (type === 'pan') {
        // PAN regex: 5 letters, 4 digits, 1 letter
        const panRegex = /[A-Z]{5}[0-9]{4}[A-Z]{1}/;
        const isValid = panRegex.test(cleanText);
        console.log('[OCR] PAN validation result:', isValid);
        return isValid;
    }

    if (type === 'aadhaar') {
        // Basic check for 12 digit number
        const aadhaarRegex = /[0-9]{12}/;
        const isValid = aadhaarRegex.test(cleanText);
        console.log('[OCR] Aadhaar validation result:', isValid);
        return isValid;
    }

    if (type === 'passport') {
        // Passport number pattern (varies by country, basic check)
        const passportRegex = /[A-Z][0-9]{7}/;
        const isValid = passportRegex.test(cleanText);
        console.log('[OCR] Passport validation result:', isValid);
        return isValid;
    }

    if (type === 'driving_license') {
        // Basic check for alphanumeric pattern
        const dlRegex = /[A-Z0-9]{8,}/;
        const isValid = dlRegex.test(cleanText);
        console.log('[OCR] Driving License validation result:', isValid);
        return isValid;
    }

    // Default true for others
    console.log('[OCR] Unknown document type, defaulting to valid');
    return true;
};
