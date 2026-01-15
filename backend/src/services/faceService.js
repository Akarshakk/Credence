// Note: In a real production environment, we would use face-api.js with canvas
// or an external service like AWS Rekognition.
// For this hackathon implementation, we will simulate face matching 
// because loading tensor models requires downloading ~100MB of model files.

/**
 * Compares a document photo with a selfie
 * @param {string} docImagePath - Path to ID card photo
 * @param {string} selfiePath - Path to selfie
 * @returns {Promise<number>} - Match score (0-100)
 */
exports.compareFaces = async (docImagePath, selfiePath) => {
    return new Promise((resolve) => {
        console.log(`[FaceMatch] Comparing ${docImagePath} with ${selfiePath}`);

        // Simulate processing delay
        setTimeout(() => {
            // Mock logic: 
            // In a real app, this would return a calculated similarity score.
            // Here we return a high score to allow the flow to succeed during testing.
            // Random score between 85 and 99
            const score = Math.floor(Math.random() * (99 - 85 + 1) + 85);
            resolve(score);
        }, 1500);
    });
};
