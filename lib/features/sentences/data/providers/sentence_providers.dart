import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../datasources/sentence_local_data_source.dart';
import '../repositories/sentence_repository_impl.dart';
import '../repositories/settings_repository_impl.dart';
import '../repositories/folder_repository_impl.dart';
import '../../domain/repositories/folder_repository.dart';
import '../../domain/repositories/sentence_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../../core/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sentence_providers.g.dart';

@riverpod
SentenceLocalDataSource sentenceLocalDataSource(Ref ref) {
  return SentenceLocalDataSourceImpl();
}

@riverpod
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

@riverpod
SentenceRepository sentenceRepository(Ref ref) {
  final localDataSource = ref.watch(sentenceLocalDataSourceProvider);
  final database = ref.watch(appDatabaseProvider);
  return SentenceRepositoryImpl(
    localDataSource: localDataSource,
    database: database,
  );
}

@riverpod
FolderRepository folderRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return FolderRepositoryImpl(database: database);
}

@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'Initialize and override sharedPreferencesProvider in main.dart',
  );
}

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepositoryImpl(prefs);
}
