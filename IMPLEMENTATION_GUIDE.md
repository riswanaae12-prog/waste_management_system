# Smart Waste Management - Flutter Implementation Guide

## 📚 Complete Implementation Checklist

### ✅ Phase 1: Foundation (Completed)
- [x] Project structure setup
- [x] Firebase configuration
- [x] Model classes (User, Bin, Issue, Notification)
- [x] Service layer (Auth, Bin, Issue, Notification, Location)
- [x] Provider setup (State management)
- [x] Authentication screens (Citizen & Driver login/register)
- [x] Home screens (Citizen & Driver dashboards)

### 📋 Phase 2: Enhanced Features (Ready to Implement)

#### 2.1 Map Integration
```dart
// Planned implementation in citizen_home_screen.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Features:
// - Display all nearby bins with markers
// - Color-coded markers (Green=Available, Red=Full)
// - Click on marker to view bin details
// - Calculate distance from user location
// - Show collection zones
```

#### 2.2 Issue Reporting Module
```dart
// New file: screens/report_issue_screen.dart
// Features:
// - Select issue type (overflow, damage, sensor malfunction)
// - Write description
// - Take/upload photos
// - Auto-fill bin location
// - Submit to backend
// - Confirmation notification
```

#### 2.3 Real-time Notifications
```dart
// Enhanced: services/notification_service.dart
// Features:
// - Handle FCM messages in foreground/background
// - Local notification display
// - Notification routing based on user role
// - Notification center/history
```

#### 2.4 Location Tracking
```dart
// Already implemented: services/location_service.dart
// Next steps:
// - Get user permission on app start
// - Continuous location updates for drivers
// - Store collection history
// - Show recent locations
```

### 🎯 Phase 3: Advanced Features (Future Enhancement)

#### 3.1 Route Optimization
```dart
// Planned: providers/route_provider.dart
// Features:
// - Calculate optimal delivery route for multiple bins
// - Real-time traffic integration
// - ETA calculation
// - Route history and analytics
```

#### 3.2 Analytics Dashboard
```dart
// Planned: screens/analytics_screen.dart
// Features:
// - Bins filled per day
// - Most problematic bins
// - Average collection time
// - Issue resolution rate
```

#### 3.3 Blockchain Integration
```dart
// Planned: services/blockchain_service.dart
// Features:
// - Record bin emptying on blockchain
// - Transparent issue tracking
// - Smart contract for collection verification
```

## 🔧 Implementation Steps

### Step 1: Setup Development Environment

```bash
# Update Flutter
flutter upgrade

# Create Firebase project
# - Go to https://firebase.google.com
# - Create new project
# - Enable Firestore, Authentication, Messaging

# Get dependencies
flutter pub get

# Generate Android/iOS files
flutterfire configure
```

### Step 2: Implement Google Maps

```dart
// File: lib/screens/citizen_map_screen.dart
// Replace the current ListView with Google Maps

import 'package:google_maps_flutter/google_maps_flutter.dart';

class CitizenMapScreen extends StatefulWidget {
  const CitizenMapScreen({Key? key}) : super(key: key);

  @override
  State<CitizenMapScreen> createState() => _CitizenMapScreenState();
}

class _CitizenMapScreenState extends State<CitizenMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadBins();
  }

  void _loadBins() async {
    final binProvider = context.read<BinProvider>();
    for (final bin in binProvider.nearbyBins) {
      _markers.add(
        Marker(
          markerId: MarkerId(bin.id),
          position: LatLng(bin.latitude, bin.longitude),
          infoWindow: InfoWindow(title: bin.location),
          icon: await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(),
            _getMarkerIcon(bin.status),
          ),
          onTap: () => binProvider.selectBin(bin.id),
        ),
      );
    }
    setState(() {});
  }

  String _getMarkerIcon(String status) {
    if (status == 'full') return 'assets/icons/marker_red.png';
    if (status == 'maintenance') return 'assets/icons/marker_orange.png';
    return 'assets/icons/marker_green.png';
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: CameraPosition(
        target: LatLng(37.7749, -122.4194), // Default: San Francisco
        zoom: 15,
      ),
      markers: _markers,
    );
  }
}
```

### Step 3: Add Issue Reporting Feature

