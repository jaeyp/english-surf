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
    final List<dynamic> jsonList = jsonDecode(jsonString);

    return jsonList.map((json) => Sentence.fromJson(json)).toList();
  }
}
