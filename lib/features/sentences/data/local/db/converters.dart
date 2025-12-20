import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../domain/enums/difficulty.dart';
import '../../../domain/value_objects/sentence_text.dart';

class DifficultyConverter extends TypeConverter<Difficulty, String> {
  const DifficultyConverter();

  @override
  Difficulty fromSql(String fromDb) => Difficulty.fromJson(fromDb);

  @override
  String toSql(Difficulty value) => value.toJson();
}

class SentenceTextConverter extends TypeConverter<SentenceText, String> {
  const SentenceTextConverter();

  @override
  SentenceText fromSql(String fromDb) {
    return SentenceText.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(SentenceText value) {
    return json.encode(value.toJson());
  }
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return (json.decode(fromDb) as List<dynamic>).cast<String>();
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value);
  }
}
