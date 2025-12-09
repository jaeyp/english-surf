import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../datasources/sentence_local_data_source.dart';
import '../repositories/sentence_repository_impl.dart';
import '../../domain/repositories/sentence_repository.dart';

part 'sentence_providers.g.dart';

@riverpod
SentenceLocalDataSource sentenceLocalDataSource(Ref ref) {
  return SentenceLocalDataSourceImpl();
}

@riverpod
SentenceRepository sentenceRepository(Ref ref) {
  final localDataSource = ref.watch(sentenceLocalDataSourceProvider);
  return SentenceRepositoryImpl(localDataSource: localDataSource);
}
