import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBn79h2bhtDd4r5JopNGg9BrxNAM-C1Gvg',
    appId: '1:601370185818:web:c4a4ff07343621c3380863',
    messagingSenderId: '601370185818',
    projectId: 'smart-waste-management-cbfdc',
    authDomain: 'smart-waste-management-cbfdc.firebaseapp.com',
    storageBucket: 'smart-waste-management-cbfdc.firebasestorage.app',
    measurementId: 'G-KC89Z0MGN8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDjiWpDnb5_MgdzPzbOqGD-bfzeS8r7Kxw',
    appId: '1:601370185818:android:5f23b1dc4132e274380863',
    messagingSenderId: '601370185818',
    projectId: 'smart-waste-management-cbfdc',
    storageBucket: 'smart-waste-management-cbfdc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9a2TAMg49q_L2N-3cm8HcxeXSmLN30LQ',
    appId: '1:601370185818:ios:1a2ff945041b5c15380863',
    messagingSenderId: '601370185818',
    projectId: 'smart-waste-management-cbfdc',
    storageBucket: 'smart-waste-management-cbfdc.firebasestorage.app',
    iosBundleId: 'com.example.smartWasteManagement',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA9a2TAMg49q_L2N-3cm8HcxeXSmLN30LQ',
    appId: '1:601370185818:ios:1a2ff945041b5c15380863',
    messagingSenderId: '601370185818',
    projectId: 'smart-waste-management-cbfdc',
    storageBucket: 'smart-waste-management-cbfdc.firebasestorage.app',
    iosBundleId: 'com.example.smartWasteManagement',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBn79h2bhtDd4r5JopNGg9BrxNAM-C1Gvg',
    appId: '1:601370185818:web:782975f4b8123247380863',
    messagingSenderId: '601370185818',
    projectId: 'smart-waste-management-cbfdc',
    authDomain: 'smart-waste-management-cbfdc.firebaseapp.com',
    storageBucket: 'smart-waste-management-cbfdc.firebasestorage.app',
    measurementId: 'G-FZ31DWWS98',
  );

}