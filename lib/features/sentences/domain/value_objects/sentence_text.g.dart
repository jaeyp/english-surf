// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sentence_text.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SentenceText _$SentenceTextFromJson(Map<String, dynamic> json) =>
    _SentenceText(
      plainText: json['plainText'] as String,
      styles:
          (json['styles'] as List<dynamic>?)
              ?.map((e) => TextStyle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SentenceTextToJson(_SentenceText instance) =>
    <String, dynamic>{
      'plainText': instance.plainText,
      'styles': instance.styles,
    };
