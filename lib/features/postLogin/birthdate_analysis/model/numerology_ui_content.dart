import '../../../../core/providers/localization_provider.dart';

class UIStrings {
  final String en;
  final String? hi;
  final String? mr;

  UIStrings({required this.en, this.hi, this.mr});

  String get(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return hi ?? en;
      case AppLanguage.marathi:
        return mr ?? en;
      case AppLanguage.english:
        return en;
    }
  }
}

class NumerologyUIContent {
  static final Map<String, UIStrings> headers = {
    'numerical_analysis': UIStrings(
      en: 'Numerical Analysis',
      hi: 'अंकज्योतिषीय विश्लेषण',
      mr: 'अंकशास्त्रीय विश्लेषण',
    ),
    'lo_shu_grid_subtitle': UIStrings(
      en: 'Ancient secrets revealed through numbers',
      hi: 'अंकों के माध्यम से प्राचीन रहस्य',
      mr: 'अंकांमधून उलगडलेली प्राचीन रहस्ये',
    ),
    'personality_analysis': UIStrings(
      en: 'Personality Analysis',
      hi: 'व्यक्तित्व विश्लेषण',
      mr: 'व्यक्तिमत्व विश्लेषण',
    ),
    'personality_subtitle': UIStrings(
      en: 'Deep Character Traits',
      hi: 'गहरे चरित्र गुण',
      mr: 'सखोल व्यक्तिमत्व गुणधर्म',
    ),
    'important_points': UIStrings(
      en: 'Important Points',
      hi: 'महत्वपूर्ण बिंदु',
      mr: 'महत्वाचे मुद्दे',
    ),
    'important_points_subtitle': UIStrings(
      en: 'Based on present numbers in your Lo Shu Grid',
      hi: 'आपके लोशु ग्रिड में मौजूद अंकों के आधार पर',
      mr: 'तुमच्या लोशु ग्रिडमधील अंकांच्या आधारावर',
    ),
    'stock_market': UIStrings(
      en: 'Stock Market Info',
      hi: 'शेयर बाजार जानकारी',
      mr: 'शेअर बाजार माहिती',
    ),
    'stock_market_subtitle': UIStrings(
      en: 'Numerological perspective on financial nature',
      hi: 'वित्तीय प्रकृति पर अंकज्योतिषीय दृष्टिकोण',
      mr: 'आर्थिक स्थितीबद्दल अंकशास्त्रीय दृष्टिकोन',
    ),
    'lucky_unlucky': UIStrings(
      en: 'Lucky - Unlucky',
      hi: 'शुभ - अशुभ',
      mr: 'शुभ - अशुभ',
    ),
    'missing_number_tells': UIStrings(
      en: 'Missing Number Tells',
      hi: 'अनुपस्थित अंक प्रभाव',
      mr: 'अनुपस्थित अंकांचा प्रभाव',
    ),
    'missing_number_tells_subtitle': UIStrings(
      en: 'Based on absent numbers in your Lo Shu Grid',
      hi: 'आपके लोशु ग्रिड में अनुपस्थित अंकों के आधार पर',
      mr: 'तुमच्या लोशु ग्रिडमध्ये नसलेल्या अंकांच्या आधारावर',
    ),
    'missing_number_remedies': UIStrings(
      en: 'Missing Number Remedies',
      hi: 'अनुपस्थित अंक उपाय',
      mr: 'अनुपस्थित अंक उपाय',
    ),
    'occurrence_details': UIStrings(
      en: 'Number Occurrences Details',
      hi: 'अंकों की पुनरावृत्ति विवरण',
      mr: 'अंकांच्या पुनरावृत्तीचा तपशील',
    ),
    'occurrence_details_subtitle': UIStrings(
      en: 'Deep insight into repeated numbers in your grid',
      hi: 'आपके ग्रिड में दोहराए गए अंकों की अंतर्दृष्टि',
      mr: 'तुमच्या ग्रिडमधील पुनरावृत्ती अंकांविषयीची सखोल माहिती',
    ),
    'lo_shu_planes': UIStrings(
      en: 'Lo Shu Planes',
      hi: 'लोशु स्तर (Planes)',
      mr: 'लोशु प्लेन्स',
    ),
    'lo_shu_planes_subtitle': UIStrings(
      en: 'Horizontal, Vertical and Diagonal planes analysis',
      hi: 'क्षैतिज, लंबवत और तिरछे स्तरों का विश्लेषण',
      mr: 'आडव्या, उभ्या आणि तिरप्या रेषांचे विश्लेषण',
    ),
    'career_destiny': UIStrings(
      en: 'Career & Destiny',
      hi: 'करियर और भाग्य',
      mr: 'करियर आणि भविष्य',
    ),
    'career_destiny_subtitle': UIStrings(
      en: 'Your professional path and life purpose',
      hi: 'आपका पेशेवर पथ और जीवन का उद्देश्य',
      mr: 'तुमचा व्यावसायिक प्रवास आणि जीवनाचे ध्येय',
    ),
    'life_path_details': UIStrings(
      en: 'Life Path Details',
      hi: 'भाग्य पथ विवरण',
      mr: 'भाग्य पथ तपशील',
    ),
    'life_path_subtitle': UIStrings(
      en: 'Understanding your soul\'s journey through numbers',
      hi: 'अंकों के माध्यम से आपकी आत्मा की यात्रा को समझना',
      mr: 'अंगांच्या माध्यमातून तुमच्या आत्म्याचा प्रवास समजून घेणे',
    ),
    'combination_analysis': UIStrings(
      en: 'Personality & Life Path Combination',
      hi: 'व्यक्तित्व और भाग्य का संयोजन',
      mr: 'व्यक्तिमत्व आणि भाग्याचा संगम',
    ),
    'combination_subtitle': UIStrings(
      en: 'Synergy between your numbers',
      hi: 'आपके अंकों के बीच का तालमेल',
      mr: 'तुमच्या अंकांमधील समन्वय',
    ),
    'boosting_personality': UIStrings(
      en: 'Boosting Personality',
      hi: 'व्यक्तित्व विकास',
      mr: 'व्यक्तिमत्व विकास',
    ),
    'boosting_personality_subtitle': UIStrings(
      en: 'Practical tips to enhance your vibrational energy',
      hi: 'आपकी ऊर्जा बढ़ाने के लिए व्यावहारिक सुझाव',
      mr: 'तुमची ऊर्जा वाढवण्यासाठी काही टिप्स',
    ),
    'pinnacle_stage': UIStrings(
      en: 'Pinnacle Stage of Life',
      hi: 'आयुष्याचा शिखर टप्पा',
      mr: 'आयुष्याचा शिखर टप्पा',
    ),
    'pinnacle_1': UIStrings(
      en: '1st Pinnacle Stage of Life',
      hi: 'जीवन का प्रथम शिखर चरण',
      mr: 'जीवनाचा पहिला शिखर टप्पा',
    ),
    'pinnacle_2': UIStrings(
      en: '2nd Pinnacle Stage of Life',
      hi: 'जीवन का दूसरा शिखर चरण',
      mr: 'जीवनाचा दुसरा शिखर टप्पा',
    ),
    'pinnacle_3': UIStrings(
      en: '3rd Pinnacle Stage of Life',
      hi: 'जीवन का तीसरा शिखर चरण',
      mr: 'जीवनाचा तिसरा शिखर टप्पा',
    ),
    'pinnacle_4': UIStrings(
      en: '4th Pinnacle Stage of Life',
      hi: 'जीवन का चौथा शिखर चरण',
      mr: 'जीवनाचा चौथा शिखर टप्पा',
    ),
    'pinnacle_subtitle': UIStrings(
      en: 'Life cycle analysis for specific age periods',
      hi: 'विशिष्ट आयु अवधियों के लिए जीवन चक्र विश्लेषण',
      mr: 'विशिष्ट वयोगटासाठी जीवन चक्राचे विश्लेषण',
    ),
  };

