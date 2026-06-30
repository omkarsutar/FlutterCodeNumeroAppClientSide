class AppConstants {
  AppConstants._();

  // static const String baseUrlProd = 'https://numeroshastra.github.io/';
  static const String appPath = 'NumeroShastraV01/';
  static const String baseUrlProd = 'https://app.numeroshastra.com/';
  // static const String appPath = '';
  static const String baseUrlLocal = 'http://localhost:3000/';
  static const String appPackageName = 'com.numeroshastra.client';
  static const String supabaseUrl = 'https://tmoskxcxgcywkzxykqth.supabase.co/';

  static const String webAppProdUrl = '$baseUrlProd$appPath';
  static const String webAppLocalUrl = '$baseUrlLocal$appPath';
  static const String webAppHashUrl = '$baseUrlProd$appPath#';
  static const String mobileRedirectUri = '$appPackageName://login-callback';

  static const String googleWebClientId =
      '846330251035-cmmm0sqq9elonjh3tl1h4rnfreet1h57.apps.googleusercontent.com';

  static const String trackingPackageName = appPackageName;
  static const String trackInstallEdgeFunctionUrl =
      '$supabaseUrl/functions/v1/track-install-android-app';
  static const String validatePromoCodeEdgeFunctionUrl =
      '$supabaseUrl/functions/v1/validate-promocode';
}
