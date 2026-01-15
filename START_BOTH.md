# 🚀 Start Backend & Frontend - Complete Setup Guide

## ✅ What Was Fixed

### Backend
- ✅ Enhanced authentication with better logging
- ✅ Auto-creates upload directories
- ✅ OTP always logged to console
- ✅ Better error messages

### Frontend (Flutter/Dart)
- ✅ Fixed API endpoint configuration
- ✅ Added proper platform detection (Android/iOS/Web)
- ✅ Enhanced logging for debugging
- ✅ Better error handling in KYC service

## 📋 Prerequisites

### Backend
- Node.js installed
- MongoDB running (or MongoDB Atlas connection)

### Frontend
- Flutter SDK installed
- Android Studio / Xcode (for mobile)
- Chrome (for web)

## 🚀 Step 1: Start Backend

### Option A: Windows PowerShell
```powershell
# Open PowerShell in project root
cd backend
npm install
npm run dev
```

### Option B: Windows CMD
```cmd
cd backend
npm install
npm run dev
```

### Expected Output:
```
✅ All checks passed! Server is ready to start.
🚀 Starting server...
📦 MongoDB Connected: cluster0...
🚀 F Buddy Server running on port 5001
```

### Verify Backend is Running:
Open another terminal:
```bash
cd backend
npm run verify
```

## 🚀 Step 2: Start Frontend (Flutter)

### For Web (Easiest for Testing)
```bash
# Open new terminal in project root
cd mobile
flutter pub get
flutter run -d chrome
```

### For Android Emulator
```bash
cd mobile
flutter pub get
flutter run
```

### For Physical Android Device
1. Enable USB debugging on your phone
2. Connect via USB
3. Run:
```bash
cd mobile
flutter pub get
flutter devices  # Check device is connected
flutter run
```

## 🔧 Configuration

### Backend URL Configuration

The frontend automatically detects the platform:

- **Web**: `http://localhost:5001/api`
- **Android Emulator**: `http://10.0.2.2:5001/api`
- **iOS Simulator**: `http://localhost:5001/api`
- **Physical Device**: You need to update `mobile/lib/config/constants.dart`

### For Physical Device Testing

1. Find your computer's local IP:
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`

2. Update `mobile/lib/config/constants.dart`:
```dart
static String get baseUrl {
  // Replace with your computer's IP
  return 'http://192.168.1.100:5001/api';
}
```

3. Make sure your phone and computer are on the same WiFi network

## 🧪 Testing the Connection

### Test 1: Backend Health Check
Open browser: `http://localhost:5001/api/health`

Should see:
```json
{
  "status": "OK",
  "message": "F Buddy API is running!"
}
```

### Test 2: Login from Flutter App
1. Start the app
2. Register a new user
3. Check backend console - you should see:
```
[AuthMiddleware] User authenticated: user@example.com
```

### Test 3: KYC Flow
1. Login to the app
2. Go to KYC section
3. Upload a document
4. Check backend console for:
   - File upload logs
   - OCR processing logs
