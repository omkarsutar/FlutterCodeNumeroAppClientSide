class AppRemoteConfig {
  final String packageName;
  final double numerologyPriceInr;
  final String razorpayMode;
  final String razorpayKey;
  final bool forceUpdateAndroid;
  final int androidMinVersionCode;
  final int androidLatestVersionCode;

  AppRemoteConfig({
    required this.packageName,
    required this.numerologyPriceInr,
    required this.razorpayMode,
    required this.razorpayKey,
    required this.forceUpdateAndroid,
    required this.androidMinVersionCode,
    required this.androidLatestVersionCode,
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
      forceUpdateAndroid: _parseBool(map['force_update_android']),
      androidMinVersionCode: _parseInt(map['android_min_version_code']),
      androidLatestVersionCode: _parseInt(map['android_latest_version_code']),
    );
  }

  factory AppRemoteConfig.fallback() {
    return AppRemoteConfig(
      packageName: 'com.numeroshastra.client',
      numerologyPriceInr: 299.0,
      razorpayMode: 'test',
      razorpayKey: '', // This will fall back to static config key in service
      forceUpdateAndroid: false,
      androidMinVersionCode: 0,
      androidLatestVersionCode: 0,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }
}
