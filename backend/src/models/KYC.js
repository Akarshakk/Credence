const mongoose = require('mongoose');

const kycSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        unique: true
    },
    documentType: {
        type: String,
        enum: ['aadhaar', 'pan', 'passport', 'driving_license'],
        default: null
    },
    documentNumber: {
        type: String,
        default: null,
        // In a real app, this should be encrypted
        select: false
    },
    documentImage: {
        type: String, // Path to the uploaded document image
        default: null
    },
    ocrData: {
        // Stores raw data extracted from OCR for verification/audit
        rawText: String,
        extractedName: String,
        extractedDob: String,
        confidence: Number,
        verifiedAt: Date
    },
    selfieImage: {
        type: String, // Path to the uploaded selfie
        default: null
    },
    faceMatchScore: {
        type: Number,
        default: null
    },
    verificationHistory: [{
        step: {
            type: String,
            enum: ['document_upload', 'selfie_verification', 'mfa_verification']
        },
        status: {
            type: String,
            enum: ['success', 'failed']
        },
        message: String,
        timestamp: {
            type: Date,
            default: Date.now
        }
    }],
    createdAt: {
        type: Date,
        default: Date.now
    },
    updatedAt: {
        type: Date,
        default: Date.now
    }
});

// Update timestamp on save
kycSchema.pre('save', function (next) {
    this.updatedAt = Date.now();
    next();
});

module.exports = mongoose.model('KYC', kycSchema);
