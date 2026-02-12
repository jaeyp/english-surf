import 'script_type.dart';

enum AppLanguage {
  english(
    code: 'en',
    displayName: 'English',
    aiPromptName: 'English',
    scriptType: ScriptType.latin,
  ),
  korean(
    code: 'ko',
    displayName: '한국어',
    aiPromptName: 'Korean',
    scriptType: ScriptType.korean,
  ),
  spanish(
    code: 'es',
    displayName: 'Español',
    aiPromptName: 'Spanish',
    scriptType: ScriptType.latin,
  ),
  portuguese(
    code: 'pt',
    displayName: 'Português', // or Português (Brasil) if targeting specific
    aiPromptName: 'Portuguese',
    scriptType: ScriptType.latin,
  ),
  french(
    code: 'fr',
    displayName: 'Français',
    aiPromptName: 'French',
    scriptType: ScriptType.latin,
  );

  final String code;
  final String displayName;
  final String aiPromptName;
  final ScriptType scriptType;

  const AppLanguage({
    required this.code,
    required this.displayName,
    required this.aiPromptName,
    required this.scriptType,
  });

  static AppLanguage fromString(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }

  static AppLanguage? fromLocale(String localeCode) {
    // Basic mapping from ISO 639-1 code
    // Handling some common variations
    final normalizeCode = localeCode.toLowerCase().split('_').first;
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
