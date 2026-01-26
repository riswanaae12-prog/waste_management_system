# Smart Waste Management System - Mobile App

A comprehensive Flutter-based mobile application for managing smart waste bins in urban areas. The system provides separate interfaces for Citizens and Truck Drivers with real-time bin tracking, issue reporting, and collection notifications.

## 📋 Project Overview

This is part of a larger Smart Waste Management System designed for an S8 B.Tech Computer Science project. The mobile application serves as the primary interface for two user roles:

- **Citizens**: Locate nearby bins, report issues, and track waste management in their area
- **Truck Drivers**: Receive real-time notifications for full bins and optimize collection routes

## 🏗️ Project Architecture

```
lib/
├── main.dart                 # Application entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── user.dart
│   ├── bin.dart
│   ├── issue.dart
│   ├── notification.dart
│   └── index.dart
├── services/                 # Business logic layer
│   ├── auth_service.dart
│   ├── bin_service.dart
│   ├── issue_service.dart
│   ├── notification_service.dart
│   ├── location_service.dart
│   └── index.dart
├── providers/                # State management (Provider pattern)
│   ├── auth_provider.dart
│   ├── bin_provider.dart
│   ├── issue_provider.dart
│   ├── notification_provider.dart
│   └── index.dart
└── screens/                  # UI layer
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── citizen_login_screen.dart
    ├── driver_login_screen.dart
    ├── home_screen.dart
    ├── citizen_home_screen.dart
    └── driver_home_screen.dart
```

## 🚀 Features

### Authentication Module
- Dual login system (Citizen & Driver)
- User registration with profile information
- JWT token-based authentication via Firebase Auth
- Password reset functionality
- Session management

### Citizen Features
- **Map View**: Display nearest smart bins with real-time status
- **Bin Details**: View fill level, waste type, and location
- **Issue Reporting**: Report problems (overflow, damage, sensor malfunction)
- **Photo Upload**: Attach images to issue reports
- **Issue Tracking**: Monitor status of reported issues
- **Profile Management**: Update personal information

### Driver Features
- **Full Bins Dashboard**: Real-time list of bins requiring collection
- **Notifications**: Push alerts when bins reach capacity
- **Collection Tracking**: Mark bins as emptied
- **Route Optimization**: View all full bins on map for efficient collection
- **Profile Management**: Driver information and contact details

## 🛠️ Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile development (Android & iOS)
- **Provider**: State management solution
- **Firebase**: Authentication and real-time database
- **Google Maps API**: Location and bin visualization
- **Firebase Cloud Messaging**: Push notifications

### Backend Integration
- **RESTful APIs**: HTTP communication with Node.js/Django backend
- **Cloud Firestore**: Real-time data synchronization
- **Firebase Authentication**: Secure user management

### Additional Libraries
- **geolocator**: Location services
- **image_picker**: Photo upload capability
- **dio**: HTTP client with interceptors
- **shared_preferences**: Local data persistence

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK (v3.0.0 or higher)
- Dart SDK (v3.0.0 or higher)
- Firebase project (Google Cloud Console)
- Android Studio or Xcode for emulator/device

### Step 1: Clone Repository
```bash
cd c:\Users\User\OneDrive\Documents\Devz
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Firebase Configuration
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Register Android and iOS apps in Firebase
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place files in respective directories:
   - Android: `android/app/`
   - iOS: `ios/Runner/`

### Step 4: Update Firebase Options
Update `lib/firebase_options.dart` with your Firebase project credentials:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: '1:YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);
```

### Step 5: Enable Location & Camera Permissions
Update platform-specific manifest files:

**Android (`android/app/src/main/AndroidManifest.xml`):**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

