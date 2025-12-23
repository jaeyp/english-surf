import 'package:shared_preferences/shared_preferences.dart';
import '../../application/providers/sentence_providers.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/sort_type.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;

  static const String _keySortType = 'sort_type';
  static const String _keyDifficulty = 'difficulty_filter';
  static const String _keyLanguageMode = 'language_mode';

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
}
