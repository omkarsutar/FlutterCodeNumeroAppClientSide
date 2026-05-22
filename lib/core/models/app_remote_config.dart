class AppRemoteConfig {
  final String packageName;
  final double numerologyPriceInr;
  final String razorpayMode;
  final String razorpayKey;

  AppRemoteConfig({
    required this.packageName,
    required this.numerologyPriceInr,
    required this.razorpayMode,
    required this.razorpayKey,
  });

  factory AppRemoteConfig.fromMap(Map<String, dynamic> map) {
    final dynamic rawPrice = map['numerology_price_inr'];
    double parsedPrice;
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice) ?? 299.0;
    } else {
      parsedPrice = 299.0;
    }

    return AppRemoteConfig(
      packageName: map['package_name'] ?? '',
      numerologyPriceInr: parsedPrice,
      razorpayMode: map['razorpay_mode'] ?? 'test',
      razorpayKey: map['razorpay_key'] ?? '',
    );
  }

  factory AppRemoteConfig.fallback() {
    return AppRemoteConfig(
      packageName: 'com.numeroshastra.client',
      numerologyPriceInr: 299.0,
      razorpayMode: 'test',
      razorpayKey: '', // This will fall back to static config key in service
    );
  }
}
