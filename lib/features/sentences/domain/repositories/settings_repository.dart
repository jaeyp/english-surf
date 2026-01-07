import '../enums/difficulty.dart';
import '../enums/sort_type.dart';
import '../../application/providers/sentence_providers.dart';

abstract class SettingsRepository {
  Future<SortType> getSortType();
  Future<void> saveSortType(SortType sortType);

  Future<Difficulty?> getDifficultyFilter();
  Future<void> saveDifficultyFilter(Difficulty? difficulty);

  Future<LanguageMode> getLanguageMode();
  Future<void> saveLanguageMode(LanguageMode mode);

  Future<bool> getShowFavoritesOnly();
  Future<void> saveShowFavoritesOnly(bool showOnly);

  Future<int> getTimerDuration();
  Future<void> saveTimerDuration(int duration);
}
