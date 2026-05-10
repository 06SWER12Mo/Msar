import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDVkPTkTjBlwFomeRf1gfA7fIfFEF6TND0',
    appId: '1:227050817312:web:d98b2d89f8bc538aef7945',
    messagingSenderId: '227050817312',
    projectId: 'hackops-checkpoint-2026',
    storageBucket: 'hackops-checkpoint-2026.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAF2Z1RCs6xpDdi4WYOLqG-I7B5VUDs8g',
    appId: '1:227050817312:android:6a955a0b5ed366c5ef7945',
    messagingSenderId: '227050817312',
    projectId: 'hackops-checkpoint-2026',
    storageBucket: 'hackops-checkpoint-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDVkPTkTjBlwFomeRf1gfA7fIfFEF6TND0',
    appId: '1:227050817312:web:d98b2d89f8bc538aef7945',
    messagingSenderId: '227050817312',
    projectId: 'hackops-checkpoint-2026',
    storageBucket: 'hackops-checkpoint-2026.firebasestorage.app',
    iosBundleId: 'com.example.checkpointApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDVkPTkTjBlwFomeRf1gfA7fIfFEF6TND0',
    appId: '1:227050817312:web:d98b2d89f8bc538aef7945',
    messagingSenderId: '227050817312',
    projectId: 'hackops-checkpoint-2026',
    storageBucket: 'hackops-checkpoint-2026.firebasestorage.app',
    iosBundleId: 'com.example.checkpointApp',
  );
}