import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_profile_state_provider.dart';
import 'auth_providers.dart';

enum AppLanguage { english, hindi, marathi }

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    // Listen to profile changes to sync language from DB
    final profile = ref.watch(userProfileStateProvider).profile;
    final dbLang = profile?.userLanguage;

    if (dbLang != null) {
      return _mapCodeToLanguage(dbLang);
    }

    return AppLanguage.hindi; // Default language
  }

  void toggleLanguage() {
    AppLanguage next;
    if (state == AppLanguage.english) {
      next = AppLanguage.hindi;
    } else if (state == AppLanguage.hindi) {
      next = AppLanguage.marathi;
    } else {
      next = AppLanguage.english;
    }
    setLanguage(next);
  }

  void setLanguage(AppLanguage lang) {
    if (state == lang) return;
    state = lang;

    // Persist to Supabase if logged in
    final authService = ref.read(authServiceProvider);
    if (authService.currentUser != null) {
      authService.updateUserLanguage(lang);
    }
  }

  AppLanguage _mapCodeToLanguage(String code) {
    switch (code) {
      case 'hi':
        return AppLanguage.hindi;
      case 'mr':
        return AppLanguage.marathi;
      case 'en':
      default:
        return AppLanguage.english;
    }
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(() {
  return LanguageNotifier();
});

final l10nProvider = Provider<Map<String, String>>((ref) {
  final lang = ref.watch(languageProvider);
  return _translations[lang] ?? _translations[AppLanguage.english]!;
});

const _translations = {
  AppLanguage.english: {
    'app_title': 'NumeroApp',
    'my_cart': 'My Cart',
    'birthdate_label': 'Birthdate',
    'age_prefix': 'Your age today is',
    'no_birthdate': 'No Birthdate',
    'years': 'years',
    'months': 'months',
    'days': 'days',
    'products': 'Products',
    'search_hint': 'Search products...',
    'add_to_cart': 'Add to Cart',
    'items': 'Items',
    'shop_profit': 'Shop Profit on MRP',
    'final_amount': 'Final Amount',
    'add_items': 'Add Items',
    'empty_cart_btn': 'Empty Cart',
    'place_order': 'Place Order',
    'pay_now': 'Pay Now',
    'thank_you': 'Thank You!',
    'order_success': 'Your order has been placed successfully.',
    'continue_shopping': 'Continue Shopping',
    'empty_cart_msg': 'Your cart is empty',
    'go_to_products': 'Go to Products',
    'confirm': 'Confirm',
    'cancel': 'Cancel',
    'place_pending_order_title': 'Place Pending Order?',
    'place_pending_order_msg':
        'You have items in your cart. Do you want to place this order now?',
    'clear_cart_title': 'Empty Cart?',
    'clear_cart_msg': 'Remove all items?',
    'clear_all': 'Clear All',
    'cart_saved_login': 'Cart saved. Please login to complete your order.',
    'only_authorized_order':
        'Only guest, salesperson, and retailer can place orders.',
    'logout': 'Logout',
    'profile': 'Profile',
    'orders': 'Orders',
    'home': 'Home',
    'welcome_numeroapp': 'Welcome to NumeroApp',
    'welcome_user': 'Welcome, {name}',
    'welcome_suffix': 'to NumeroApp',
    'role': 'Role',
    'purchase_history': 'Purchase History',
    'login': 'Login',
    'select': 'Select',
    'no_products_found': 'No products found',
    'no_matching_products': 'No matching products',
    'error_loading': 'Error loading',
    'no_internet': 'No internet connection. Please check your network.',
    'internet_connected': 'Back online!',
    'internet_disconnected': 'You are offline. Some features may not work.',
    'save_success': 'Saved successfully!',
    'delete_success': 'Deleted successfully!',
    'save_failed': 'Failed to save.',
    'delete_failed': 'Failed to delete.',
    'please_wait': 'Please wait...',
    'role_change_msg': 'Your access permissions have changed. Reloading app...',
    'shop_link_change_msg':
        'Your shop assignments have changed. Reloading app...',
    'personality_number_label': 'Personality Number',
    'life_path_number_label': 'Life Path Number',
    'pinnacle1_number_label': 'Pinnacle 1',
    'pinnacle2_number_label': 'Pinnacle 2',
    'pinnacle3_number_label': 'Pinnacle 3',
    'pinnacle4_number_label': 'Pinnacle 4',
    'pinnacle_base_label': 'Pinnacle Base',
    'absent_numbers_label': 'Missing Numbers',
    'occurrence_label': 'Number Occurrences',
  },
  AppLanguage.marathi: {
    'app_title': 'NumeroApp',
    'my_cart': ' माझे कार्ट',
    'birthdate_label': 'जन्म तारीख',
    'age_prefix': 'तुमचे आजचे वय',
    'no_birthdate': 'जन्म तारीख निवडली नाही',
    'years': 'वर्षे',
    'months': 'महिने',
    'days': 'दिवस',
    'products': 'प्रोडक्ट्स',
    'search_hint': 'प्रोडक्ट्स शोधा...',
    'add_to_cart': 'कार्टमध्ये टाका',
    'items': 'सामान',
    'shop_profit': 'दुकानाचा नफा (MRP वर)',
    'final_amount': 'एकूण रक्कम',
    'add_items': 'प्रोडक्ट्स वाढवा',
    'empty_cart_btn': 'कार्ट रिकामे करा',
    'place_order': 'ऑर्डर करा',
    'pay_now': 'आता पैसे द्या',
    'thank_you': 'धन्यवाद!',
    'order_success': 'आपली ऑर्डर यशस्वीरीत्या पूर्ण झाली आहे.',
    'continue_shopping': 'खरेदी सुरू ठेवा',
    'empty_cart_msg': 'आपले कार्ट रिकामे आहे',
    'go_to_products': 'प्रोडक्ट्स पहा',
    'confirm': 'ठीक आहे',
    'cancel': 'रद्द करा',
    'place_pending_order_title': 'जुनी ऑर्डर पूर्ण करायची का?',
    'place_pending_order_msg':
        'आपल्या कार्टमध्ये जुने सामान आहे. आता ऑर्डर करायची आहे का?',
    'clear_cart_title': 'कार्ट रिकामे करायचे का?',
    'clear_cart_msg': 'सर्व प्रोडक्ट्स काढून टाका?',
    'clear_all': 'सर्व काढा',
    'cart_saved_login': 'कार्ट सेव्ह झाले आहे. ऑर्डरसाठी लॉगिन करा.',
    'only_authorized_order':
        'फक्त गेस्ट, सेल्सपर्सन आणि रिटेलर ऑर्डर करू शकतात.',
    'logout': 'लॉग आउट',
    'profile': 'माझे प्रोफाइल',
    'orders': 'माझी ऑर्डर',
    'home': 'All',
    'welcome_numeroapp': 'NumeroApp मध्ये स्वागत आहे',
    'welcome_user': 'स्वागत आहे, {name}',
    'welcome_suffix': 'NumeroApp मध्ये',
    'role': 'Role',
    'purchase_history': 'जुने ऑर्डर',
    'login': 'लॉगिन करा',
    'select': 'निवडा',
    'no_products_found': 'कोणतेही प्रोडक्ट सापडले नाही',
    'no_matching_products': 'जुळणारे प्रोडक्ट सापडले नाही',
    'error_loading': 'क्षमस्व, लोड होत नाही',
    'no_internet': 'इंटरनेट कनेक्शन नाही. कृपया तुमचे नेटवर्क तपासा.',
    'internet_connected': 'इंटरनेट परत आले!',
    'internet_disconnected': 'तुम्ही ऑफलाइन आहात. काही सुविधा काम करणार नाहीत.',
    'save_success': 'यशस्वीरीत्या सेव्ह झाले!',
    'delete_success': 'यशस्वीरीत्या डिलीट झाले!',
    'save_failed': 'सेव्ह होऊ शकले नाही.',
    'delete_failed': 'डिलीट होऊ शकले नाही.',
    'please_wait': 'कृपया थांबा..',
    'role_change_msg': 'तुमची परवानगी बदलली आहे. अ‍ॅप पुन्हा लोड होत आहे...',
    'shop_link_change_msg':
        'तुमची शॉप असाइनमेंट बदलली आहे. अ‍ॅप पुन्हा लोड होत आहे...',
    'personality_number_label': 'व्यक्तिमत्व क्रमांक',
    'life_path_number_label': 'जीवन पथ क्रमांक',
    'pinnacle1_number_label': 'शिखर १',
    'pinnacle2_number_label': 'शिखर २',
    'pinnacle3_number_label': 'शिखर ३',
    'pinnacle4_number_label': 'शिखर ४',
    'pinnacle_base_label': 'शिखर आधार',
    'absent_numbers_label': 'अनुपस्थित क्रमांक',
    'occurrence_label': 'अंक वारंवारता',
  },
  AppLanguage.hindi: {
    'app_title': 'NumeroApp',
    'my_cart': 'मेरा कार्ट',
    'birthdate_label': 'जन्म तिथि',
    'age_prefix': 'आपकी आज की उम्र',
    'no_birthdate': 'जन्म तिथि नहीं चुनी गई',
    'years': 'साल',
    'months': 'महीने',
    'days': 'दिन',
    'products': 'प्रोडक्ट्स',
    'search_hint': 'प्रोडक्ट खोजें...',
    'add_to_cart': 'कार्ट में डालें',
    'items': 'सामान',
    'shop_profit': 'दुकान का मुनाफा (MRP पर)',
    'final_amount': 'कुल रकम',
    'add_items': 'प्रोडक्ट जोड़ें',
    'empty_cart_btn': 'कार्ट खाली करें',
    'place_order': 'ऑर्डर करें',
    'pay_now': 'अभी भुगतान करें',
    'thank_you': 'धन्यवाद!',
    'order_success': 'आपका ऑर्डर सफलतापूर्वक हो गया है।',
    'continue_shopping': 'खरीदारी जारी रखें',
    'empty_cart_msg': 'आपका कार्ट खाली है',
    'go_to_products': 'प्रोडक्ट्स देखें',
    'confirm': 'ठीक है',
    'cancel': 'रद्द करें',
    'place_pending_order_title': 'पुराना ऑर्डर पूरा करें?',
    'place_pending_order_msg':
        'आपके कार्ट में पुराना सामान है। क्या आप अभी ऑर्डर करना चाहते हैं?',
    'clear_cart_title': 'कार्ट खाली करें?',
    'clear_cart_msg': 'सारे प्रोडक्ट हटाएँ?',
    'clear_all': 'सब हटाएँ',
    'cart_saved_login': 'कार्ट सेव हो गया। ऑर्डर के लिए लॉगिन करें।',
    'only_authorized_order':
        'केवल गेस्ट, सेल्सपर्सन और रिटेलर ही ऑर्डर कर सकते हैं।',
    'logout': 'लॉग आउट',
    'profile': 'मेरा प्रोफ़ाइल',
    'orders': 'मेरे ऑर्डर',
    'home': 'All',
    'welcome_numeroapp': 'NumeroApp में स्वागत है',
    'welcome_user': 'स्वागत है, {name}',
    'welcome_suffix': 'NumeroApp में',
    'role': 'Role',
    'purchase_history': 'पुराने ऑर्डर',
    'login': 'लॉगिन करें',
    'select': 'चुनें',
    'no_products_found': 'कोई प्रोडक्ट नहीं मिला',
    'no_matching_products': 'मिलता-जुलता प्रोडक्ट नहीं मिला',
    'error_loading': 'क्षमा करें, लोड नहीं हो पाया',
    'no_internet': 'इंटरनेट कनेक्शन नहीं है। कृपया अपना नेटवर्क जांचें।',
    'internet_connected': 'इंटरनेट वापस आ गया!',
    'internet_disconnected': 'आप ऑफलाइन हैं। कुछ सुविधाएँ काम नहीं करेंगी।',
    'save_success': 'सफलतापूर्वक सेव हो गया!',
    'delete_success': 'सफलतापूर्वक डिलीट हो गया!',
    'save_failed': 'सेव नहीं हो पाया।',
    'delete_failed': 'डिलीट नहीं हो पाया।',
    'please_wait': 'कृपया प्रतीक्षा करें...',
    'role_change_msg': 'आपकी अनुमति बदल गई है। ऐप फिर से लोड हो रहा है...',
    'shop_link_change_msg':
        'आपका शॉप असाइनमेंट बदल गया है। ऐप फिर से लोड हो रहा है...',
    'personality_number_label': 'व्यक्तित्व संख्या',
    'life_path_number_label': 'जीवन पथ संख्या',
    'pinnacle1_number_label': 'शिखर १',
    'pinnacle2_number_label': 'शिखर २',
    'pinnacle3_number_label': 'शिखर ३',
    'pinnacle4_number_label': 'शिखर ४',
    'pinnacle_base_label': 'शिखर आधार',
    'absent_numbers_label': 'अनुपस्थित संख्या',
    'occurrence_label': 'अंकों की आवृत्ति',
  },
};
