// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_generated_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiGeneratedContent _$AiGeneratedContentFromJson(Map<String, dynamic> json) =>
    _AiGeneratedContent(
      translation: json['translation'] as String,
      notes: json['notes'] as String,
      examples: json['examples'] as String,
      difficulty: $enumDecodeNullable(_$DifficultyEnumMap, json['difficulty']),
    );

Map<String, dynamic> _$AiGeneratedContentToJson(_AiGeneratedContent instance) =>
    <String, dynamic>{
      'translation': instance.translation,
      'notes': instance.notes,
      'examples': instance.examples,
      'difficulty': instance.difficulty,
    };

const _$DifficultyEnumMap = {
  Difficulty.beginner: 'beginner',
  Difficulty.intermediate: 'intermediate',
  Difficulty.advanced: 'advanced',
};
