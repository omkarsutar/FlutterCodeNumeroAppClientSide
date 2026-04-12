import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with [Firebase.initializeApp].
/// 
/// This class is a placeholder. To enable Firebase on Web, replace the values in [web] 
/// with the configuration from your Firebase Console.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'PLACEHOLDER-FOR-WEB',
    appId: 'PLACEHOLDER-FOR-WEB',
    messagingSenderId: 'PLACEHOLDER-FOR-WEB',
    projectId: 'PLACEHOLDER-FOR-WEB',
    authDomain: 'PLACEHOLDER-FOR-WEB.firebaseapp.com',
    storageBucket: 'PLACEHOLDER-FOR-WEB.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyActmShjR2HwMWZenZmkBYehLsHUCbAmTU',
    appId: '1:398076701751:android:3e22cd4c1d311ab3f2a3b2',
    messagingSenderId: '398076701751',
    projectId: 'numero-shastra',
    storageBucket: 'numero-shastra.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'not-needed-read-from-google-services-plist',
    appId: '1:placeholder:ios:placeholder', // This will be overridden by the .plist file on iOS
    messagingSenderId: 'placeholder',
    projectId: 'placeholder',
    storageBucket: 'placeholder.appspot.com',
    iosBundleId: 'com.numeroshastra.client',
  );
}
