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
    return AppRemoteConfig(
      packageName: map['package_name'] ?? '',
      numerologyPriceInr: (map['numerology_price_inr'] as num?)?.toDouble() ?? 299.0,
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
