// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TextStyle _$TextStyleFromJson(Map<String, dynamic> json) => _TextStyle(
  type: _typeFromJson(json['type'] as String),
  range: TextRange.fromJson(json['range'] as Map<String, dynamic>),
  value: json['value'] as String?,
);

Map<String, dynamic> _$TextStyleToJson(_TextStyle instance) =>
    <String, dynamic>{
      'type': _typeToJson(instance.type),
      'range': instance.range,
      'value': instance.value,
    };
