# KYC Backend Integration Guide

## Fixed Issues

### 1. Authentication (401 Errors)
The 401 errors were caused by missing or incorrect JWT tokens. The backend now:
- Provides better error messages showing what's missing
- Logs authentication attempts for debugging
- Supports both `Authorization: Bearer <token>` and `x-auth-token` headers

### 2. File Upload Directory
- Automatically creates `uploads/kyc/` directory if it doesn't exist
- Increased file size limit to 10MB
- Better error handling for file uploads

### 3. OCR Service
- Enhanced logging for debugging
- Better error messages
- Improved document validation for all document types

### 4. MFA/OTP Service
- OTP is always logged to console for testing
- Email sending is optional (works without SMTP configured)
- Better error handling and logging

## Frontend Integration Steps

### Step 1: Ensure Token is Stored After Login

```javascript
// After successful login/register
const response = await axios.post('http://localhost:5001/api/auth/login', {
  email: 'user@example.com',
  password: 'password123'
});

// Store the token
const token = response.data.token;
localStorage.setItem('authToken', token);
```

### Step 2: Include Token in All KYC Requests

```javascript
// Get token from storage
const token = localStorage.getItem('authToken');

// Include in all requests
const config = {
  headers: {
    'Authorization': `Bearer ${token}`
  }
};

// Example: Get KYC Status
axios.get('http://localhost:5001/api/kyc/status', config);
```

### Step 3: Document Upload with Token

```javascript
const uploadDocument = async (file, documentType) => {
  const token = localStorage.getItem('authToken');
  
  const formData = new FormData();
  formData.append('document', file);
  formData.append('documentType', documentType); // 'pan', 'aadhaar', 'passport', 'driving_license'
  
  try {
    const response = await axios.post(
      'http://localhost:5001/api/kyc/upload-document',
      formData,
      {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'multipart/form-data'
        }
      }
    );
    
    console.log('Document uploaded:', response.data);
    return response.data;
  } catch (error) {
    console.error('Upload failed:', error.response?.data);
    throw error;
  }
};
```

### Step 4: Request OTP

```javascript
const requestOTP = async () => {
  const token = localStorage.getItem('authToken');
  
  try {
    const response = await axios.post(
      'http://localhost:5001/api/kyc/mfa/request',
      {},
      {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      }
    );
    
    console.log('OTP sent:', response.data.message);
    // Check backend console for OTP (in development)
    return response.data;
  } catch (error) {
    console.error('OTP request failed:', error.response?.data);
    throw error;
  }
};
```

### Step 5: Verify OTP

```javascript
const verifyOTP = async (otp) => {
  const token = localStorage.getItem('authToken');
  
  try {
    const response = await axios.post(
      'http://localhost:5001/api/kyc/mfa/verify',
      { otp: otp },
      {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      }
    );
    
    console.log('KYC Verified:', response.data);
    return response.data;
  } catch (error) {
    console.error('OTP verification failed:', error.response?.data);
    throw error;
  }
};
```

## Complete KYC Flow Example

```javascript
// 1. User logs in
const loginResponse = await axios.post('http://localhost:5001/api/auth/login', {
  email: 'user@example.com',
  password: 'password123'
});
const token = loginResponse.data.token;
localStorage.setItem('authToken', token);

// 2. Check KYC status
const statusResponse = await axios.get(
  'http://localhost:5001/api/kyc/status',
  { headers: { 'Authorization': `Bearer ${token}` } }
);
console.log('Current KYC Status:', statusResponse.data);

// 3. Upload document
const formData = new FormData();
formData.append('document', documentFile);
formData.append('documentType', 'pan');

const uploadResponse = await axios.post(
  'http://localhost:5001/api/kyc/upload-document',
  formData,
  {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'multipart/form-data'
    }
  }
);

// 4. Upload selfie (if document was valid)
if (uploadResponse.data.data.isValid) {
  const selfieFormData = new FormData();
  selfieFormData.append('selfie', selfieFile);
  
  await axios.post(
    'http://localhost:5001/api/kyc/upload-selfie',
    selfieFormData,
    {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'multipart/form-data'
      }
    }
  );
}

// 5. Request OTP
await axios.post(
  'http://localhost:5001/api/kyc/mfa/request',
  {},
  { headers: { 'Authorization': `Bearer ${token}` } }
);

// Check backend console for OTP in development

// 6. Verify OTP
const verifyResponse = await axios.post(
  'http://localhost:5001/api/kyc/mfa/verify',
  { otp: '123456' },
  { headers: { 'Authorization': `Bearer ${token}` } }
);

console.log('KYC Complete:', verifyResponse.data);
```

## Testing the Backend

### Option 1: Use the Test Script

```bash
cd backend
node test-kyc-flow.js
```

This will test all endpoints and show you exactly what's working.

### Option 2: Manual Testing with curl

```bash
# 1. Register
curl -X POST http://localhost:5001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"test123"}'

# 2. Login (save the token from response)
curl -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# 3. Get KYC Status (replace YOUR_TOKEN)
curl -X GET http://localhost:5001/api/kyc/status \
  -H "Authorization: Bearer YOUR_TOKEN"

# 4. Request OTP
curl -X POST http://localhost:5001/api/kyc/mfa/request \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Common Issues & Solutions

### Issue: "Not authorized - No token provided"
**Solution**: Make sure you're including the Authorization header with Bearer token

### Issue: "Not authorized - Invalid token"
**Solution**: Token might be expired or incorrect. Login again to get a fresh token

### Issue: "User not found"
**Solution**: The user ID in the token doesn't exist. Register/login again

### Issue: OTP not received in email
**Solution**: Check the backend console - OTP is always logged there for development

### Issue: Document upload fails
**Solution**: 
- Check file size (max 10MB)
- Ensure file is JPEG, JPG, PNG, or PDF
- Verify token is included in request

## Environment Variables

Make sure your `.env` file has:

```env
PORT=5001
NODE_ENV=development
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_secret_key
JWT_EXPIRE=30d

# Optional - for email OTP delivery
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_EMAIL=your_email@gmail.com
SMTP_PASSWORD=your_app_password
```

## API Endpoints Summary

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| POST | `/api/auth/register` | No | Register new user |
| POST | `/api/auth/login` | No | Login user |
| GET | `/api/kyc/status` | Yes | Get KYC status |
| POST | `/api/kyc/upload-document` | Yes | Upload ID document |
| POST | `/api/kyc/upload-selfie` | Yes | Upload selfie |
| POST | `/api/kyc/mfa/request` | Yes | Request OTP |
| POST | `/api/kyc/mfa/verify` | Yes | Verify OTP |

## Next Steps

1. Start the backend: `npm start` or `npm run dev`
2. Test with the test script: `node test-kyc-flow.js`
3. Update your frontend to include the Authorization header
4. Test the complete flow from frontend
5. Check backend console for detailed logs and OTP codes

## Support

If you're still facing issues:
1. Check backend console for detailed error logs
2. Verify MongoDB is connected
3. Ensure all dependencies are installed: `npm install`
4. Try the test script to isolate frontend vs backend issues
