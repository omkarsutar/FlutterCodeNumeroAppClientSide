for https://zaenvrciiycqctpldldr.supabase.co/rest/v1/rpc/get_number_occurrence_details now response is [
    {
        "number": 1,
        "occurrence": 2,
        "description": "You are communicative",
        "description_hindi": "आप संवादशील हैं",
        "description_marathi": "तुम्ही संवादशील आहात"
    },
    {
        "number": 2,
        "occurrence": 1,
        "description": "You are sensitive",
        "description_hindi": "आप संवेदनशील हैं",
        "description_marathi": "तुम्ही संवेदनशील आहात"
    }, and https://zaenvrciiycqctpldldr.supabase.co/rest/v1/rpc/get_loshu_planes response of this is changed to [
    {
        "grid_position": "firstRow",
        "title": "First row (4,9,2) - Genius, Sharp memory - MENTAL PLANE",
        "description": "You are having 4,",
        "title_hindi": "पहली पंक्ति (4,9,2) – मानसिक स्तर – प्रतिभाशाली, तीव्र स्मृति",
        "title_marathi": "पहिली ओळ (4,9,2) – मानसिक स्तर – प्रतिभावान, तीक्ष्ण स्मरणशक्ती",
        "description_hindi": "यदि आपके ",
        "description_marathi": "जर तुमच्या "
    },
    {
        "grid_position": "thirdRow",
        "title": "Third row (8,1,6) - PRACTICAL PLANE",
        "description": "Your feet is pract",
        "title_hindi": "तीसरी पंक्ति (8,1,6) – व्यावहारिक स्तर",
        "title_marathi": "तिसरी ओळ (8,1,6) – व्यावहारिक स्तर",
        "description_hindi": "आपके पैर ज़मीन पर मज",
        "description_marathi": "तुमचे पाय जमिनीवर "
    }
] and for this https://zaenvrciiycqctpldldr.supabase.co/rest/v1/static_testimonials?select=%2A&is_active=eq.true&order=id.desc.nullslast response is changed to [
    {
        "id": 6,
        "person_name": "Valentina",
        "description": "I really got ",
        "image": "",
        "is_active": true,
        "description_hindi": "मुझे अपने ",
        "description_marathi": "मला माझ्या जीवन"
    },
    {
        "id": 5,
        "person_name": "Luis",
        "description": "Really good experien",
        "image": "",
        "is_active": true,
        "description_hindi": "वास्तव में अच्छा अनुभव। मु",
        "description_marathi": "खरंच चांगला अनुभव. म"
    }, so now hindi and marathi columns added and table stuctures are also changed. plz do changes in view according to selected language.


---------------------------------------------------


class SupabaseConfig {
  static const String supabaseUrl = 'https://zaenvrciiycqctpldldr.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InphZW52cmNpaXljcWN0cGxkbGRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQwOTUzOTIsImV4cCI6MjA4OTY3MTM5Mn0.7IsnnLHNxnuHJs2YMUgnuBfRqXyEjaTNf3bh61fzCOE';
}


----------------------------------------------------

protect static tables on supabase