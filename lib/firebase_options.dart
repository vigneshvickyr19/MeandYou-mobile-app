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
    apiKey: 'AIzaSyA94EDKAwwzrnKyyO3DY82Gltv7pZ2QVas',
    appId: '1:170946286094:web:06209937041b36aa66225f',
    messagingSenderId: '170946286094',
    projectId: 'me-and-you-11e89',
    authDomain: 'me-and-you-11e89.firebaseapp.com',
    storageBucket: 'me-and-you-11e89.firebasestorage.app',
    databaseURL: 'https://me-and-you-11e89-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBocnY5mQ-2cEVaTqMnkrCt4jgv4_Ga330',
    appId: '1:170946286094:android:06209937041b36aa66225f',
    messagingSenderId: '170946286094',
    projectId: 'me-and-you-11e89',
    storageBucket: 'me-and-you-11e89.firebasestorage.app',
    databaseURL: 'https://me-and-you-11e89-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA94EDKAwwzrnKyyO3DY82Gltv7pZ2QVas',
    appId: '1:170946286094:ios:29f9530dc6f1a52866225f',
    messagingSenderId: '170946286094',
    projectId: 'me-and-you-11e89',
    storageBucket: 'me-and-you-11e89.firebasestorage.app',
    iosBundleId: 'com.meandyou.dating',
    databaseURL: 'https://me-and-you-11e89-default-rtdb.firebaseio.com',
  );
}
