import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';
import 'script_type.dart';

enum AppLanguage {
  @JsonValue('en')
  english(
    displayName: 'English',
    aiPromptName: 'English',
    scriptType: ScriptType.english,
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
    scriptType: ScriptType.spanish,
    locale: Locale('es'),
  ),
  @JsonValue('pt')
  portuguese(
    displayName: 'Português', // or Português (Brasil) if targeting specific
    aiPromptName: 'Portuguese',
    scriptType: ScriptType.portuguese,
    locale: Locale('pt'),
  ),
  @JsonValue('fr')
  french(
    displayName: 'Français',
    aiPromptName: 'French',
    scriptType: ScriptType.french,
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

  /// Heuristic to detect language from text content.
  /// Returns null if the language cannot be identified
  /// (e.g., unsupported scripts like Chinese or Japanese).
  static AppLanguage? detect(String text) {
    if (text.isEmpty) return null;

    // 1. Korean text check (Hangul)
    if (RegExp(r'[가-힣]').hasMatch(text)) return AppLanguage.korean;

    // 2. Latin family scoring
    Map<AppLanguage, int> scores = {
      AppLanguage.spanish: 0,
      AppLanguage.portuguese: 0,
      AppLanguage.french: 0,
    };

    // Spanish features: ¿, ¡, ñ, accents (á, é, í, ó, ú, ü)
    if (RegExp(r'[ñ¿¡áéíóúü]').hasMatch(text)) {
      scores[AppLanguage.spanish] = scores[AppLanguage.spanish]! + 5;
    }

    // Portuguese features
    // ã, õ are very strong indicators for Portuguese
    if (RegExp(r'[ãõ]').hasMatch(text)) {
      scores[AppLanguage.portuguese] = scores[AppLanguage.portuguese]! + 10;
    }
    // ê is common in PT (você) but also FR (être). Give a moderate score.
    if (RegExp(r'[ê]').hasMatch(text)) {
      scores[AppLanguage.portuguese] = scores[AppLanguage.portuguese]! + 3;
    }
    // ê at the end of a word is very common in Portuguese (você, bebê)
    if (RegExp(r'ê(?=\s|$)').hasMatch(text)) {
      scores[AppLanguage.portuguese] = scores[AppLanguage.portuguese]! + 3;
    }
    // ç is shared but weighted.
    if (RegExp(r'[ç]').hasMatch(text)) {
      scores[AppLanguage.portuguese] = scores[AppLanguage.portuguese]! + 2;
    }

    // French features
    // à, è, ù, â, î, ô, û, ë, ï are strong French indicators
    // Also 'oe' ligature 'œ' but keeping it simple with regex
    if (RegExp(r'[àèùâîôûëï]').hasMatch(text)) {
      scores[AppLanguage.french] = scores[AppLanguage.french]! + 7;
    }
    // ê is also common in French
    if (RegExp(r'[ê]').hasMatch(text)) {
      scores[AppLanguage.french] = scores[AppLanguage.french]! + 3;
    }
    // ç is shared
    if (RegExp(r'[ç]').hasMatch(text)) {
      scores[AppLanguage.french] = scores[AppLanguage.french]! + 2;
    }

    // 3. Find language with the highest score
    var winner = scores.entries.reduce((a, b) => a.value > b.value ? a : b);

    // If score is 0, check if text contains Latin characters.
    // If yes, it's likely English. If no, it's an unsupported language.
    if (winner.value == 0) {
      if (RegExp(r'[a-zA-Z]').hasMatch(text)) return AppLanguage.english;
      return null;
    }

    return winner.key;
  }
}
