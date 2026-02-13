import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';
import 'script_type.dart';

enum AppLanguage {
  @JsonValue('en')
  english(
    displayName: 'English',
    aiPromptName: 'English',
    scriptType: ScriptType.latin,
    locale: Locale('en'),
  ),
  @JsonValue('ko')
  korean(
    displayName: '한국어',
    aiPromptName: 'Korean',
    scriptType: ScriptType.korean,
    locale: Locale('ko'),
  ),
  @JsonValue('es')
  spanish(
    displayName: 'Español',
    aiPromptName: 'Spanish',
    scriptType: ScriptType.latin,
    locale: Locale('es'),
  ),
  @JsonValue('pt')
  portuguese(
    displayName: 'Português', // or Português (Brasil) if targeting specific
    aiPromptName: 'Portuguese',
    scriptType: ScriptType.latin,
    locale: Locale('pt'),
  ),
  @JsonValue('fr')
  french(
    displayName: 'Français',
    aiPromptName: 'French',
    scriptType: ScriptType.latin,
    locale: Locale('fr'),
  );

  final String displayName;
  final String aiPromptName;
  final ScriptType scriptType;
  final Locale locale;

  String get code => locale.languageCode;

  const AppLanguage({
    required this.displayName,
    required this.aiPromptName,
    required this.scriptType,
    required this.locale,
  });

  static AppLanguage fromString(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }

  static AppLanguage? fromLocale(Locale locale) {
    // Basic mapping from ISO 639-1 code
    final normalizeCode = locale.languageCode.toLowerCase();
    try {
      return AppLanguage.values.firstWhere(
        (lang) => lang.code == normalizeCode,
      );
    } catch (_) {
      return null;
    }
  }

  /// Simple heuristic to detect language from text content.
  /// Used for importing legacy backups or missing fields.
  static AppLanguage detect(String text) {
    if (text.isEmpty) return AppLanguage.english;

    // Check for Hangul characters for Korean
    if (RegExp(r'[가-힣]').hasMatch(text)) {
      return AppLanguage.korean;
    }

    // Default to English for Latin scripts as a safe fallback for "EnglishSurf" context
    // We could add more specific regex for accented characters for ES/PT/FR,
    // but for now, the primary use case is separating KO vs non-KO.
    return AppLanguage.english;
  }
}
