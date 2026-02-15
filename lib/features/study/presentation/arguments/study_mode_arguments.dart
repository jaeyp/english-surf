import '../../../sentences/domain/enums/app_language.dart';
import '../../../sentences/application/providers/sentence_providers.dart';

class StudyModeArguments {
  final int initialIndex;
  final bool isTestMode;
  final bool isAudioMode;
  final AppLanguage? originalLanguage;
  final AppLanguage? translationLanguage;

  const StudyModeArguments({
    this.initialIndex = 0,
    this.isTestMode = false,
    this.isAudioMode = false,
    this.originalLanguage,
    this.translationLanguage,
    this.languageMode,
  });

  final LanguageMode? languageMode;
}
