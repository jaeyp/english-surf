// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sentence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Sentence _$SentenceFromJson(Map<String, dynamic> json) => _Sentence(
  id: (json['id'] as num).toInt(),
  order: (json['order'] as num).toInt(),
  original: _sentenceTextFromJson(json['original']),
  translation: json['translation'] as String,
  difficulty: Difficulty.fromJson(json['difficulty'] as String),
  paraphrases:
      (json['paraphrases'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  notes: json['notes'] as String? ?? '',
  isFavorite: json['isFavorite'] as bool? ?? false,
  folderId: json['folderId'] as String?,
);

Map<String, dynamic> _$SentenceToJson(_Sentence instance) => <String, dynamic>{
  'id': instance.id,
  'order': instance.order,
  'original': _sentenceTextToJson(instance.original),
  'translation': instance.translation,
  'difficulty': _difficultyToJson(instance.difficulty),
  'paraphrases': instance.paraphrases,
  'notes': instance.notes,
  'isFavorite': instance.isFavorite,
  'folderId': instance.folderId,
};