  static final Map<String, UIStrings> labels = {
    'personality': UIStrings(
      en: 'Personality',
      hi: 'व्यक्तित्व',
      mr: 'व्यक्तिमत्व',
    ),
    'life_path': UIStrings(en: 'Life Path', hi: 'भाग्य पथ', mr: 'भाग्य पथ'),
    'lo_shu_grid': UIStrings(
      en: 'Lo Shu Grid',
      hi: 'लोशु ग्रिड',
      mr: 'लोशु ग्रिड',
    ),
    'lord': UIStrings(en: 'Lord', hi: 'स्वामी', mr: 'स्वामी ग्रह'),
    'qualities': UIStrings(
      en: 'Character Qualities',
      hi: 'चरित्र गुण',
      mr: 'चारित्र्य गुणधर्म',
    ),
    'weaknesses': UIStrings(
      en: 'Weaknesses',
      hi: 'कमजोरियाँ',
      mr: 'कमतरता / दोष',
    ),
    'recommendation': UIStrings(
      en: 'You Should',
      hi: 'आपको चाहिए',
      mr: 'तुम्ही आवर्जून करावे',
    ),
    'detailed_insight': UIStrings(
      en: 'Detailed Insight',
      hi: 'विस्तृत जानकारी',
      mr: 'सखोल विश्लेषण',
    ),
    'occurrence_format': UIStrings(
      en: 'Number {number} ({count} {times})',
      hi: 'अंक {number} ({count} {times})',
      mr: 'अंक {number} ({count} {times})',
    ),
    'time_singular': UIStrings(en: 'time', hi: 'बार', mr: 'वेळ'),
    'time_plural': UIStrings(en: 'times', hi: 'बार', mr: 'वेळा'),
    'missing_number_label': UIStrings(
      en: 'Missing Number {number}',
      hi: 'अनुपस्थित अंक {number}',
      mr: 'अनुपस्थित अंक {number}',
    ),
    'age_prefix': UIStrings(en: 'Age', hi: 'आयु', mr: 'वय'),
    'lucky_color': UIStrings(en: 'Lucky Colors', hi: 'शुभ रंग', mr: 'शुभ रंग'),
    'unlucky_color': UIStrings(
      en: 'Unlucky Colors',
      hi: 'अशुभ रंग',
      mr: 'अशुभ रंग',
    ),
    'lucky_day': UIStrings(en: 'Lucky Days', hi: 'शुभ दिन', mr: 'शुभ दिवस'),
    'unlucky_day': UIStrings(
      en: 'Unlucky Days',
      hi: 'अशुभ दिन',
      mr: 'अशुभ दिवस',
    ),
    'lucky_number': UIStrings(
      en: 'Lucky Numbers',
      hi: 'शुभ अंक',
      mr: 'शुभ अंक',
    ),
    'unlucky_number': UIStrings(
      en: 'Unlucky Numbers',
      hi: 'अशुभ अंक',
      mr: 'अशुभ अंक',
    ),
    'numbers_for_remedy': UIStrings(
      en: 'Numbers For Remedy',
      hi: 'उपाय के लिए अंक',
      mr: 'उपाय करण्यासाठी अंक',
    ),
    'numbers_not_for_remedy': UIStrings(
      en: 'Numbers Not For Remedy',
      hi: 'उपाय के बिना अंक',
      mr: 'उपाय करू नयेत असे अंक',
    ),
    'example': UIStrings(en: 'Example', hi: 'उदाहरण', mr: 'उदाहरण'),
    'remedy_instruction': UIStrings(
      en: '[Multiple remedies are given for each number, do any 1 remedy for 1 number as per your convenience]',
      hi: '[प्रत्येक संख्या के लिए कई उपाय दिए गए हैं, अपनी सुविधानुसार किसी भी 1 संख्या के लिए 1 उपाय करें]',
      mr: '[प्रत्येक अंकासाठी अनेक उपाय दिले आहेत, तुमच्या सोयीनुसार कोणत्याही एका अंकासाठी एक उपाय करा]',
    ),
    'no_remedy_instruction': UIStrings(
      en: 'No remedy to number {numbers} as they are enemy to you',
      hi: 'अंक {numbers} का कोई उपाय नहीं है क्योंकि वे आपके शत्रु हैं',
      mr: 'अंक {numbers} साठी कोणताही उपाय नाही कारण ते तुमचे शत्रू आहेत',
    ),
    'age': UIStrings(en: 'Age', hi: 'आयु', mr: 'वय'),
    'years': UIStrings(en: 'Years', hi: 'वर्ष', mr: 'वर्षे'),
    'months': UIStrings(en: 'Months', hi: 'महीने', mr: 'महिने'),
    'days': UIStrings(en: 'Days', hi: 'दिन', mr: 'दिवस'),
    'personality_analysis_label': UIStrings(
      en: 'Number {number} - Deep Character Traits',
      hi: 'अंक {number} - गहरे चरित्र गुण',
      mr: 'अंक {number} - सखोल व्यक्तिमत्व गुणधर्म',
    ),
    'remedy_for_number': UIStrings(
      en: 'Remedy for number {number}',
      hi: 'अंक {number} के लिए उपाय',
      mr: 'अंक {number} साठी उपाय',
    ),
    'missing_numbers_grid': UIStrings(
      en: 'Missing Numbers (from Lo Shu Grid)',
      hi: 'अनुपस्थित अंक (लोशु ग्रिड से)',
      mr: 'अनुपस्थित अंक (लोशु ग्रिडमधून)',
    ),
    'occurrences_grid': UIStrings(
      en: 'Number Occurrences',
      hi: 'अंकों की पुनरावृत्ति',
      mr: 'अंकांची पुनरावृत्ती',
    ),
    'occurrence_chip_format': UIStrings(
      en: '{number} : {count} {times}',
      hi: '{number} : {count} {times}',
      mr: '{number} : {count} {times}',
    ),
  };

  static String getHeaderTitle(String key, AppLanguage lang) =>
      headers[key]?.get(lang) ?? key;
  static String getHeaderSubtitle(String key, AppLanguage lang) =>
      headers[key]?.get(lang) ?? '';
  static String getLabel(String key, AppLanguage lang) =>
      labels[key]?.get(lang) ?? key;
}
