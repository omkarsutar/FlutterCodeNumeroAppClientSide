class AppConstants {
  AppConstants._();

  static const String baseUrlProd = 'https://omkarsutar.github.io/';
  static const String baseUrlLocal = 'http://localhost:3000/';
  static const String appPath = 'NumeroShastraV01/';

  static const String webAppProdUrl = '$baseUrlProd$appPath';
  static const String webAppLocalUrl = '$baseUrlLocal$appPath';
  static const String webAppHashUrl = '$baseUrlProd$appPath#';
  static const String mobileRedirectUri =
      'com.numeroshastra.client://login-callback';
}
