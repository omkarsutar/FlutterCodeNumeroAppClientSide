import '../../../../core/providers/localization_provider.dart';

class HelpContent {
  final String titleEn;
  final String contentEn;
  final String? titleHi;
  final String? contentHi;
  final String? titleMr;
  final String? contentMr;

  HelpContent({
    required this.titleEn,
    required this.contentEn,
    this.titleHi,
    this.contentHi,
    this.titleMr,
    this.contentMr,
  });

  String getTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return titleHi ?? titleEn;
      case AppLanguage.marathi:
        return titleMr ?? titleEn;
      case AppLanguage.english:
        return titleEn;
    }
  }

  String getContent(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return contentHi ?? contentEn;
      case AppLanguage.marathi:
        return contentMr ?? contentEn;
      case AppLanguage.english:
        return contentEn;
    }
  }
}

class NumerologyHelpRepository {
  static final Map<String, HelpContent> helpData = {
    'lo_shu_grid': HelpContent(
      titleEn: 'Lo Shu Grid',
      contentEn:
          'The Lo Shu Grid is a 3x3 magic square used in numerology to map numbers from your birthdate. Each position in the grid represents different life elements like wealth, health, and wisdom. It helps identify strengths and areas needing balance.',
      titleHi: 'लोशु ग्रिड',
      contentHi:
          'लोशु ग्रिड एक 3x3 जादुई वर्ग है जिसका उपयोग अंकज्योतिष में आपकी जन्मतिथि के अंकों को व्यवस्थित करने के लिए किया जाता है। ग्रिड में प्रत्येक स्थिति धन, स्वास्थ्य और ज्ञान जैसे विभिन्न जीवन तत्वों का प्रतिनिधित्व करती है।',
      titleMr: 'लोशु ग्रिड',
      contentMr:
          'लोशु ग्रिड हा ३x३ का जादूचा चौरस आहे जो अंकशास्त्रात तुमच्या जन्मतारखेतील अंक मांडण्यासाठी वापरला जातो. ग्रिडमधील प्रत्येक स्थान संपत्ती, आरोग्य आणि शहाणपण यांसारख्या विविध जीवन घटकांचे प्रतिनिधित्व करते.',
    ),
    'personality_number': HelpContent(
      titleEn: 'Personality Number',
      contentEn:
          'This number is derived from your birth day. it reflects your core character, innate traits, and the initial impression you make on others. it is often called your "Inner Self."',
      titleHi: 'व्यक्तित्व अंक',
      contentHi:
          'यह अंक आपके जन्म के दिन से प्राप्त होता है। यह आपके मूल चरित्र, जन्मजात गुणों और दूसरों पर आपके द्वारा बनाए गए शुरुआती प्रभाव को दर्शाता है।',
      titleMr: 'व्यक्तिमत्व अंक',
      contentMr:
          'हा अंक तुमच्या जन्मतारखेतील दिवसावरून मिळतो. हे तुमचे मूळ चारित्र्य, जन्मजात गुण आणि इतरांवर तुमच्या पडणाऱ्या प्रभावाचे दर्शन घडवते.',
    ),
    'life_path_number': HelpContent(
      titleEn: 'Life Path Number',
      contentEn:
          'Calculated from your full birthdate, this is the most important number. it reveals your life\'s purpose, the primary journey you will take, and the major lessons you are here to learn.',
      titleHi: 'भाग्य अंक (लाइफ पाथ)',
      contentHi:
          'आपकी पूरी जन्मतिथि से गणना की गई, यह सबसे महत्वपूर्ण अंक है। यह आपके जीवन के उद्देश्य, आपकी प्राथमिक यात्रा और उन बड़े पाठों को प्रकट करता है जिन्हें आप सीखने आए हैं।',
      titleMr: 'भाग्य अंक',
      contentMr:
          'तुमच्या पूर्ण जन्मतारखेवरून मोजला जाणारा हा सर्वात महत्त्वाचा अंक आहे. हे तुमच्या जीवनाचा उद्देश आणि तुमचा मुख्य प्रवास दर्शवते.',
    ),
    'important_points': HelpContent(
      titleEn: 'Important Points',
      contentEn:
          'These are specific insights generated based on the presence of certain number combinations in your Lo Shu Grid. They highlight unique psychological traits and potential life events.',
      titleHi: 'महत्वपूर्ण बिंदु',
      contentHi:
          'ये आपके लोशु ग्रिड में कुछ निश्चित संख्या संयोजनों की उपस्थिति के आधार पर उत्पन्न विशिष्ट अंतर्दृष्टि हैं। वे अद्वितीय मनोवैज्ञानिक लक्षणों को उजागर करते हैं।',
      titleMr: 'महत्वाचे मुद्दे',
      contentMr:
          'तुमच्या लोशु ग्रिडमधील विशिष्ट संख्यांच्या संयोजनावर आधारित हे काही महत्त्वाचे निष्कर्ष आहेत. ते तुमचे मानसिक गुणधर्म दर्शवतात.',
    ),
    'number_occurrences': HelpContent(
      titleEn: 'Number Occurrences',
      contentEn:
          'The frequency of a number in your birthdate indicates the intensity of that number\'s influence. High frequency can suggest strong talents but sometimes also challenges related to that number\'s qualities.',
      titleHi: 'अंकों की पुनरावृत्ति',
      contentHi:
          'आपकी जन्मतिथि में किसी अंक की आवृत्ति उस अंक के प्रभाव की तीव्रता को दर्शाती है। उच्च आवृत्ति मजबूत प्रतिभा का सुझाव दे सकती है।',
      titleMr: 'अंकांची पुनरावृत्ती',
      contentMr:
          'तुमच्या जन्मतारखेतील एखाद्या अंकाची वारंवारता त्या अंकाच्या प्रभावाची तीव्रता दर्शवते.',
    ),
    'missing_number_tells': HelpContent(
      titleEn: 'Missing Number Tells',
      contentEn:
          'These are patterns observed when certain numbers are absent from your grid. They explain the challenges or "missing links" you might face in different aspects of life.',
      titleHi: 'अनुपस्थित अंक प्रभाव',
      contentHi:
          'जब आपके ग्रिड में कुछ अंक अनुपस्थित होते हैं, तो वे जीवन के विभिन्न पहलुओं में आपके सामने आने वाली चुनौतियों या कमियों को दर्शाते हैं।',
      titleMr: 'अनुपस्थित अंकांचा प्रभाव',
      contentMr:
          'जेव्हा तुमच्या ग्रिडमध्ये काही अंक नसतात, तेव्हा ते तुमच्या जीवनातील काही कमतरता दर्शवतात.',
    ),
    'missing_number_remedies': HelpContent(
      titleEn: 'Missing Number Remedies',
      contentEn:
          'Simple actions or items that help balance the energy of missing numbers in your Lo Shu Grid, assisting you in overcoming related life challenges.',
      titleHi: 'अनुपस्थित अंक उपाय',
      contentHi:
          'सरल क्रियाएं या वस्तुएं जो आपके लोशु ग्रिड में अनुपस्थित अंकों की ऊर्जा को संतुलित करने में मदद करती हैं।',
      titleMr: 'अनुपस्थित अंक उपाय',
      contentMr:
          'तुमच्या लोशु ग्रिडमधील नसलेल्या अंकांची ऊर्जा संतुलित करण्यासाठी सुचवलेले सोपे उपाय.',
    ),
    'lo_shu_planes': HelpContent(
      titleEn: 'Lo Shu Planes',
      contentEn:
          'The grid is analyzed through horizontal, vertical, and diagonal lines called "Planes." Each plane (like Mental, Emotional, or Practical) provides a collective view of specific personality areas.',
      titleHi: 'लोशु स्तर (Planes)',
      contentHi:
          'ग्रिड का विश्लेषण क्षैतिज, लंबवत और तिरछी रेखाओं के माध्यम से किया जाता है जिन्हें "प्लेन" कहा जाता है। प्रत्येक प्लेन व्यक्तित्व के विशिष्ट क्षेत्रों का सामूहिक दृश्य प्रदान करता है।',
      titleMr: 'लोशु प्लेन्स',
      contentMr:
          'ग्रिडचे विश्लेषण आडव्या, उभ्या आणि तिरप्या रेषांद्वारे केले जाते जिन्हें "प्लेन्स" म्हणतात. प्रत्येक प्लेन तुमच्या व्यक्तिमत्त्वाच्या विशिष्ट पैलूंचे दर्शन घडवते.',
    ),
    'career_destiny': HelpContent(
      titleEn: 'Career & Destiny',
      contentEn:
          'Insights into your professional potential and life\'s mission based on your Life Path number. It suggests the fields where you are most likely to find success.',
      titleHi: 'करियर और भाग्य',
      contentHi:
          'आपके भाग्य अंक के आधार पर आपकी पेशेवर क्षमता और जीवन के मिशन की अंतर्दृष्टि। यह उन क्षेत्रों का सुझाव देता है जहां आपको सफलता मिलने की संभावना है।',
      titleMr: 'करियर आणि भविष्य',
      contentMr:
          'तुमच्या भाग्य अंकाच्या आधारावर तुमच्या व्यावसायिक क्षमता आणि जीवनाचे ध्येय याविषयीची माहिती.',
    ),
    'combination_analysis': HelpContent(
      titleEn: 'Combination Analysis',
      contentEn:
          'This explores the synergy between your Personality Number and your Life Path Number, showing how your inner self aligns with your life\'s destiny.',
      titleHi: 'संयोजन विश्लेषण',
      contentHi:
          'यह आपके व्यक्तित्व अंक और आपके भाग्य अंक के बीच के तालमेल की पड़ताल करता है, जो दिखाता है कि आपका आंतरिक स्व आपके जीवन के उद्देश्य के साथ कैसे तालमेल बिठाता है।',
      titleMr: 'संयोजन विश्लेषण',
      contentMr:
          'हे तुमच्या व्यक्तिमत्त्व अंक आणि भाग्य अंक यांच्यातील समन्वयाचा अभ्यास करते.',
    ),
    'boosting_personality': HelpContent(
      titleEn: 'Boosting Personality',
      contentEn:
          'Actionable tips grounded in numerology to improve your confidence, aura, and the way you express your core personality traits.',
      titleHi: 'व्यक्तित्व विकास टिप्स',
      contentHi:
          'आपके आत्मविश्वास, आभा और आपके मूल व्यक्तित्व लक्षणों को व्यक्त करने के तरीके को बेहतर बनाने के लिए अंकज्योतिष पर आधारित सुझाव।',
      titleMr: 'व्यक्तिमत्व विकास टिप्स',
      contentMr:
          'तुमचा आत्मविश्वास आणि तुमचे व्यक्तिमत्त्व सुधारण्यासाठी अंकशास्त्रावर आधारित काही टिप्स.',
    ),
    'pinnacles': HelpContent(
      titleEn: 'Pinnacle Stages',
      contentEn:
          'Life is divided into four major cycles called Pinnacles. Each stage represents a specific atmosphere and type of opportunities that will dominate that period of your life.',
      titleHi: 'शिखर चरण (Pinnacles)',
      contentHi:
          'जीवन चार प्रमुख चक्रों में विभाजित है जिन्हें शिखर (Pinnacles) कहा जाता है। प्रत्येक चरण एक विशिष्ट वातावरण और अवसरों का प्रतिनिधित्व करता है।',
      titleMr: 'शिखर टप्पे',
      contentMr:
          'आयुष्याचे चार प्रमुख टप्पे असतात ज्यांना शिखर (Pinnacles) म्हणतात. प्रत्येक टप्पा विशिष्ट संधींचे प्रतिनिधित्व करतो.',
    ),
    'stock_market': HelpContent(
      titleEn: 'Stock Market Insight',
      contentEn:
          'A numerological perspective on your financial tendencies and risk profile based on your birth date numbers. (For informational purposes only).',
      titleHi: 'शेयर बाजार अंतर्दष्टि',
      contentHi:
          'आपकी जन्मतिथि के अंकों के आधार पर आपकी वित्तीय प्रवृत्तियों और जोखिम प्रोफाइल पर एक अंकज्योतिषीय परिप्रेक्ष्य। (केवल सूचनात्मक उद्देश्यों के लिए)।',
      titleMr: 'शेअर बाजार अंदाज',
      contentMr:
          'जन्मतारखेच्या अंकांवर आधारित तुमच्या आर्थिक प्रवृत्तींचा अंकशास्त्रीय दृष्टिकोन. (केवळ माहितीसाठी).',
    ),
    'lucky_unlucky': HelpContent(
      titleEn: 'Lucky & Unlucky Values',
      contentEn:
          'Vibrational alignment with certain numbers, colors, and days. Following these can help in harmonizing your lifestyle with your numerological strengths.',
      titleHi: 'शुभ और अशुभ मूल्य',
      contentHi:
          'कुछ विशिष्ट अंकों, रंगों और दिनों के साथ आपके कंपन का तालमेल। इनका पालन करने से आपकी जीवनशैली में अंकज्योतिषीय शक्तियों को संतुलित करने में मदद मिल सकती है।',
      titleMr: 'शुभ आणि अशुभ मूल्ये',
      contentMr:
          'विशिष्ट अंक, रंग आणि दिवसांशी तुमचे ट्यूनिंग. याचे पालन केल्याने तुमच्या जीवनात सकारात्मक ऊर्जा मिळण्यास मदत होऊ शकते.',
    ),
  };
}
