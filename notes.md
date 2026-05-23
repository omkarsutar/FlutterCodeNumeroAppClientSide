-- Option A: Add a specific policy for logged-in users
CREATE POLICY "Allow authenticated read access to app configs" 
ON public.app_remote_configs 
FOR SELECT TO authenticated 
USING (true);
-- Option B (Recommended): Change the policy to "public" (covers both anon and logged-in)
DROP POLICY "Allow anonymous read access to app configs" ON public.app_remote_configs;
CREATE POLICY "Allow public read access to app configs" 
ON public.app_remote_configs 
FOR SELECT TO anon, authenticated 
USING (true);

[{"idx":0,"id":"71bc89bd-707c-49d4-bfaa-4f0709cf7a71","package_name":"com.numeroshastra.client.debug","numerology_price_inr":"1.00","razorpay_mode":"test","razorpay_key":"rzp_test_SYxEd8SaQvfl81","updated_at":"2026-05-22 04:03:01.243051+00"},{"idx":1,"id":"e8767d7d-8620-4a96-9b96-179a634c6214","package_name":"com.numeroshastra.client","numerology_price_inr":"399.00","razorpay_mode":"live","razorpay_key":"rzp_live_EESyiZv7gEQo8u","updated_at":"2026-05-22 04:03:01.243051+00"}]

app showing RemoteConfig -> package=com.numeroshastra.client, price=299.0, mode=test, key=missing | FALLBACK_299 no_rows. but database is not having price value ₹299 in both live and test rows. and in this case app always showing ₹299 on every install, reinstall and reopen. when i created app after doing flutter clean and then installed first time it was showing data fetched from live row. but then on every reinstall or reopen it was showing 299. when it showed 399 it was showing 299 for a moment then suddenly data came and replaced the text with 399 automatically. i am so much confused

