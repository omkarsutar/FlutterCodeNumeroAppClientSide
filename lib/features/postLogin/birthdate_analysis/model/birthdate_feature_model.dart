import '../../../../core/providers/localization_provider.dart';

/// Represents a single feature row from the [birthdate_features] Supabase table.
///
/// Table schema:
/// ```sql
/// CREATE TABLE IF NOT EXISTS public.birthdate_features (
///   id              uuid    NOT NULL DEFAULT gen_random_uuid(),
///   title           text    NOT NULL,
///   title_hindi     text,
///   title_marathi   text,
///   description     text    NOT NULL,
///   description_hindi   text,
///   description_marathi text,
///   image_url       text
/// );
/// ```
class BirthdateFeature {
  final String id;
  final String titleEn;
  final String? titleHi;
  final String? titleMr;
  final String descriptionEn;
  final String? descriptionHi;
  final String? descriptionMr;
  final String? imageUrl;

  const BirthdateFeature({
    required this.id,
    required this.titleEn,
    this.titleHi,
    this.titleMr,
    required this.descriptionEn,
    this.descriptionHi,
    this.descriptionMr,
    this.imageUrl,
  });

  factory BirthdateFeature.fromMap(Map<String, dynamic> map) {
    return BirthdateFeature(
      id: map['id']?.toString() ?? '',
      titleEn: map['title'] as String? ?? '',
      titleHi: map['title_hindi'] as String?,
      titleMr: map['title_marathi'] as String?,
      descriptionEn: map['description'] as String? ?? '',
      descriptionHi: map['description_hindi'] as String?,
      descriptionMr: map['description_marathi'] as String?,
      imageUrl: map['image_url'] as String?,
    );
  }

  /// Returns the title localised to [lang], falling back to English.
  String getTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return titleHi?.isNotEmpty == true ? titleHi! : titleEn;
      case AppLanguage.marathi:
        return titleMr?.isNotEmpty == true ? titleMr! : titleEn;
      case AppLanguage.english:
        return titleEn;
    }
  }

  /// Returns the description localised to [lang], falling back to English.
  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHi?.isNotEmpty == true ? descriptionHi! : descriptionEn;
      case AppLanguage.marathi:
        return descriptionMr?.isNotEmpty == true ? descriptionMr! : descriptionEn;
      case AppLanguage.english:
        return descriptionEn;
    }
  }
}
