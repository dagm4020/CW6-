// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyA_jzNLbVeeYu4Zr5jE--f1fwhfkik39Aw',
    appId: '1:554974324225:web:fb5934d7cba855ff120200',
    messagingSenderId: '554974324225',
    projectId: 'task-manager-43c62',
    authDomain: 'task-manager-43c62.firebaseapp.com',
    storageBucket: 'task-manager-43c62.firebasestorage.app',
    measurementId: 'G-65NT2MP02J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDc-XqTMeaQpJ_M_VQwkSHZVZJGgMMs5w0',
    appId: '1:554974324225:android:cfe7bc67562b729d120200',
    messagingSenderId: '554974324225',
    projectId: 'task-manager-43c62',
    storageBucket: 'task-manager-43c62.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCb3eAFnke4gz8yxDPOT5ylib-zdAu3Sc4',
    appId: '1:554974324225:ios:e3772d192a179016120200',
    messagingSenderId: '554974324225',
    projectId: 'task-manager-43c62',
    storageBucket: 'task-manager-43c62.firebasestorage.app',
    iosBundleId: 'com.example.taskManager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCb3eAFnke4gz8yxDPOT5ylib-zdAu3Sc4',
    appId: '1:554974324225:ios:e3772d192a179016120200',
    messagingSenderId: '554974324225',
    projectId: 'task-manager-43c62',
    storageBucket: 'task-manager-43c62.firebasestorage.app',
    iosBundleId: 'com.example.taskManager',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA_jzNLbVeeYu4Zr5jE--f1fwhfkik39Aw',
    appId: '1:554974324225:web:b8a91c30c1ad2ad1120200',
    messagingSenderId: '554974324225',
    projectId: 'task-manager-43c62',
    authDomain: 'task-manager-43c62.firebaseapp.com',
    storageBucket: 'task-manager-43c62.firebasestorage.app',
    measurementId: 'G-XZXTZMV07K',
  );
}