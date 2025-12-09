// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TextStyle _$TextStyleFromJson(Map<String, dynamic> json) => _TextStyle(
  type: $enumDecode(_$TextStyleTypeEnumMap, json['type']),
  start: (json['start'] as num).toInt(),
  end: (json['end'] as num).toInt(),
  value: json['value'] as String?,
);

Map<String, dynamic> _$TextStyleToJson(_TextStyle instance) =>
    <String, dynamic>{
      'type': instance.type,
      'start': instance.start,
      'end': instance.end,
      'value': instance.value,
    };

const _$TextStyleTypeEnumMap = {
  TextStyleType.bold: 'bold',
  TextStyleType.highlight: 'highlight',
  TextStyleType.underline: 'underline',
  TextStyleType.strikethrough: 'strikethrough',
  TextStyleType.italic: 'italic',
  TextStyleType.color: 'color',
};
