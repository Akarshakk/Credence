# 🚀 Quick Start Guide - Fixed Backend

## What Was Fixed

### 1. **401 Unauthorized Errors** ✅
- Enhanced authentication middleware with better logging
- Added support for multiple token header formats
- Clear error messages showing what's missing

### 2. **File Upload Issues** ✅
- Auto-creates upload directories on startup
- Increased file size limit to 10MB
- Better error handling for file operations

### 3. **OCR Processing** ✅
- Enhanced logging for debugging
- Better document validation
- Improved error messages

### 4. **OTP/MFA System** ✅
- OTP always logged to console for testing
- Email sending is optional (works without SMTP)
- Better error handling and debugging

## Start the Backend

### Step 1: Install Dependencies (if not done)
```bash
cd backend
npm install
```

### Step 2: Check Configuration
```bash
npm run check
```

This will verify:
- Environment variables are set
- Upload directories exist
- All dependencies are installed

### Step 3: Start the Server
```bash
npm run dev
```

You should see:
```
🔍 Running Backend Startup Checks...
✅ All checks passed! Server is ready to start.
🚀 Starting server...
📦 MongoDB Connected: cluster0...
🚀 F Buddy Server running on port 5001
```

## Test the Backend

### Option 1: Use the Test Script
```bash
npm run test-kyc
```

This will:
- Register a test user
- Login
- Check KYC status
- Upload a document
- Request OTP
- Show you the complete flow

### Option 2: Use the HTML Test Page
1. Start the backend: `npm run dev`
2. Open `FRONTEND_EXAMPLE.html` in your browser
3. Click through each step
4. Watch the backend console for OTP codes

### Option 3: Test with curl
```bash
# Login
curl -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123456"}'

# Save the token from response, then:
curl -X GET http://localhost:5001/api/kyc/status \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Fix Your Frontend

The main issue is that your frontend is not sending the JWT token. Here's what you need to do:

### 1. Store Token After Login
```javascript
// After successful login
const response = await axios.post('http://localhost:5001/api/auth/login', {
  email: email,
  password: password
});

// IMPORTANT: Store this token!
const token = response.data.token;
localStorage.setItem('authToken', token);
```

### 2. Include Token in All KYC Requests
```javascript
// Get token
const token = localStorage.getItem('authToken');

// Include in every request
const config = {
  headers: {
    'Authorization': `Bearer ${token}`
  }
};

// Example: Check status
axios.get('http://localhost:5001/api/kyc/status', config);

// Example: Upload document
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

## Common Issues

### "Not authorized - No token provided"
**Fix**: Add `Authorization: Bearer <token>` header to your request

### "Not authorized - Invalid token"
**Fix**: Login again to get a fresh token

### OTP not received
**Fix**: Check the backend console - OTP is always printed there

### Document upload fails
**Fix**: 
- Check file size (max 10MB)
- Ensure file is image or PDF
- Include Authorization header

## File Structure

```
backend/
├── src/
│   ├── controllers/
│   │   └── kycController.js      ✅ Fixed
│   ├── middleware/
│   │   └── auth.js                ✅ Fixed
│   ├── routes/
│   │   └── kyc.js                 ✅ Fixed
│   ├── services/
│   │   ├── ocrService.js          ✅ Fixed
│   │   ├── mfaService.js          ✅ Fixed
│   │   └── faceService.js
│   └── server.js                  ✅ Enhanced
├── uploads/kyc/                   ✅ Auto-created
├── startup-check.js               ✅ New
├── test-kyc-flow.js               ✅ New
├── FRONTEND_EXAMPLE.html          ✅ New
├── KYC_INTEGRATION_GUIDE.md       ✅ New
└── QUICK_START.md                 ✅ This file
```

## API Endpoints

All KYC endpoints require `Authorization: Bearer <token>` header:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/login` | POST | Login (get token) |
| `/api/kyc/status` | GET | Get KYC status |
| `/api/kyc/upload-document` | POST | Upload ID document |
| `/api/kyc/upload-selfie` | POST | Upload selfie |
| `/api/kyc/mfa/request` | POST | Request OTP |
| `/api/kyc/mfa/verify` | POST | Verify OTP |

## Environment Variables

Your `.env` file should have:
```env
PORT=5001
MONGODB_URI=your_mongodb_uri
JWT_SECRET=your_secret_key
JWT_EXPIRE=30d

# Optional - for email OTP
SMTP_EMAIL=your_email@gmail.com
SMTP_PASSWORD=your_app_password
```

## Next Steps

1. ✅ Start backend: `npm run dev`
2. ✅ Test backend: `npm run test-kyc` or open `FRONTEND_EXAMPLE.html`
3. ✅ Update frontend to include Authorization header
4. ✅ Test complete flow
5. ✅ Deploy!

## Need Help?

- Check `KYC_INTEGRATION_GUIDE.md` for detailed integration steps
- Look at `FRONTEND_EXAMPLE.html` for working code examples
- Run `npm run test-kyc` to verify backend is working
- Check backend console for detailed logs and OTP codes

## Debug Mode

The backend now logs everything:
- Authentication attempts
- Token validation
- File uploads
- OCR processing
- OTP generation
- All errors with details

Just watch the console while testing!
