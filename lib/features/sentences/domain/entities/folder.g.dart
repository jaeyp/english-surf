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
);

Map<String, dynamic> _$FolderToJson(_Folder instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdAt': instance.createdAt.toIso8601String(),
  'flagColor': instance.flagColor,
};
