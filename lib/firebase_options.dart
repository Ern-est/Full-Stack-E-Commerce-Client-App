// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Android configuration (from your google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVY1z299rxekmbR2GFUmbrZMDKBTsLduQ',
    appId: '1:433640086598:android:8aa84e2efee6a5453f7e47',
    messagingSenderId: '433640086598',
    projectId: 'admin-panel-fe7d1',
    storageBucket: 'admin-panel-fe7d1.firebasestorage.app',
  );

  // iOS placeholder (you can fill later if you build for iOS)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER_IOS_API_KEY',
    appId: 'PLACEHOLDER_IOS_APP_ID',
    messagingSenderId: 'PLACEHOLDER_IOS_SENDER_ID',
    projectId: 'admin-panel-fe7d1',
    storageBucket: 'admin-panel-fe7d1.firebasestorage.app',
    iosBundleId: 'PLACEHOLDER_IOS_BUNDLE_ID',
  );

  // macOS placeholder
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'PLACEHOLDER_MACOS_API_KEY',
    appId: 'PLACEHOLDER_MACOS_APP_ID',
    messagingSenderId: 'PLACEHOLDER_MACOS_SENDER_ID',
    projectId: 'admin-panel-fe7d1',
    storageBucket: 'admin-panel-fe7d1.firebasestorage.app',
    iosBundleId: 'PLACEHOLDER_MACOS_BUNDLE_ID',
  );
}
