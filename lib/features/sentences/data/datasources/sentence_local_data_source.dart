import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/sentence.dart';

import '../../domain/entities/folder.dart';

abstract class SentenceLocalDataSource {
  /// Gets the folder and list of sentences from the local JSON file.
  Future<(Folder, List<Sentence>)> getFolderWithSentences();
}

class SentenceLocalDataSourceImpl implements SentenceLocalDataSource {
  final AssetBundle assetBundle;

  SentenceLocalDataSourceImpl({AssetBundle? assetBundle})
    : assetBundle = assetBundle ?? rootBundle;

  @override
  Future<(Folder, List<Sentence>)> getFolderWithSentences() async {
    final jsonString = await assetBundle.loadString(
      'assets/data/sentences.json',
    );
    final dynamic decoded = jsonDecode(jsonString);
    final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(decoded);

    final folder = Folder.fromJson(jsonMap['folder'] as Map<String, dynamic>);
    final List<dynamic> sentencesJson = jsonMap['sentences'] as List<dynamic>;

    final sentences = sentencesJson
        .map((json) => Sentence.fromJson(json).copyWith(folderId: folder.id))
        .toList();

    return (folder, sentences);
  }
}
