# F-Buddy Backend - KYC System

## 🎯 Overview
Backend API for F-Buddy Student Finance Tracking App with secure KYC (Know Your Customer) verification system.

## ✅ Recent Fixes (January 2026)

### Fixed 401 Unauthorized Errors
- Enhanced authentication middleware with detailed logging
- Better error messages showing exactly what's missing
- Support for multiple token header formats

### Fixed File Upload Issues
- Auto-creates upload directories on startup
- Increased file size limit to 10MB
- Better error handling for file operations

### Enhanced OCR & MFA
- Improved OCR processing with detailed logging
- OTP always logged to console for testing
- Email sending is optional (works without SMTP)

## 🚀 Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Environment
Create `.env` file (see `.env.example`):
```env
PORT=5001
MONGODB_URI=your_mongodb_uri
JWT_SECRET=your_secret_key
JWT_EXPIRE=30d

# Optional - for email OTP
SMTP_EMAIL=your_email@gmail.com
SMTP_PASSWORD=your_app_password
```

### 3. Start Server
```bash
npm run dev
```

### 4. Verify Backend
```bash
npm run verify
```

### 5. Test KYC Flow
```bash
npm run test-kyc
```

## 📚 Documentation

- **QUICK_START.md** - Quick reference guide
- **KYC_INTEGRATION_GUIDE.md** - Detailed frontend integration guide
- **FIXES_SUMMARY.md** - Complete list of fixes and changes
- **FRONTEND_EXAMPLE.html** - Working HTML example

## 🔑 API Endpoints

### Authentication (No token required)
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login and get JWT token

### KYC (Requires `Authorization: Bearer <token>`)
- `GET /api/kyc/status` - Get current KYC status
- `POST /api/kyc/upload-document` - Upload ID document
- `POST /api/kyc/upload-selfie` - Upload selfie photo
- `POST /api/kyc/mfa/request` - Request OTP via email
- `POST /api/kyc/mfa/verify` - Verify OTP code

### Other Features
- Income tracking
- Expense management
- Bill scanning with OCR
- Analytics and reports
- Group expense splitting
- Debt tracking

## 🧪 Testing

### Automated Test
```bash
npm run test-kyc
```

### Manual Test with HTML
1. Start backend: `npm run dev`
2. Open `FRONTEND_EXAMPLE.html` in browser
3. Follow the step-by-step interface

### Test with curl
```bash
# Login
curl -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# Get KYC Status (replace YOUR_TOKEN)
curl -X GET http://localhost:5001/api/kyc/status \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 🔧 Frontend Integration

### Store Token After Login
```javascript
const response = await axios.post('http://localhost:5001/api/auth/login', {
  email: email,
  password: password
});

// Store token
const token = response.data.token;
localStorage.setItem('authToken', token);
```

### Include Token in Requests
```javascript
const token = localStorage.getItem('authToken');

// For GET requests
axios.get('http://localhost:5001/api/kyc/status', {
  headers: { 'Authorization': `Bearer ${token}` }
});

// For POST with file upload
const formData = new FormData();
formData.append('document', file);
formData.append('documentType', 'pan');

axios.post('http://localhost:5001/api/kyc/upload-document', formData, {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'multipart/form-data'
  }
});
```

## 🛠️ NPM Scripts

- `npm start` - Start with configuration check
- `npm run dev` - Start with auto-reload (nodemon)
- `npm run check` - Verify configuration
- `npm run test-kyc` - Test KYC flow
- `npm run verify` - Check if backend is running

## 🐛 Common Issues

**401 Unauthorized**
- Make sure you're including `Authorization: Bearer <token>` header
- Verify token is valid (login again if needed)

**OTP Not Received**
- Check backend console - OTP is always logged there
- SMTP configuration is optional for development

**File Upload Fails**
- Check file size (max 10MB)
- Ensure file is JPEG, JPG, PNG, or PDF
- Include Authorization header

## 📦 Dependencies

- **express** - Web framework
- **mongoose** - MongoDB ODM
- **jsonwebtoken** - JWT authentication
- **bcryptjs** - Password hashing
- **multer** - File upload handling
- **tesseract.js** - OCR text extraction
- **nodemailer** - Email sending
- **otp-generator** - OTP generation
- **cors** - CORS middleware

## 📝 License

MIT

---

For detailed integration instructions, see **KYC_INTEGRATION_GUIDE.md**