backupSchemasOfsupaDbNumeroApp01On22May2025.sql this modified file is provided. we have below code Here is the complete, finalized production code for your Flutter Checkout Page.This file is fully integrated with your Robust v1.1.0 Tracking SDK, dynamically fetches your keys and pricing from your app_remote_configs table using package_info_plus, handles backward compatibility transitions for older device memory states, and routes the entire un-parsed tracking payloads straight into Razorpay notes for server-side processing. 

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:central_tracker_sdk/central_tracker_sdk.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Razorpay _razorpay;
  final _supabase = Supabase.instance.client;
  final TextEditingController _promoController = TextEditingController();
  
  double _baseAmountINR = 0.0;
  double _finalAmountINR = 0.0;
  String _razorpayPublicKey = '';
  String _appliedCode = 'none';
  
  bool _isLoadingConfigs = true;
  bool _isValidatingPromo = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize standard native Razorpay listeners
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    
    // Load pricing matrices and public keys dynamically from Supabase
    _fetchRemoteConfigurations();
  }

  @override
  void dispose() {
    _razorpay.clear(); // Drop listeners to avoid background execution memory leaks
    _promoController.dispose();
    super.dispose();
  }

  /// Queries Supabase using the active OS package bundle to load correct keys/prices dynamically
  Future<void> _fetchRemoteConfigurations() async {
    try {
      // 1. Inspect the operating system to retrieve the active runtime package name
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String activePackageName = packageInfo.packageName; 
      // Returns 'com.numeroshastra.client.debug' on local emulators, 'com.numeroshastra.client' from Play Store

      // 2. Query your public RLS-protected remote configurations table configuration
      final data = await _supabase
          .from('app_remote_configs')
          .select('numerology_price_inr, razorpay_key')
          .eq('package_name', activePackageName)
          .single();

      setState(() {
        _baseAmountINR = (data['numerology_price_inr'] as num).toDouble();
        _finalAmountINR = _baseAmountINR;
        _razorpayPublicKey = data['razorpay_key'] ?? '';
        _isLoadingConfigs = false;
      });
    } catch (e) {
      print("Remote configuration fetch failure error: \$e");
      // Fallback boundaries if network connectivity cuts out on initialization
      setState(() {
        _baseAmountINR = 299.00;
        _finalAmountINR = 299.00;
        _razorpayPublicKey = 'rzp_test_FALLBACK_DEFAULT';
        _isLoadingConfigs = false;
      });
    }
  }

  /// Sends the coupon identifier string to CentralTrackerSDK for database validation
  void _validateAndApplyPromo() async {
    String inputCode = _promoController.text.trim().toUpperCase();
    if (inputCode.isEmpty) return;

    setState(() {
      _isValidatingPromo = true;
    });

    // Run remote validation down your SDK infrastructure pipeline
    final result = await CentralTrackerSDK.verifyPromoCode(inputCode);

    setState(() {
      _isValidatingPromo = false;
    });

    if (result['valid'] == true) {
      double discountPercent = (result['discount_percentage'] as num).toDouble();
      
      setState(() {
        _appliedCode = inputCode;
        _finalAmountINR = _baseAmountINR * (1 - (discountPercent / 100));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Success! Applied influencer discount code: -\$discountPercent%")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Invalid promo code structure.")),
      );
    }
  }

  /// Fetches unparsed tracking records from local storage memory and spins up Razorpay checkout
  void _startCheckoutSequence() async {
    if (_razorpayPublicKey.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();

    // 1. Fetch multi-touch tracking strings populated by your version 1.1.0 tracker SDK
    String? firstReferrerRaw = prefs.getString('first_touch_source');
    String? lastReferrerRaw = prefs.getString('second_touch_source');

    // 2. Migration Guard: Read legacy parameters if user downloaded app before v1.1.0 setup
    if (firstReferrerRaw == null || lastReferrerRaw == null) {
      String legacyReferrer = prefs.getString('sdk_attribution_logged_com.numeroshastra.client') 
          ?? 'utm_source=organic&utm_medium=direct&utm_campaign=none';
      
      firstReferrerRaw ??= legacyReferrer;
      lastReferrerRaw ??= legacyReferrer;
    }

    // 3. Convert target price to Razorpay Paisa currency values (e.g. ₹299 = 29900)
    int finalAmountInPaisa = (_finalAmountINR * 100).toInt();

    // 4. Extract active application bundle identity dynamically for backend logging
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // 5. Structure options package payload mapping parameters
    var options = {
      'key': _razorpayPublicKey, // ◄ DYNAMIC KEY: Loaded securely from your Supabase row!
      'amount': finalAmountInPaisa,
      'name': 'NumeroShastra Services',
      'description': 'Premium App Consultation Checkout',
      'timeout': 300, 
      'prefill': {
        'contact': '9876543210', 
        'email': 'customer@numeroshastra.com'
      },
      
      // CRITICAL LOG COUPLING: Captured server-to-server by your track-purchase webhook function
      'notes': {
        'package_name': packageInfo.packageName,
        'promo_code_applied': _appliedCode,
        
        // Forward entire unparsed parameter tracks directly to your database logs
        'first_touch_referrer_raw': firstReferrerRaw,
        'last_touch_referrer_raw': lastReferrerRaw,
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Razorpay native checkout interface screen failed to render: \$e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment processed locally. Your server-side webhook catches the confirmation notes, 
    // extracts parameters, splits attribution streams, and writes database rows securely!
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Payment Received"),
        content: Text("Transaction ID: \${response.paymentId}\nYour consultation profile allocation is being initialized."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("Continue"),
          )
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Declined: [Error Code \({response.code}]\){response.message}"),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  @override
  Widget build(BuildContext context) {
    // Show smooth rendering progress indicators while fetching server variables
    if (_isLoadingConfigs) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Secure Checkout")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cost Aggregations Metrics Visual Card Panel
              Card(
                elevation: 0,
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          const Text("Consultation Price", style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text("₹\${_baseAmountINR.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          const Text("Total Outstanding", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          Text("₹\${_finalAmountINR.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Dynamic Promocode Validation Entry Input Block
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      decoration: InputDecoration(
                        hintText: "ENTER INFLUENCER CODE",
                        labelText: "Promocode",
border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),prefixIcon: const Icon(Icons.confirmation_number_outlined),),textCapitalization: TextCapitalization.characters,),),const SizedBox(width: 12),ElevatedButton(onPressed: _isValidatingPromo ? null : _validateAndApplyPromo,style: ElevatedButton.styleFrom(minimumSize: const Size(100, 56),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),),child: _isValidatingPromo? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)): const Text("Apply"),)],),const Spacer(),// Native Gateway Access Key Execution ButtonElevatedButton.icon(onPressed: _startCheckoutSequence,icon: const Icon(Icons.verified_user, color: Colors.white),label: const Text("Proceed to Payment Verification", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,padding: const EdgeInsets.symmetric(vertical: 16),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),),)],),),),);}} 

this code is generated by gemini ai. we have to refer this. i want to enhance install tracker, then want to implement promocode while purchase. want to show dynamic price for numerology purchase from app_remote_configs supabase table. central_tracker_sdk is updated.  


# Implementation Plan - Dynamic Pricing, Attribution, and Promocodes

Enhance the application's checkout process by introducing dynamic pricing from Supabase, integrating the attribution tracker cache fallbacks, and adding promocode validation/discounts.

## User Review Required

> [!IMPORTANT]
> The checkout flow price calculation rules will dynamically transition from using a hardcoded `₹299/₹249` pricing model to utilizing the dynamic base price retrieved from the `app_remote_configs` table in Supabase.
> The logic is:
> - `subtotal = count * basePrice`
> - If promocode applied: `subtotal * (1 - (discountPercentage / 100))`

> [!NOTE]
> CentralTrackerSDK only tracks installations on Android devices with Google Play Services. To prevent attribution parameters from being null on other platforms, we introduce fallback attribution caching.

---

## Proposed Changes

### Component 1: Models & Core Configuration

#### [NEW] [app_remote_config.dart](file:///e:/Flutter%20Projects%20after%2010Oct2025/NumeroAppClientSide/main%20branch/mainBranchNumeroAppClientSide/lib/core/models/app_remote_config.dart)
- Model representing the `app_remote_configs` database table with fields:
  - `packageName` (string)
  - `numerologyPriceInr` (double)
  - `razorpayMode` (string)
  - `razorpayKey` (string)

#### [MODIFY] [core_models_barrel.dart](file:///e:/Flutter%20Projects%20after%2010Oct2025/NumeroAppClientSide/main%20branch/mainBranchNumeroAppClientSide/lib/core/models/core_models_barrel.dart)
- Export the new `app_remote_config.dart` model.

#### [MODIFY] [core_providers.dart](file:///e:/Flutter%20Projects%20after%2010Oct2025/NumeroAppClientSide/main%20branch/mainBranchNumeroAppClientSide/lib/core/providers/core_providers.dart)
- Implement `appRemoteConfigProvider` which fetches the configuration dynamically based on the current platform's package name (`package_info_plus`).

---

### Component 2: Attribution Tracker Enhancements

#### [MODIFY] [web_utils_interface.dart](file:///e:/Flutter%20Projects%20after%2010Oct2025/NumeroAppClientSide/main%20branch/mainBranchNumeroAppClientSide/lib/core/utils/platform/web_utils_interface.dart)
- Declare `String? getFullUtmParams()` in the interface.

#### [MODIFY] [web_utils_web.dart](file:///e:/Flutter%20Projects%20after%2010Oct2025/NumeroAppClientSide/main%20branch/mainBranchNumeroAppClientSide/lib/core/utils/platform/web_utils_web.dart)
- Implement `getFullUtmParams()` to capture and return URL UTM parameter query strings on Web platforms.

#### [MODIFY] [web_utils_mobile.dart](file:///e:/Flutter%20Projects%20after%2010Oct2025/NumeroAppClientSide/main%20branch/mainBranchNumeroAppClientSide/lib/core/utils/platform/web_utils_mobile.dart)
- Implement no-op fallback returning `null` for `getFullUtmParams()`.

#### [MODIFY] [main.dart](file:///e:/Flutter%20Projects%20after%2010Oct2025/NumeroAppClientSide/main%20branch/mainBranchNumeroAppClientSide/lib/main.dart)
- Introduce the helper function `enhanceAttributionTracking()` and execute it at startup to ensure `first_touch_source` and `second_touch_source` keys are always initialized (e.g. fallback to UTMs on web, platform direct routes on iOS/Android emulators).

---

### Component 3: Payment Gateway & Controller Routing

#### [MODIFY] [razorpay_service.dart](file:///e:/Flutter%20Projects%20after%2010Oct2025/NumeroAppClientSide/main%20branch/mainBranchNumeroAppClientSide/lib/core/services/razorpay_service.dart)
- Enhance `openCheckout` signature to accept optional `apiKey` and custom `notes` parameters. If `apiKey` is provided, use it dynamically; otherwise fallback to the class initialized `_apiKey`.

#### [MODIFY] [cart_controller.dart](file:///e:/Flutter%20Projects%20after%2010Oct2025/NumeroAppClientSide/main%20branch/mainBranchNumeroAppClientSide/lib/features/postLogin/cart/providers/cart_controller.dart)
- Accept optional `apiKey` and `appliedPromoCode` in `startPaymentFlow()`.
- Query `SharedPreferences` for tracking attributions (`first_touch_source`, `second_touch_source`), package name details via `PackageInfo`, and bundle them into the Razorpay notes parameter object.

---

### Component 4: Cart Checkout UI

#### [MODIFY] [cart_page.dart](file:///e:/Flutter%20Projects%20after%2010Oct2025/NumeroAppClientSide/main%20branch/mainBranchNumeroAppClientSide/lib/features/postLogin/cart/ui/cart_page.dart)
- Fetch pricing dynamically from `appRemoteConfigProvider`.
- Insert a beautiful, responsive promocode entry input block and active promo card in the cart payment footer layout.
- Bind promocode validation routines using `CentralTrackerSDK.verifyPromoCode`.
- Wire payment action triggers to pass the dynamically selected price, dynamic Razorpay api key, and applied promo metadata to the payment flow controller.

---

## Verification Plan

### Automated Tests
- Build and run the app to check for any compilation or syntax warnings.
  ```powershell
  flutter test
  ```

### Manual Verification
- Verify that dynamic prices load correctly.
- Enter a promocode in the cart, verify the validation state, the success state showing the applied percentage discount, and check the adjusted total price.
- Cancel the promocode, check that the price updates back to the base dynamic price.
- Confirm the Razorpay options payload contains the custom `notes` with attribution variables.














logo color code is   #003BFF
