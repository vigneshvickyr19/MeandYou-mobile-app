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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBRllM8rjTWKm4KJlayTIqBruFpPUF59bI',
    appId: '1:470989654160:web:REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: '470989654160',
    projectId: 'lik-connect',
    authDomain: 'lik-connect.firebaseapp.com',
    storageBucket: 'lik-connect.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRllM8rjTWKm4KJlayTIqBruFpPUF59bI',
    appId: '1:470989654160:android:20705a7d77b526b5d77015',
    messagingSenderId: '470989654160',
    projectId: 'lik-connect',
    storageBucket: 'lik-connect.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBRllM8rjTWKm4KJlayTIqBruFpPUF59bI',
    appId: '1:470989654160:ios:REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '470989654160',
    projectId: 'lik-connect',
    storageBucket: 'lik-connect.firebasestorage.app',
    iosBundleId: 'com.example.lik',
  );
}
