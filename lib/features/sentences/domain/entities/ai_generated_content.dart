import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/difficulty.dart';

part 'ai_generated_content.freezed.dart';
part 'ai_generated_content.g.dart';

@freezed
abstract class AiGeneratedContent with _$AiGeneratedContent {
  const factory AiGeneratedContent({
    required String translation,
    required String notes,
    required String paraphrases,
    Difficulty? difficulty,
  }) = _AiGeneratedContent;

  factory AiGeneratedContent.fromJson(Map<String, dynamic> json) =>
      _$AiGeneratedContentFromJson(json);
}