**iOS (`ios/Runner/Info.plist`):**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby bins</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to report issues</string>
```

### Step 6: Run Application
```bash
flutter run
```

## 📱 User Flows

### Citizen User Flow
1. **Login/Register** → Select "Citizen" role
2. **Home Screen** → View nearby bins on map
3. **Bin Details** → See fill level and waste type
4. **Report Issue** → Upload photo and describe problem
5. **Profile** → Update personal information or logout

### Driver User Flow
1. **Login/Register** → Select "Driver" role
2. **Dashboard** → View count of full bins ready for collection
3. **Full Bins List** → See location and fill level of bins
4. **Collection** → Mark bins as emptied after collection
5. **Notifications** → Receive alerts for newly full bins
6. **Profile** → Manage driver information

## 🗂️ Data Models

### User Model
```dart
User(
  id: String,
  name: String,
  email: String,
  phone: String,
  userType: 'citizen' | 'driver',
  profileImage: String?,
  createdAt: DateTime,
  isActive: bool,
)
```

### Bin Model
```dart
Bin(
  id: String,
  location: String,
  latitude: double,
  longitude: double,
  fillLevel: double (0-100),
  status: 'available' | 'full' | 'maintenance',
  wasteType: 'general' | 'organic' | 'recyclable' | 'hazardous',
  capacity: double,
  lastEmptied: DateTime,
  lastUpdated: DateTime,
  sensorsData: String?,
)
```

### Issue Model
```dart
Issue(
  id: String,
  userId: String,
  binId: String,
  title: String,
  description: String,
  issueType: 'overflow' | 'damage' | 'sensor_malfunction' | 'other',
  images: List<String>,
  status: 'open' | 'in_progress' | 'resolved',
  createdAt: DateTime,
  resolvedAt: DateTime?,
  resolution: String?,
)
```

### Notification Model
```dart
Notification(
  id: String,
  userId: String,
  title: String,
  body: String,
  type: 'bin_full' | 'issue_update' | 'collection_reminder' | 'system',
  data: Map<String, dynamic>,
  createdAt: DateTime,
  isRead: bool,
  relatedBinId: String?,
)
```

## 🔄 API Endpoints (Backend Integration)

The app communicates with the following backend services:

```
POST /api/auth/register          # User registration
POST /api/auth/login             # User login
GET  /api/bins                   # Fetch all bins
GET  /api/bins/nearby            # Fetch nearby bins (with lat/lng)
GET  /api/bins/:id               # Get bin details
PUT  /api/bins/:id               # Update bin status
POST /api/issues                 # Create issue report
GET  /api/issues/user/:userId    # Get user's issues
PUT  /api/issues/:id             # Update issue status
GET  /api/users/:id              # Get user profile
PUT  /api/users/:id              # Update user profile
POST /api/notifications/subscribe # Subscribe to topics
```

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Encrypted Data**: HTTPS for all API communications
- **Firebase Security Rules**: Firestore access control
- **Permission-based Access**: Location and camera permissions
- **Session Management**: Automatic logout on token expiration

## 📊 Firestore Collections Structure

```
users/
├── {userId}
│   ├── name, email, phone
│   ├── userType, profileImage
│   └── createdAt, isActive

bins/
├── {binId}
│   ├── location, latitude, longitude
│   ├── fillLevel, status, wasteType
│   ├── capacity, lastEmptied, lastUpdated
│   └── sensorsData

issues/
├── {issueId}
│   ├── userId, binId, title, description
│   ├── issueType, images, status
│   └── createdAt, resolvedAt, resolution

notifications/
├── {notificationId}
│   ├── userId, title, body, type
│   ├── data, createdAt, isRead
│   └── relatedBinId
```

## 🔔 Firebase Cloud Messaging

### Topics
- `user_{userId}`: User-specific notifications
- `driver_{driverId}`: Driver-specific alerts
- `all_drivers`: Broadcast to all drivers
- `bin_full`: Full bin notifications

### Notification Types
- **bin_full**: Sent when a bin reaches capacity (drivers only)
- **issue_update**: When an issue status changes
- **collection_reminder**: Reminder for pending collections
- **system**: General system announcements

## 🎨 UI/UX Design Guidelines

### Color Scheme
- **Primary Green**: #2E7D32 (Citizen theme)
- **Primary Blue**: #1976D2 (Driver theme)
- **Status Green**: #4CAF50 (Available)
- **Status Red**: #F44336 (Full/Emergency)
- **Status Orange**: #FF9800 (Maintenance)

### Navigation Structure
- **Citizen App**: Map Tab → Issues Tab → Profile Tab
- **Driver App**: Full Bins Tab → Profile Tab

## 🧪 Testing

### Unit Tests
Create tests for service classes and providers:
```bash
flutter test test/
```

### Widget Tests
Test individual screens and widgets:
```bash
flutter test test/widgets/
```

### Integration Tests
Test complete user flows:
```bash
flutter drive --target=test_driver/app.dart
```

## 📈 Performance Optimization

- **Lazy Loading**: Load bin data on demand
- **Real-time Sync**: Firestore listeners for updates
- **Image Optimization**: Compress images before upload
- **Caching**: Local storage for frequently accessed data
- **Provider Efficiency**: Selective rebuilds with Consumer widgets

## 🚀 Deployment

### Android Build
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS Build
```bash
flutter build ios --release
# Then deploy via Xcode or TestFlight
```

## 📝 Future Enhancements

- [ ] AI-based route optimization for drivers
- [ ] Predictive analytics for bin fill levels
- [ ] Multi-language support
- [ ] Offline functionality with sync
- [ ] Advanced map features (heatmaps, clusters)
- [ ] Analytics dashboard for admin
- [ ] Blockchain integration for transparency
- [ ] In-app chat support
- [ ] Gamification (points, rewards)
- [ ] AR view for bin locations

## 🐛 Known Issues & Limitations

- Map view currently uses simple list (replace with Google Maps implementation)
- Image upload requires backend image storage service
- Real-time notifications require active app or background service
- Location tracking requires continuous GPS (battery intensive)

## 📖 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Google Maps API](https://developers.google.com/maps/documentation)

## 👥 Team Information

- **Project**: Smart Waste Management System
- **Semester**: S8 (B.Tech Computer Science)
- **Type**: Dual-role mobile application with IoT integration

## 📄 License

This project is created for educational purposes as part of B.Tech Computer Science curriculum.

## 📞 Support & Contacts

For issues, feature requests, or questions, please contact the development team through the project management system.

---

**Last Updated**: January 18, 2026  
**Status**: Framework Complete - Ready for Backend Integration
