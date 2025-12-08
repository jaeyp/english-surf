// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sentence_text.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SentenceText _$SentenceTextFromJson(Map<String, dynamic> json) =>
    _SentenceText(
      rawText: json['rawText'] as String,
      plainText: json['plainText'] as String,
      boldRanges:
          (json['boldRanges'] as List<dynamic>?)
              ?.map((e) => TextRange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      highlightRanges:
          (json['highlightRanges'] as List<dynamic>?)
              ?.map((e) => TextRange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SentenceTextToJson(_SentenceText instance) =>
    <String, dynamic>{
      'rawText': instance.rawText,
      'plainText': instance.plainText,
      'boldRanges': instance.boldRanges,
      'highlightRanges': instance.highlightRanges,
    };
