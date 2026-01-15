const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { protect } = require('../middleware/auth');
const {
  getKycStatus,
  uploadDocument,
  uploadSelfie,
  requestMfa,
  verifyMfa
} = require('../controllers/kycController');

// Ensure upload directory exists
const uploadDir = path.join(__dirname, '../../uploads/kyc');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
  console.log('[KYC] Created uploads/kyc directory');
}

// Multer Config
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const userId = req.user ? req.user.id : 'anonymous';
    cb(null, `${userId}-${Date.now()}${path.extname(file.originalname)}`);
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: function (req, file, cb) {
    console.log('[Multer] File upload attempt:');
    console.log('  - Original name:', file.originalname);
    console.log('  - Mimetype:', file.mimetype);
    console.log('  - Field name:', file.fieldname);
    
    // Check mimetype first (more reliable for Flutter uploads)
    const validMimetypes = [
      'image/jpeg',
      'image/jpg', 
      'image/png',
      'image/webp',
      'application/pdf',
      'application/octet-stream' // Flutter sometimes sends this
    ];
    
    // Check file extension
    const filetypes = /jpeg|jpg|png|pdf|webp/i;
    const extname = file.originalname ? filetypes.test(path.extname(file.originalname).toLowerCase()) : false;
    const mimetype = validMimetypes.includes(file.mimetype.toLowerCase());
    
    // Accept if either mimetype is valid OR extension is valid
    // This handles cases where Flutter doesn't send proper mimetype
    if (mimetype || extname || file.mimetype.startsWith('image/')) {
      console.log('[Multer] ✓ File accepted');
      return cb(null, true);
    } else {
      console.log('[Multer] ✗ File rejected');
      cb(new Error(`Invalid file type. Received: ${file.mimetype}, Name: ${file.originalname}`));
    }
  }
});

// Protected routes
router.get('/status', protect, getKycStatus);
router.post('/upload-document', protect, upload.single('document'), uploadDocument);
router.post('/upload-selfie', protect, upload.single('selfie'), uploadSelfie);
router.post('/mfa/request', protect, requestMfa);
router.post('/mfa/verify', protect, verifyMfa);

module.exports = router;
