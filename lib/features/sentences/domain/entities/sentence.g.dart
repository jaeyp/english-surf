// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sentence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Sentence _$SentenceFromJson(Map<String, dynamic> json) => _Sentence(
  id: (json['id'] as num).toInt(),
  order: (json['order'] as num).toInt(),
  sentence: json['sentence'] as String,
  translation: json['translation'] as String,
  difficulty: json['difficulty'] as String,
  examples:
      (json['examples'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  notes: json['notes'] as String? ?? '',
);

Map<String, dynamic> _$SentenceToJson(_Sentence instance) => <String, dynamic>{
  'id': instance.id,
  'order': instance.order,
  'sentence': instance.sentence,
  'translation': instance.translation,
  'difficulty': instance.difficulty,
  'examples': instance.examples,
  'notes': instance.notes,
};
