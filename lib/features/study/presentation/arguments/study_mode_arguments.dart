import '../../../sentences/domain/enums/app_language.dart';

class StudyModeArguments {
  final int initialIndex;
  final bool isTestMode;
  final AppLanguage? originalLanguage;
  final AppLanguage? translationLanguage;

  const StudyModeArguments({
    this.initialIndex = 0,
    this.isTestMode = false,
    this.originalLanguage,
    this.translationLanguage,
  });
}
