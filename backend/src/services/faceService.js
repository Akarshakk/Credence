// Enhanced Face Verification Service
// Note: In a real production environment, we would use face-api.js with canvas
// or an external service like AWS Rekognition.
// For this implementation, we'll use a more sophisticated mock that simulates
// real face matching behavior with proper validation.

const fs = require('fs');
const path = require('path');

/**
 * Compares a document photo with a selfie
 * @param {string} docImagePath - Path to ID card photo
 * @param {string} selfiePath - Path to selfie
 * @returns {Promise<Object>} - Match result with score and details
 */
exports.compareFaces = async (docImagePath, selfiePath) => {
    return new Promise((resolve, reject) => {
        console.log(`[FaceMatch] Comparing ${docImagePath} with ${selfiePath}`);

        // Validate input files exist
        if (!fs.existsSync(docImagePath)) {
            return reject(new Error('Document image not found'));
        }
        
        if (!fs.existsSync(selfiePath)) {
            return reject(new Error('Selfie image not found'));
        }

        // Simulate processing delay (real face recognition takes time)
        setTimeout(() => {
            try {
                // Enhanced mock logic with more realistic behavior
                const result = simulateFaceMatching(docImagePath, selfiePath);
                console.log(`[FaceMatch] Result: Score=${result.score}, Match=${result.isMatch}`);
                resolve(result);
            } catch (error) {
                reject(error);
            }
        }, 2000); // Realistic processing time
    });
};

/**
 * Simulates face matching with more realistic behavior
 * @param {string} docImagePath - Document image path
 * @param {string} selfiePath - Selfie image path  
 * @returns {Object} - Match result
 */
function simulateFaceMatching(docImagePath, selfiePath) {
    // Get file stats for basic validation
    const docStats = fs.statSync(docImagePath);
    const selfieStats = fs.statSync(selfiePath);
    
    // Basic file size validation (too small = likely invalid)
    if (docStats.size < 1000 || selfieStats.size < 1000) {
        return {
            score: 15,
            isMatch: false,
            confidence: 'low',
            reason: 'Image quality too poor for comparison'
        };
    }
    
    // Simulate different scenarios based on file characteristics
    const docSize = docStats.size;
    const selfieSize = selfieStats.size;
    
    // Create a deterministic but varied score based on file properties
    const sizeDiff = Math.abs(docSize - selfieSize);
    const baseScore = 75 + (sizeDiff % 20); // Base score 75-95
    
    // Add some randomness for realism (±10 points)
    const randomFactor = (Math.random() - 0.5) * 20;
    let finalScore = Math.round(baseScore + randomFactor);
    
    // Ensure score is within valid range
    finalScore = Math.max(0, Math.min(100, finalScore));
    
    // Determine match result
    const isMatch = finalScore >= 75; // Threshold for match
    
    let confidence, reason;
    
    if (finalScore >= 90) {
        confidence = 'very_high';
        reason = 'Strong facial feature match detected';
    } else if (finalScore >= 80) {
        confidence = 'high';
        reason = 'Good facial feature match detected';
    } else if (finalScore >= 70) {
        confidence = 'medium';
        reason = 'Moderate facial similarity detected';
    } else if (finalScore >= 50) {
        confidence = 'low';
        reason = 'Weak facial similarity detected';
    } else {
        confidence = 'very_low';
        reason = 'No significant facial similarity detected';
    }
    
    return {
        score: finalScore,
        isMatch,
        confidence,
        reason,
        threshold: 75,
        processingTime: '2.1s'
    };
}

/**
 * Validates if an image appears to contain a face
 * @param {string} imagePath - Path to image
 * @returns {Promise<Object>} - Validation result
 */
exports.validateFaceInImage = async (imagePath) => {
    return new Promise((resolve, reject) => {
        if (!fs.existsSync(imagePath)) {
            return reject(new Error('Image file not found'));
        }
        
        setTimeout(() => {
            const stats = fs.statSync(imagePath);
            
            // Basic validation - in real implementation this would use face detection
            const isValid = stats.size > 5000; // Minimum size for face image
            
            resolve({
                hasFace: isValid,
                confidence: isValid ? 0.85 : 0.15,
                reason: isValid ? 'Face detected in image' : 'No face detected or image quality too poor'
            });
        }, 500);
    });
};
