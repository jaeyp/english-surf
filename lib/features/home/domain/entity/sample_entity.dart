import 'package:freezed_annotation/freezed_annotation.dart';

part 'sample_entity.freezed.dart';
part 'sample_entity.g.dart';

@freezed
class SampleEntity with _$SampleEntity {
  const factory SampleEntity({
    required String id,
    required String name,
  }) = _SampleEntity;

  factory SampleEntity.fromJson(Map<String, dynamic> json) =>
      _$SampleEntityFromJson(json);
}
