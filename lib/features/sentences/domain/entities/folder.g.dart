// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Folder _$FolderFromJson(Map<String, dynamic> json) => _Folder(
  id: json['id'] as String,
  name: json['name'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  flagColor: json['flagColor'] as String?,
  originalLanguage:
      $enumDecodeNullable(_$AppLanguageEnumMap, json['originalLanguage']) ??
      AppLanguage.english,
  translationLanguage:
      $enumDecodeNullable(_$AppLanguageEnumMap, json['translationLanguage']) ??
      AppLanguage.korean,
);

Map<String, dynamic> _$FolderToJson(_Folder instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdAt': instance.createdAt.toIso8601String(),
  'flagColor': instance.flagColor,
  'originalLanguage': _$AppLanguageEnumMap[instance.originalLanguage]!,
  'translationLanguage': _$AppLanguageEnumMap[instance.translationLanguage]!,
};

const _$AppLanguageEnumMap = {
  AppLanguage.english: 'en',
  AppLanguage.korean: 'ko',
  AppLanguage.spanish: 'es',
  AppLanguage.portuguese: 'pt',
  AppLanguage.french: 'fr',
};
