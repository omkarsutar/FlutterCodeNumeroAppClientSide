I have completed the requested changes. The "What you get in Detailed Analysis" tile is now moved to the Cart page with corrected visibility logic, and the navigation experience has been improved.

Summary of Improvements:
Relocated Premium Tile:
Removed the marketing tile from the BirthdateAnalysisPage to declutter the analysis view.
Implemented it in cart_page.dart within the promotional footer.
Logic Fix: The tile now checks if any order currently in the cart is in a pending state, ensuring it only appears when relevant to the user's immediate purchase.
Enhanced Navigation:
Updated custom_app_bar.dart to be context-aware.
When navigating from the Birthdate Analysis page to the Cart (via the "Unlock Full Analysis" button), the Cart page now displays a Back Arrow instead of a drawer icon, allowing for an intuitive return to the analysis.
UI Polish:
Resolved syntax and indentation issues on the Cart page.
Ensured full localization support (English, Hindi, Marathi) for all new UI elements.
All features are now correctly integrated and follow the intended user flow.

Task Completion Status:
[Completed] Moved 'Detailed Analysis' tile to Cart page.
[Completed] Implemented smarter visibility logic based on cart contents.
[Completed] Added automatic back-arrow support for Cart page when reached via analysis.
[Completed] Fixed all reported syntax and linting errors.



-----------------------------------------------------------------


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



logo color code is   #003BFF
