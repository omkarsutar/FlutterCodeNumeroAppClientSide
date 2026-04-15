for https://zaenvrciiycqctpldldr.supabase.co/rest/v1/rpc/get_number_occurrence_details now response is [
    {
        "number": 1,
        "occurrence": 2,
        "description": "You are communicative",
        "description_hindi": "आप संवादशील हैं",
        "description_marathi": "तुम्ही संवादशील आहात"
    },
    {
        "number": 2,
        "occurrence": 1,
        "description": "You are sensitive",
        "description_hindi": "आप संवेदनशील हैं",
        "description_marathi": "तुम्ही संवेदनशील आहात"
    }, and https://zaenvrciiycqctpldldr.supabase.co/rest/v1/rpc/get_loshu_planes response of this is changed to [
    {
        "grid_position": "firstRow",
        "title": "First row (4,9,2) - Genius, Sharp memory - MENTAL PLANE",
        "description": "You are having 4,",
        "title_hindi": "पहली पंक्ति (4,9,2) – मानसिक स्तर – प्रतिभाशाली, तीव्र स्मृति",
        "title_marathi": "पहिली ओळ (4,9,2) – मानसिक स्तर – प्रतिभावान, तीक्ष्ण स्मरणशक्ती",
        "description_hindi": "यदि आपके ",
        "description_marathi": "जर तुमच्या "
    },
    {
        "grid_position": "thirdRow",
        "title": "Third row (8,1,6) - PRACTICAL PLANE",
        "description": "Your feet is pract",
        "title_hindi": "तीसरी पंक्ति (8,1,6) – व्यावहारिक स्तर",
        "title_marathi": "तिसरी ओळ (8,1,6) – व्यावहारिक स्तर",
        "description_hindi": "आपके पैर ज़मीन पर मज",
        "description_marathi": "तुमचे पाय जमिनीवर "
    }
] and for this https://zaenvrciiycqctpldldr.supabase.co/rest/v1/static_testimonials?select=%2A&is_active=eq.true&order=id.desc.nullslast response is changed to [
    {
        "id": 6,
        "person_name": "Valentina",
        "description": "I really got ",
        "image": "",
        "is_active": true,
        "description_hindi": "मुझे अपने ",
        "description_marathi": "मला माझ्या जीवन"
    },
    {
        "id": 5,
        "person_name": "Luis",
        "description": "Really good experien",
        "image": "",
        "is_active": true,
        "description_hindi": "वास्तव में अच्छा अनुभव। मु",
        "description_marathi": "खरंच चांगला अनुभव. म"
    }, so now hindi and marathi columns added and table stuctures are also changed. plz do changes in view according to selected language.


---------------------------------------------------


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



----------------------------------------------------

protect static tables on supabase