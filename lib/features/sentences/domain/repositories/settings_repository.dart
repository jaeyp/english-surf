import '../enums/difficulty.dart';
import '../enums/sort_type.dart';
import '../../application/providers/sentence_providers.dart';
import '../enums/ai_provider.dart';

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

  Future<AiProvider> getAiProvider();
  Future<void> saveAiProvider(AiProvider provider);

  Future<String> getAiModel(AiProvider provider);
  Future<void> saveAiModel(AiProvider provider, String modelName);
}
