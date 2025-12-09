import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/sentence.dart';

abstract class SentenceLocalDataSource {
  /// Gets the list of sentences from the local JSON file.
  Future<List<Sentence>> getSentences();
}

class SentenceLocalDataSourceImpl implements SentenceLocalDataSource {
  final AssetBundle assetBundle;

  SentenceLocalDataSourceImpl({AssetBundle? assetBundle})
    : assetBundle = assetBundle ?? rootBundle;

  @override
  Future<List<Sentence>> getSentences() async {
    final jsonString = await assetBundle.loadString(
      'assets/data/sentences.json',
    );
    final dynamic decoded = jsonDecode(jsonString);
    final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(decoded);
    final List<dynamic> jsonList = jsonMap['sentences'];

    return jsonList.map((json) => Sentence.fromJson(json)).toList();
  }
}
