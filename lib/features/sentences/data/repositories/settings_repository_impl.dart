import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/enums/app_language.dart';
import '../../application/providers/sentence_providers.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/sort_type.dart';
import '../../domain/enums/ai_provider.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../../features/tts/domain/enums/tts_speaker.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;

  static const String _keySortType = 'sort_type';
  static const String _keyDifficulty = 'difficulty_filter';
  static const String _keyLanguageMode = 'language_mode';
  static const String _keyShowFavoritesOnly = 'show_favorites_only';
  static const String _keyTimerDuration = 'timer_duration';
  static const String _keyAiProvider = 'ai_provider';
  static const String _keyAiModelPrefix = 'ai_model_';
  static const String _keyDefaultOriginalLanguage = 'default_original_language';
  static const String _keyDefaultTranslationLanguage =
      'default_translation_language';
  static const String _keyTtsSpeaker = 'tts_speaker';

  SettingsRepositoryImpl(this._prefs);

  @override
  Future<SortType> getSortType() async {
    final value = _prefs.getString(_keySortType);
    if (value == null) return SortType.random;
    return SortType.fromJson(value);
  }

  @override
  Future<void> saveSortType(SortType sortType) async {
    await _prefs.setString(_keySortType, sortType.toJson());
  }

  @override
  Future<Difficulty?> getDifficultyFilter() async {
    final value = _prefs.getString(_keyDifficulty);
    if (value == null) return null;
    return Difficulty.fromJson(value);
  }

  @override
  Future<void> saveDifficultyFilter(Difficulty? difficulty) async {
    if (difficulty == null) {
      await _prefs.remove(_keyDifficulty);
    } else {
      await _prefs.setString(_keyDifficulty, difficulty.toJson());
    }
  }

  @override
  Future<LanguageMode> getLanguageMode() async {
    final value = _prefs.getString(_keyLanguageMode);
    if (value == null) return LanguageMode.translationToOriginal;
    return LanguageMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LanguageMode.translationToOriginal,
    );
  }

  @override
  Future<void> saveLanguageMode(LanguageMode mode) async {
    await _prefs.setString(_keyLanguageMode, mode.name);
  }

  @override
  Future<bool> getShowFavoritesOnly() async {
    return _prefs.getBool(_keyShowFavoritesOnly) ?? false;
  }

  @override
  Future<void> saveShowFavoritesOnly(bool showOnly) async {
    await _prefs.setBool(_keyShowFavoritesOnly, showOnly);
  }

  @override
  Future<int> getTimerDuration() async {
    return _prefs.getInt(_keyTimerDuration) ?? 10;
  }

  @override
  Future<void> saveTimerDuration(int duration) async {
    await _prefs.setInt(_keyTimerDuration, duration);
  }

  @override
  Future<AiProvider> getAiProvider() async {
    final value = _prefs.getString(_keyAiProvider);
    return AiProvider.fromString(value);
  }

  @override
  Future<void> saveAiProvider(AiProvider provider) async {
    await _prefs.setString(_keyAiProvider, provider.name);
  }

  @override
  Future<String> getAiModel(AiProvider provider) async {
    final key = '$_keyAiModelPrefix${provider.name}';
    return _prefs.getString(key) ?? provider.defaultModel;
  }

  @override
  Future<void> saveAiModel(AiProvider provider, String modelName) async {
    final key = '$_keyAiModelPrefix${provider.name}';
    await _prefs.setString(key, modelName);
  }

  @override
  Future<AppLanguage> getDefaultOriginalLanguage() async {
    final code = _prefs.getString(_keyDefaultOriginalLanguage);
    if (code != null) return AppLanguage.fromString(code);
    return AppLanguage.english;
  }

  @override
  Future<void> saveDefaultOriginalLanguage(AppLanguage language) async {
    await _prefs.setString(_keyDefaultOriginalLanguage, language.code);
  }

  @override
  Future<AppLanguage> getDefaultTranslationLanguage() async {
    final code = _prefs.getString(_keyDefaultTranslationLanguage);
    if (code != null) return AppLanguage.fromString(code);

    try {
      final systemLocale = PlatformDispatcher.instance.locale;
      final fromSystem = AppLanguage.fromLocale(systemLocale);
      if (fromSystem != null) return fromSystem;
    } catch (_) {
      // Fallback to default if platform interaction fails
    }

    return AppLanguage.english;
  }

  @override
  Future<void> saveDefaultTranslationLanguage(AppLanguage language) async {
    await _prefs.setString(_keyDefaultTranslationLanguage, language.code);
  }

  // Per-folder notes language
  static const String _keyNotesLangPrefix = 'notes_lang_';

  @override
  Future<String?> getNotesLanguage(String folderId) async {
    return _prefs.getString('$_keyNotesLangPrefix$folderId');
  }

  @override
  Future<void> saveNotesLanguage(String folderId, String langCode) async {
    await _prefs.setString('$_keyNotesLangPrefix$folderId', langCode);
  }

  @override
  Future<TtsSpeaker> getTtsSpeaker() async {
    final value = _prefs.getString(_keyTtsSpeaker);
    if (value == null) return TtsSpeaker.male;
    return TtsSpeaker.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TtsSpeaker.male,
    );
  }

  @override
  Future<void> saveTtsSpeaker(TtsSpeaker speaker) async {
    await _prefs.setString(_keyTtsSpeaker, speaker.name);
  }
}
