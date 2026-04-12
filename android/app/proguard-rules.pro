# ProGuard rules for Flutter
# Add project specific ProGuard rules here.
# By default, the rules in this file are appended to the default ProGuard rules from the Android Gradle plugin.
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Flutter-specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
-ignorewarnings

# Razorpay rules
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
    public void onPayment*(...);
}

# Firebase & Google Analytics rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.measurement.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.measurement.**
-dontwarn com.google.android.gms.tasks.**
-dontwarn com.google.android.gms.common.**

# Firebase Messaging specific
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.messaging.**

# Supabase & JSON serialization
-keep class com.supabase.** { *; }
-keep class io.github.jan.supabase.** { *; }
-dontwarn com.supabase.**

# General Flutter Plugin rules
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Keep everything in our main package
-keep class com.numeroshastra.client.** { *; }

