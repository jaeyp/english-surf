import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/app_language.dart';

part 'folder.freezed.dart';
part 'folder.g.dart';

@freezed
abstract class Folder with _$Folder {
  const factory Folder({
    required String id,
    required String name,
    required DateTime createdAt,
    String? flagColor,
    @Default(AppLanguage.english) AppLanguage originalLanguage,
    @Default(AppLanguage.korean) AppLanguage translationLanguage,
  }) = _Folder;

  factory Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);
}
