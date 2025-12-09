// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sentence_text.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SentenceText _$SentenceTextFromJson(Map<String, dynamic> json) =>
    _SentenceText(
      text: json['text'] as String,
      styles:
          (json['styles'] as List<dynamic>?)
              ?.map((e) => TextStyle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SentenceTextToJson(_SentenceText instance) =>
    <String, dynamic>{'text': instance.text, 'styles': instance.styles};
