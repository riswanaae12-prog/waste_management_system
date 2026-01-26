# Quick Start Guide - Smart Waste Management Mobile App

## 🚀 5-Minute Setup

### 1. Prerequisites Check
```bash
flutter --version  # Should be 3.0.0 or higher
dart --version     # Should be 3.0.0 or higher
```

### 2. Get Dependencies
```bash
cd c:\Users\User\OneDrive\Documents\Devz
flutter pub get
```

### 3. Configure Firebase
- Create Firebase project: https://console.firebase.google.com
- Create two apps (Android and iOS)
- Download credentials and place in respective folders
- Update `lib/firebase_options.dart` with your credentials

### 4. Run the App
```bash
flutter run
```

---

## 🎯 Project Structure at a Glance

```
lib/
├── main.dart              # Entry point - routing, theme setup
├── models/                # Data classes (User, Bin, Issue, etc.)
├── services/              # Business logic (Auth, Bin, Issue, etc.)
├── providers/             # State management (Provider pattern)
└── screens/               # UI screens (Login, Home, etc.)
```

---

## 👤 User Roles & Flows

### Citizen Role
```
Login → Home (Map View) → View Nearby Bins → Report Issues → Profile
```

**Key Files**: 
- [citizen_login_screen.dart](lib/screens/citizen_login_screen.dart)
- [citizen_home_screen.dart](lib/screens/citizen_home_screen.dart)

### Driver Role
```
Login → Dashboard (Full Bins) → Collect Bin → Mark as Done → Profile
```

**Key Files**:
- [driver_login_screen.dart](lib/screens/driver_login_screen.dart)
- [driver_home_screen.dart](lib/screens/driver_home_screen.dart)

---

## 🔧 Key Classes & Providers

### Authentication Provider
```dart
// Access current user
final user = context.read<AuthProvider>().user;
final isDriver = context.read<AuthProvider>().isDriver;

// Login
await authProvider.login(email, password);

// Register
await authProvider.register(email, password, name, phone, userType);
```

### Bin Provider
```dart
// Get nearby bins
await binProvider.fetchNearbyBins();
final bins = binProvider.nearbyBins;

// Get full bins (for drivers)
await binProvider.fetchFullBins();
final fullBins = binProvider.fullBins;
```

### Issue Provider
```dart
// Report issue
await issueProvider.createIssue(
  userId, binId, title, description, issueType, imageUrls
);

// Get user issues
final issues = issueProvider.userIssues;
```

---

## 📱 Screen Navigation

```
LoginScreen
├── CitizenLoginScreen → CitizenHomeScreen
│   ├── Map Tab (nearby bins)
│   ├── Issues Tab (report & track)
│   └── Profile Tab (user info)
│
└── DriverLoginScreen → DriverHomeScreen
    ├── Full Bins Tab (collection list)
    └── Profile Tab (driver info)
```

---

## 🗄️ Firebase Services Used

- **Authentication**: User login/registration
- **Firestore**: Real-time database for bins, issues, notifications
- **Cloud Messaging**: Push notifications for drivers
- **Storage**: Image uploads (when implementing)

---

## 📊 Data Models Overview

| Model | Purpose | Key Fields |
|-------|---------|-----------|
| **User** | User account | id, name, email, userType |
| **Bin** | Smart waste bin | id, location, fillLevel, status |
| **Issue** | Problem report | id, binId, title, issueType, status |
| **Notification** | Alert/message | id, title, type, isRead |

---

## ⚠️ Common Setup Issues & Fixes

### Issue: "No Firebase project configured"
```bash
flutterfire configure --project=your-project-id
```

### Issue: "Location permission denied"
- Grant permissions in device settings
- Or call `LocationService().requestLocationPermission()` first

### Issue: "Imports not found"
```bash
flutter pub get
flutter pub upgrade
```

### Issue: "Gradle build fails"
```bash
flutter clean
./gradlew clean  # On Windows: gradlew clean
flutter pub get
flutter run
```

---

## 🎨 Customization

### Change App Theme
Edit `lib/main.dart`:
```dart
theme: ThemeData(
  primarySwatch: Colors.blue,  // Change primary color
  useMaterial3: true,
),
```

### Update Firebase Config
Edit `lib/firebase_options.dart`:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_KEY',
  appId: 'YOUR_ID',
  // ... other fields
);
```

### Change Login Welcome Message
Edit respective login screen files:
```dart
const Text(
  'Your custom message',
  style: TextStyle(fontSize: 24),
)
```

---

## 🧪 Testing the App

### Test Login Flow
1. Click role selection (Citizen/Driver)
2. Click Register or Login
3. Fill in credentials
4. Check if home screen appears

### Test Bin Display (Citizen)
1. Login as citizen
2. Go to Map tab
3. Verify bins are displayed

### Test Full Bins (Driver)
1. Login as driver
2. Dashboard shows count of full bins
3. List displays actual full bins

---

## 📲 Install on Device

### Android
```bash
flutter install  # Install APK on connected device
```

### iOS
```bash
flutter run -v  # Run on connected iOS device
```

---

## 🔐 Security Checklist

- [ ] Firebase security rules configured
- [ ] API endpoints use HTTPS
- [ ] Sensitive data not logged
- [ ] User tokens handled securely
- [ ] Permissions requested appropriately

---

## 📈 Next Steps After Setup

1. **Integrate Google Maps** - Replace bin list with actual map
2. **Add Image Upload** - For issue reporting with photos
3. **Setup Real-time Updates** - Firestore listeners for live data
4. **Configure Push Notifications** - FCM setup for drivers
5. **Add Analytics** - Track user interactions
6. **Implement Blockchain** - For transparency (optional)

See [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) for detailed instructions.

---

## 💡 Pro Tips

- Use `flutter run -v` for verbose output and debugging
- Use `flutter devices` to see available emulators/devices
- Use `flutter logs` to view app logs
- Use `flutter pub upgrade` to update dependencies
- Use `flutter pub outdated` to check for updates

---

## 🆘 Need Help?

1. Check [README.md](README.md) for full documentation
2. Review [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) for advanced features
3. Check Flutter docs: https://flutter.dev/docs
4. Check Firebase docs: https://firebase.flutter.dev/

---

## 📞 Quick Reference

| Task | File | Method |
|------|------|--------|
| Login/Register | `auth_provider.dart` | `login()` / `register()` |
| Get bins | `bin_provider.dart` | `fetchNearbyBins()` |
| Report issue | `issue_provider.dart` | `createIssue()` |
| Handle location | `location_service.dart` | `getCurrentLocation()` |

---

**Status**: Ready to Deploy  
**Last Updated**: January 18, 2026  
**Framework Version**: Flutter 3.0.0+