5. Request OTP
6. **Check backend console for OTP code** (it's printed there)
7. Enter OTP in app

## 📱 Running Both Services

### Terminal 1 - Backend
```bash
cd backend
npm run dev
```

### Terminal 2 - Frontend (Web)
```bash
cd mobile
flutter run -d chrome
```

### Terminal 3 - Frontend (Android)
```bash
cd mobile
flutter run
```

## 🐛 Troubleshooting

### Backend Issues

**Port 5001 already in use:**
```bash
# Windows
netstat -ano | findstr :5001
taskkill /PID <PID> /F

# Or change port in backend/.env
PORT=5002
```

**MongoDB connection failed:**
- Check your `backend/.env` file
- Verify MongoDB URI is correct
- Ensure MongoDB is running

### Frontend Issues

**Cannot connect to backend:**
1. Check backend is running: `http://localhost:5001/api/health`
2. For Android emulator, use `10.0.2.2` instead of `localhost`
3. For physical device, use your computer's IP address
4. Check firewall settings

**Flutter build errors:**
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

**Platform detection issues:**
- Check `mobile/lib/config/constants.dart`
- Verify the baseUrl is correct for your platform

## 📊 Monitoring

### Backend Logs
Watch the backend terminal for:
- `[AuthMiddleware]` - Authentication logs
- `[KYC]` - KYC operation logs
- `[OCR]` - OCR processing logs
- `[MFA]` - **OTP codes are printed here**

### Frontend Logs
Watch the Flutter terminal for:
- `[API]` - API request logs
- `[KYC]` - KYC service logs

## 🔑 Important Notes

### OTP Testing
- OTP is **always logged in backend console**
- Look for lines like:
```
=============================================
[MFA] GENERATED OTP FOR user@example.com: 123456
=============================================
```

### Token Storage
- Tokens are stored securely using `flutter_secure_storage`
- Automatically included in all authenticated requests
- Check logs to verify token is being sent

### File Uploads
- Max file size: 10MB
- Supported formats: JPEG, JPG, PNG, PDF
- Files stored in `backend/uploads/kyc/`

## 📁 Project Structure

```
F-Buddy/
├── backend/                    # Node.js Backend
│   ├── src/
│   │   ├── routes/kyc.js      # KYC endpoints
│   │   ├── services/
│   │   │   ├── ocrService.js  # OCR processing
│   │   │   └── mfaService.js  # OTP generation
│   │   └── middleware/auth.js # JWT authentication
│   ├── uploads/kyc/           # Uploaded documents
│   └── .env                   # Configuration
│
└── mobile/                    # Flutter Frontend
    ├── lib/
    │   ├── config/
    │   │   └── constants.dart # API configuration
    │   ├── services/
    │   │   ├── api_service.dart    # HTTP client
    │   │   └── kyc_service.dart    # KYC API calls
    │   └── screens/kyc/       # KYC UI screens
    └── pubspec.yaml

```

## ✅ Verification Checklist

- [ ] Backend starts without errors
- [ ] MongoDB connects successfully
- [ ] Health endpoint responds: `http://localhost:5001/api/health`
- [ ] Flutter app builds successfully
- [ ] Can register/login from app
- [ ] Backend logs show authentication
- [ ] Can access KYC screens
- [ ] Document upload works
- [ ] OTP appears in backend console
- [ ] OTP verification works

## 🎯 Quick Commands Reference

### Backend
```bash
cd backend
npm run dev          # Start with auto-reload
npm run verify       # Check if running
npm run test-kyc     # Test KYC flow
```

### Frontend
```bash
cd mobile
flutter run -d chrome              # Run on web
flutter run                        # Run on connected device
flutter run -d <device-id>         # Run on specific device
flutter devices                    # List available devices
flutter clean && flutter pub get   # Clean build
```

## 📚 Additional Documentation

- `backend/QUICK_START.md` - Backend quick reference
- `backend/KYC_INTEGRATION_GUIDE.md` - API integration details
- `backend/FRONTEND_EXAMPLE.html` - HTML test interface
- `backend/FIXES_SUMMARY.md` - Complete list of changes

## 🆘 Getting Help

If you encounter issues:

1. **Check backend console** - Most issues show up here
2. **Check Flutter console** - Look for error messages
3. **Verify network connectivity** - Ping backend from browser
4. **Check firewall** - Ensure port 5001 is not blocked
5. **Review logs** - Both backend and frontend log extensively

## 🎉 Success!

When everything is working, you should see:

**Backend Terminal:**
```
🚀 F Buddy Server running on port 5001
[AuthMiddleware] User authenticated: user@example.com
[KYC] Getting status...
[MFA] GENERATED OTP: 123456
```

**Flutter Terminal:**
```
[API] POST http://localhost:5001/api/auth/login
[API] Response: 200
[KYC] Getting status with token: eyJhbGciOiJIUzI1NiIs...
[KYC] Status data: {status: VERIFIED, step: 3}
```

Now you're ready to test the complete KYC flow! 🚀
