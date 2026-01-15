# 🚀 F-Buddy Complete Startup Guide

## 🎯 Quick Start (Easiest Way)

### Step 1: Start Backend
**Double-click:** `start-backend.bat`

Or manually:
```bash
cd backend
npm install
npm run dev
```

### Step 2: Start Frontend (Choose One)

#### Option A: Web (Recommended for Testing)
**Double-click:** `start-frontend-web.bat`

Or manually:
```bash
cd mobile
flutter pub get
flutter run -d chrome
```

#### Option B: Android
**Double-click:** `start-frontend-android.bat`

Or manually:
```bash
cd mobile
flutter pub get
flutter run
```

## ✅ What You'll See

### Backend Terminal
```
🔍 Running Backend Startup Checks...
✅ All checks passed! Server is ready to start.
🚀 Starting server...
📦 MongoDB Connected: cluster0...
🚀 F Buddy Server running on port 5001
```

### Frontend Terminal
```
Launching lib/main.dart on Chrome in debug mode...
Building application for the web...
Application finished.
```

## 🧪 Test the Connection

### 1. Test Backend
Open browser: http://localhost:5001/api/health

Should see:
```json
{"status":"OK","message":"F Buddy API is running!"}
```

### 2. Test Frontend
- App should open automatically
- Register a new user
- Login
- Go to KYC section

### 3. Test KYC Flow
1. Upload a document (any image)
2. Backend will process with OCR
3. Request OTP
4. **Check backend terminal for OTP code**
5. Enter OTP in app
6. Complete verification

## 🔑 Important: OTP Testing

**OTP codes are printed in the backend terminal!**

Look for:
```
=============================================
[MFA] GENERATED OTP FOR user@example.com: 123456
[MFA] User ID: 507f1f77bcf86cd799439011
[MFA] Expires in 10 minutes
=============================================
```

Copy the 6-digit code and paste it in the app.

## 📱 Platform-Specific Setup

### For Web
- No additional setup needed
- Backend URL: `http://localhost:5001/api`

### For Android Emulator
- Start Android emulator first
- Backend URL: `http://10.0.2.2:5001/api` (automatically configured)

### For Physical Android Device
1. Find your computer's IP address:
   ```bash
   ipconfig
   ```
   Look for "IPv4 Address" (e.g., 192.168.1.100)

2. Update `mobile/lib/config/constants.dart`:
   ```dart
   static String get baseUrl {
     return 'http://YOUR_IP_HERE:5001/api';
   }
   ```

3. Ensure phone and computer are on same WiFi

## 🐛 Troubleshooting

### Backend Won't Start

**Problem:** Port 5001 already in use
```bash
# Find and kill process using port 5001
netstat -ano | findstr :5001
taskkill /PID <PID> /F
```

**Problem:** MongoDB connection failed
- Check `backend/.env` file
- Verify MONGODB_URI is correct

### Frontend Won't Start

**Problem:** Flutter not found
```bash
flutter doctor
```
Install Flutter SDK if needed

**Problem:** Dependencies error
```bash
cd mobile
flutter clean
flutter pub get
```

### Cannot Connect to Backend

**Problem:** 401 Unauthorized
- Make sure you're logged in
- Token is automatically stored and sent

**Problem:** Network error
- Check backend is running: http://localhost:5001/api/health
- For Android emulator, verify using `10.0.2.2`
- For physical device, use computer's IP address

## 📊 Monitoring

### Backend Logs Show:
- ✅ Authentication attempts
- ✅ API requests
- ✅ File uploads
- ✅ OCR processing
- ✅ **OTP codes**
- ✅ All errors

### Frontend Logs Show:
- ✅ API calls
- ✅ Response status
- ✅ KYC operations
- ✅ Errors

## 🔧 Configuration Files

### Backend: `backend/.env`
```env
PORT=5001
MONGODB_URI=your_mongodb_uri
JWT_SECRET=your_secret_key
JWT_EXPIRE=30d

# Optional - for email OTP
SMTP_EMAIL=your_email@gmail.com
SMTP_PASSWORD=your_app_password
```

### Frontend: `mobile/lib/config/constants.dart`
```dart
static String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:5001/api';
  }
  return 'http://10.0.2.2:5001/api'; // Android emulator
}
```

## 📁 Project Structure

```
F-Buddy/
├── start-backend.bat              ← Double-click to start backend
├── start-frontend-web.bat         ← Double-click for web app
├── start-frontend-android.bat     ← Double-click for Android
├── START_BOTH.md                  ← Detailed setup guide
├── README_STARTUP.md              ← This file
│
├── backend/                       ← Node.js Backend
│   ├── src/
│   ├── uploads/kyc/              ← Uploaded documents
│   ├── .env                      ← Configuration
│   └── package.json
│
└── mobile/                        ← Flutter Frontend
    ├── lib/
    │   ├── config/constants.dart ← API configuration
    │   ├── services/             ← API services
    │   └── screens/              ← UI screens
    └── pubspec.yaml
```

## ✅ Verification Checklist

Before testing, verify:

- [ ] Backend starts without errors
- [ ] MongoDB connects successfully
- [ ] Health endpoint works: http://localhost:5001/api/health
- [ ] Flutter app builds successfully
- [ ] Can register/login
- [ ] Backend logs show authentication
- [ ] Can access KYC screens
- [ ] Document upload works
- [ ] OTP appears in backend console
- [ ] OTP verification works

## 🎯 Quick Commands

### Backend
```bash
cd backend
npm run dev          # Start server
npm run verify       # Check if running
npm run test-kyc     # Test KYC flow
npm run check        # Verify configuration
```

### Frontend
```bash
cd mobile
flutter run -d chrome              # Web
flutter run                        # Android/iOS
flutter devices                    # List devices
flutter clean && flutter pub get   # Clean build
```

## 📚 Additional Documentation

- **START_BOTH.md** - Complete setup guide with troubleshooting
- **backend/QUICK_START.md** - Backend quick reference
- **backend/KYC_INTEGRATION_GUIDE.md** - API integration details
- **backend/FRONTEND_EXAMPLE.html** - HTML test interface

## 🎉 Success Indicators

### Backend Running Successfully:
```
✅ All checks passed!
🚀 F Buddy Server running on port 5001
📦 MongoDB Connected
```

### Frontend Running Successfully:
```
✓ Built build/web/main.dart.js
Application finished.
```

### Connection Working:
```
Backend: [AuthMiddleware] User authenticated: user@example.com
Frontend: [API] Response: 200
```

## 🆘 Need Help?

1. Check backend console for errors
2. Check Flutter console for errors
3. Verify backend health: http://localhost:5001/api/health
4. Review logs in both terminals
5. See START_BOTH.md for detailed troubleshooting

## 🔐 Security Notes

- JWT tokens stored securely using flutter_secure_storage
- Tokens automatically included in authenticated requests
- OTP expires in 10 minutes
- Files stored locally in backend/uploads/kyc/

## 🚀 Ready to Go!

1. **Start backend** → `start-backend.bat`
2. **Start frontend** → `start-frontend-web.bat`
3. **Register/Login** in the app
4. **Test KYC flow** with any image
5. **Check backend console** for OTP
6. **Complete verification**

Happy coding! 🎉
