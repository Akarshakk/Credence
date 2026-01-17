# CRUDENCE UI/UX UPGRADE - IMPLEMENTATION PLAN

## ✅ COMPLETED: Theme System Update

### Design System Applied:
- **Border Radius**: Cards 20px, Buttons/Inputs/Chips 12px
- **Colors**: Purple accent (#8B5CF6), proper contrast ratios
- **Typography**: Inter for headings, Poppins for body
- **Spacing**: Screen padding 24px, vertical rhythm 8/16/24px
- **High Contrast**: All text meets WCAG AAA standards

### Files Modified:
1. ✅ `mobile/lib/config/theme.dart` - Complete theme overhaul

## 🔄 IN PROGRESS: Screen Updates

### Priority 1: KYC & Face Verification (CRITICAL)
**Files to Update:**
- `mobile/lib/screens/kyc/selfie_screen.dart` - Face capture with clear instructions
- `mobile/lib/screens/kyc/document_upload_screen.dart` - PAN/Aadhaar upload
- `mobile/lib/screens/kyc/kyc_screen.dart` - Main KYC flow
- `mobile/lib/screens/kyc/mfa_screen.dart` - MFA verification

**UI Enhancements Needed:**
- ✅ Clear on-screen instructions: "Only your own face is allowed"
- ✅ Visual framing guide for face capture
- ✅ Strong error messages for mismatches
- ✅ Prevent confusing states (loading/error/success)
- ✅ Ensure captured preview is clearly visible
- ✅ OCR text preview readable
- ✅ Dropdown selectors have visible text
- ❌ NO LOGIC CHANGES - UI ONLY

### Priority 2: Auth Screens
**Files to Update:**
- `mobile/lib/screens/auth/login_screen.dart`
- `mobile/lib/screens/auth/register_screen.dart`
- `mobile/lib/screens/auth/email_verification_screen.dart`

**UI Enhancements:**
- Clean fintech-style layout
- Clearly visible input labels & hints
- Proper keyboard avoidance
- Strong CTA contrast
- Error text clearly readable

### Priority 3: Dashboard & Home
**Files to Update:**
- `mobile/lib/screens/home/dashboard_tab.dart`
- `mobile/lib/screens/home/expenses_tab.dart`
- `mobile/lib/screens/home/profile_tab.dart`

**UI Enhancements:**
- Card-based hierarchy
- Clear typography scale
- Proper spacing (24px screen padding)
- Charts stay wired to existing data
- NO LOGIC CHANGES

### Priority 4: Transactions
**Files to Update:**
- `mobile/lib/screens/transaction_history_screen.dart`
- Transaction detail screens

**UI Enhancements:**
- Improve grouping clarity
- Fix text truncation/overflow
- Clear income vs expense color usage
- Ensure amounts always readable
- Clear status pills
- Prominent amount display
- Buttons clearly enabled/disabled visually

### Priority 5: Feature Selection
**Files to Update:**
- `mobile/lib/screens/feature_selection_screen.dart`
- `mobile/lib/screens/splash_screen.dart`

**UI Enhancements:**
- Brand update: "f-buddy" → "Crudence"
- Modern card-based layout
- Clear feature descriptions
- Smooth animations

## 🚫 STRICT RULES (NO EXCEPTIONS)

### DO NOT TOUCH:
- ❌ Backend APIs
- ❌ Firebase config
- ❌ Face matching algorithms
- ❌ OCR/KYC logic
- ❌ Controllers/Blocs/Providers
- ❌ Services (except UI-facing methods)
- ❌ Models
- ❌ Routes
- ❌ Directory structure

### ONLY MODIFY:
- ✅ UI layer Dart code
- ✅ Visual presentation
- ✅ Text labels & hints
- ✅ Colors & spacing
- ✅ Animations (UI-only)
- ✅ Layout & hierarchy

## 📋 BRAND UPDATE CHECKLIST

### Text Replacements (UI Only):
- [ ] "f-buddy" → "Crudence" in screen titles
- [ ] "f-buddy" → "Crudence" in labels
- [ ] "f-buddy" → "Crudence" in buttons
- [ ] "f-buddy" → "Crudence" in headings
- [ ] "f-buddy" → "Crudence" in helper text

### DO NOT RENAME:
- ❌ Package names
- ❌ Firebase keys
- ❌ Bundle IDs
- ❌ API parameters
- ❌ File/folder names

## 🎨 VISUAL FIXES NEEDED

### Dropdown & Input Visibility:
- [ ] Fix invisible dropdown selected values
- [ ] Fix low-contrast hint text
- [ ] Fix disabled fields appearing "empty"
- [ ] Ensure selected text always visible
- [ ] Error states clearly red
- [ ] Success states clearly green

### KYC Face Verification UX:
- [ ] Add visual frame guide for face capture
- [ ] Add clear instruction text overlay
- [ ] Add "Do not use photos/screens" warning
- [ ] Improve preview visibility
- [ ] Add confidence feedback (UI only)
- [ ] Clear error messages

## 📊 NEXT STEPS

1. **Immediate**: Update KYC screens (highest priority)
2. **Next**: Update auth screens
3. **Then**: Update dashboard & transactions
4. **Finally**: Polish animations & micro-interactions

## ✅ SAFETY CHECKLIST

Before committing each change:
- [ ] No DummyData added
- [ ] No backend edits
- [ ] No Firebase edits
- [ ] No API edits
- [ ] No logic refactor
- [ ] No KYC logic touched
- [ ] Only UI & UX improvements
- [ ] Text visibility issues fixed
- [ ] Dropdowns readable
- [ ] Face verification UX clarified
