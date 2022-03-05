// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    // ignore: missing_enum_constant_in_switch
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
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDuRuj1oUocyd2pAAqz5chffIaUrPxkwEI',
    appId: '1:352517991018:android:40ffcdd9f6d7579c8f7813',
    messagingSenderId: '352517991018',
    projectId: 'nasim-f5b74',
    storageBucket: 'nasim-f5b74.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDdi-n8CN_ZhQ8wROIY6HWifDG2FX256cQ',
    appId: '1:352517991018:ios:2dab0e470874cdcb8f7813',
    messagingSenderId: '352517991018',
    projectId: 'nasim-f5b74',
    storageBucket: 'nasim-f5b74.appspot.com',
    iosClientId: '352517991018-f5s17mv2qa50jccsu3ufr8od10inm73m.apps.googleusercontent.com',
    iosBundleId: 'com.nasim',
  );
}