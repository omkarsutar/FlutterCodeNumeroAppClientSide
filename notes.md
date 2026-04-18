https://zaenvrciiycqctpldldr.supabase.co/rest/v1/rpc/get_lucky_unlucky_values


[
    {
        "unlucky_numbers": [
            1,
            2,
            3
        ],
        "unlucky_colors": [
            "Black",
            "Red",
            "Yellow"
        ],
        "unlucky_colors_hindi": [
            "काला",
            "पीला",
            "लाल"
        ],
        "unlucky_colors_marathi": [
            "काळा",
            "पिवळा",
            "लाल"
        ],
        "lucky_numbers": [
            5,
            8,
            9,
            7,
            6
        ],
        "lucky_colors": [
            "Green",
            "White"
        ],
        "lucky_colors_hindi": [
            "हरा",
            "सफेद"
        ],
        "lucky_colors_marathi": [
            "पांढरा",
            "हिरवा"
        ],
        "lucky_days": [
            "Friday",
            "Saturday"
        ],
        "lucky_days_hindi": [
            "शनिवार",
            "शुक्रवार"
        ],
        "lucky_days_marathi": [
            "शनिवार",
            "शुक्रवार"
        ],
        "numbers_for_remedy": [
            7,
            5
        ],
        "numbers_not_for_remedy": [
            3
        ]
    }
]

---------------------------------------------------
SELECT * FROM public.get_share_market_advice(
    birthdate_id => '8cc21ed8-06c1-4084-915e-14fed06db17d'
);

[
  {
    "included_numbers": [
      "2",
      "1"
    ],
    "description_en": "Your numbers are favorable for the stock market. You can trade as an intraday trader or invest as an investor.",
    "description_hi": "आपके अंक शेयर बाजार के लिए अनुकूल हैं। आप इंट्राडे ट्रेडर के रूप में व्यापार कर सकते हैं या निवेशक के रूप में निवेश कर सकते हैं।",
    "description_mr": "तुमचे अंक शेअर बाजारासाठी अनुकूल आहेत. तुम्ही इंट्राडे ट्रेडर म्हणून व्यापार करू शकता किंवा गुंतवणूकदार म्हणून गुंतवणूक करू शकता."
  }
]



----------------------------------------------------

protect static tables on supabase



h