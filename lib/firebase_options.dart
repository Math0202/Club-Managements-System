// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyDs9mhq70gXmvpPPRp78LMDeS7F4IzjYOI',
    appId: '1:116529557634:web:1cf5aedbbda4bbc3ba849b',
    messagingSenderId: '116529557634',
    projectId: 'ongolftech-78cc7',
    authDomain: 'ongolftech-78cc7.firebaseapp.com',
    storageBucket: 'ongolftech-78cc7.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDfhT2XdrVl0MXll3EfsC9b1foZkdBoHR4',
    appId: '1:116529557634:ios:d42ac1e9213a9f0eba849b',
    messagingSenderId: '116529557634',
    projectId: 'ongolftech-78cc7',
    storageBucket: 'ongolftech-78cc7.appspot.com',
    iosBundleId: 'com.example.ongolfTechMamagementSystem',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDfhT2XdrVl0MXll3EfsC9b1foZkdBoHR4',
    appId: '1:116529557634:ios:d42ac1e9213a9f0eba849b',
    messagingSenderId: '116529557634',
    projectId: 'ongolftech-78cc7',
    storageBucket: 'ongolftech-78cc7.appspot.com',
    iosBundleId: 'com.example.ongolfTechMamagementSystem',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDYS7Kwfib0cvq-eF3JNWTgmJNlBOSiVPU',
    appId: '1:116529557634:android:6f8c28f9b627d3f5ba849b',
    messagingSenderId: '116529557634',
    projectId: 'ongolftech-78cc7',
    storageBucket: 'ongolftech-78cc7.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDs9mhq70gXmvpPPRp78LMDeS7F4IzjYOI',
    appId: '1:116529557634:web:08cf34ad3a156e4dba849b',
    messagingSenderId: '116529557634',
    projectId: 'ongolftech-78cc7',
    authDomain: 'ongolftech-78cc7.firebaseapp.com',
    storageBucket: 'ongolftech-78cc7.appspot.com',
  );

}