```dart
// File: lib/screens/report_issue_screen.dart

class ReportIssueScreen extends StatefulWidget {
  final String binId;
  const ReportIssueScreen({required this.binId, Key? key}) : super(key: key);

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<XFile> _selectedImages = [];
  String _selectedIssueType = 'overflow';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Issue')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Issue Type Dropdown
              DropdownButton<String>(
                value: _selectedIssueType,
                items: ['overflow', 'damage', 'sensor_malfunction', 'other']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedIssueType = value!),
              ),
              
              // Title Input
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Issue Title'),
              ),
              
              // Description Input
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 5,
              ),
              
              // Image Upload
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo),
                label: const Text('Add Photos'),
              ),
              
              // Display selected images
              ListView.builder(
                shrinkWrap: true,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) => Image.file(
                  File(_selectedImages[index].path),
                  height: 100,
                ),
              ),
              
              // Submit Button
              ElevatedButton(
                onPressed: _submitIssue,
                child: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final images = await picker.pickMultiImage();
    setState(() => _selectedImages.addAll(images));
  }

  Future<void> _submitIssue() async {
    final issueProvider = context.read<IssueProvider>();
    final authProvider = context.read<AuthProvider>();
    
    // Upload images first
    final imageUrls = <String>[];
    for (final image in _selectedImages) {
      // TODO: Implement image upload to Firebase Storage
      // imageUrls.add(uploadedUrl);
    }
    
    final success = await issueProvider.createIssue(
      userId: authProvider.user!.id,
      binId: widget.binId,
      title: _titleController.text,
      description: _descriptionController.text,
      issueType: _selectedIssueType,
      imageUrls: imageUrls,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue reported successfully')),
      );
      Navigator.pop(context);
    }
  }
}
```

### Step 4: Implement Firebase Cloud Storage

```dart
// File: lib/services/storage_service.dart

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(String userId, String filePath) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('issues/$userId/$fileName');
      
      await ref.putFile(File(filePath));
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}
```

### Step 5: Setup Push Notifications

```dart
// File: lib/services/notification_service.dart (Enhanced)

Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  
  if (message.notification != null) {
    // Show notification
    // Update local database if needed
  }
}

void setupFlutterNotifications() async {
  // Set up notification channels for Android
  // Configure notification appearance
  // Handle notification taps
}
```

### Step 6: Database Schema

```javascript
// Firestore collection structure

// users/{userId}
{
  email: string
  name: string
  phone: string
  profileImage: string (optional)
  userType: "citizen" | "driver"
  createdAt: timestamp
  isActive: boolean
  fcmToken: string
  lastActive: timestamp
}

// bins/{binId}
{
  location: string
  latitude: number
  longitude: number
  fillLevel: number (0-100)
  status: "available" | "full" | "maintenance"
  wasteType: "general" | "organic" | "recyclable" | "hazardous"
  capacity: number
  lastEmptied: timestamp
  lastUpdated: timestamp
  sensorsData: string (optional)
  collectionHistory: array
}

// issues/{issueId}
{
  userId: string (ref: users)
  binId: string (ref: bins)
  title: string
  description: string
  issueType: string
  images: array<string> (URLs)
  status: "open" | "in_progress" | "resolved"
  createdAt: timestamp
  resolvedAt: timestamp (optional)
  resolution: string (optional)
  adminNotes: string (optional)
}

// notifications/{notificationId}
{
  userId: string (ref: users)
  title: string
  body: string
  type: string
  data: object
  createdAt: timestamp
  isRead: boolean
  relatedBinId: string (optional)
}

// collectionHistory/{entryId}
{
  driverId: string (ref: users)
  binId: string (ref: bins)
  collectedAt: timestamp
  quantityCollected: number
  wasteType: string
  location: object (coordinates)
}
```

### Step 7: Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Public read access to bins
    match /bins/{binId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }
    
    // Users can read and create issues
    match /issues/{issueId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == request.resource.data.userId;
      allow update: if request.auth.token.admin == true;
    }
    
    // Users can only read their notifications
    match /notifications/{notificationId} {
      allow read: if request.auth.uid == resource.data.userId;
    }
  }
}
```

## 🎯 Testing Checklist

- [ ] Authentication (Login/Register/Logout)
- [ ] View bins list (Citizen)
- [ ] View full bins (Driver)
- [ ] Report issue with photos
- [ ] Receive notifications
- [ ] Update profile information
- [ ] Handle network errors
- [ ] Location permissions
- [ ] Camera/Photo permissions
- [ ] Offline functionality

## 📞 Debugging Tips

### Common Issues & Solutions

**1. Firebase Authentication not working**
```bash
# Check Firebase setup
flutter pub get
flutterfire configure --project=your-project-id

# Clear cache
flutter clean
flutter pub get
```

**2. Location permission denied**
```dart
// Add to AndroidManifest.xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

// Add to Info.plist
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location</string>
```

**3. Images not uploading**
```dart
// Enable Firebase Storage rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /issues/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📚 References

- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [Firebase Security](https://firebase.google.com/docs/rules)
- [Google Maps for Flutter](https://pub.dev/packages/google_maps_flutter)
- [Firebase Storage](https://firebase.flutter.dev/docs/storage/usage)

---

**Last Updated**: January 18, 2026
