import 'dart:convert';
import 'dart:io';

// Available languages for multilingual TTS
const List<String> availableLangs = ['en', 'ko', 'es', 'pt', 'fr'];

bool isValidLang(String lang) => availableLangs.contains(lang);

// Hangul Jamo constants for NFKD decomposition
const int _hangulSyllableBase = 0xAC00;
const int _hangulSyllableEnd = 0xD7A3;
const int _leadingJamoBase = 0x1100;
const int _vowelJamoBase = 0x1161;
const int _trailingJamoBase = 0x11A7;
const int _vowelCount = 21;
const int _trailingCount = 28;

/// Decompose a Hangul syllable into Jamo (NFKD-like decomposition)
List<int> _decomposeHangulSyllable(int codePoint) {
  if (codePoint < _hangulSyllableBase || codePoint > _hangulSyllableEnd) {
    return [codePoint];
  }

  final syllableIndex = codePoint - _hangulSyllableBase;
  final leadingIndex = syllableIndex ~/ (_vowelCount * _trailingCount);
  final vowelIndex =
      (syllableIndex % (_vowelCount * _trailingCount)) ~/ _trailingCount;
  final trailingIndex = syllableIndex % _trailingCount;

  final result = <int>[
    _leadingJamoBase + leadingIndex,
    _vowelJamoBase + vowelIndex,
  ];

  if (trailingIndex > 0) {
    result.add(_trailingJamoBase + trailingIndex);
  }

  return result;
}

/// Common Latin character decompositions (NFKD) for es, pt, fr
const Map<int, List<int>> _latinDecompositions = {
  // Uppercase with acute accent
  0x00C1: [0x0041, 0x0301], // Á → A + ́
  0x00C9: [0x0045, 0x0301], // É → E + ́
  0x00CD: [0x0049, 0x0301], // Í → I + ́
  0x00D3: [0x004F, 0x0301], // Ó → O + ́
  0x00DA: [0x0055, 0x0301], // Ú → U + ́
  // Lowercase with acute accent
  0x00E1: [0x0061, 0x0301], // á → a + ́
  0x00E9: [0x0065, 0x0301], // é → e + ́
  0x00ED: [0x0069, 0x0301], // í → i + ́
  0x00F3: [0x006F, 0x0301], // ó → o + ́
  0x00FA: [0x0075, 0x0301], // ú → u + ́
  // Grave accent
  0x00C0: [0x0041, 0x0300], // À → A + ̀
  0x00C8: [0x0045, 0x0300], // È → E + ̀
  0x00CC: [0x0049, 0x0300], // Ì → I + ̀
  0x00D2: [0x004F, 0x0300], // Ò → O + ̀
  0x00D9: [0x0055, 0x0300], // Ù → U + ̀
  0x00E0: [0x0061, 0x0300], // à → a + ̀
  0x00E8: [0x0065, 0x0300], // è → e + ̀
  0x00EC: [0x0069, 0x0300], // ì → i + ̀
  0x00F2: [0x006F, 0x0300], // ò → o + ̀
  0x00F9: [0x0075, 0x0300], // ù → u + ̀
  // Circumflex
  0x00C2: [0x0041, 0x0302], // Â → A + ̂
  0x00CA: [0x0045, 0x0302], // Ê → E + ̂
  0x00CE: [0x0049, 0x0302], // Î → I + ̂
  0x00D4: [0x004F, 0x0302], // Ô → O + ̂
  0x00DB: [0x0055, 0x0302], // Û → U + ̂
  0x00E2: [0x0061, 0x0302], // â → a + ̂
  0x00EA: [0x0065, 0x0302], // ê → e + ̂
  0x00EE: [0x0069, 0x0302], // î → i + ̂
  0x00F4: [0x006F, 0x0302], // ô → o + ̂
  0x00FB: [0x0075, 0x0302], // û → u + ̂
  // Tilde
  0x00C3: [0x0041, 0x0303], // Ã → A + ̃
  0x00D1: [0x004E, 0x0303], // Ñ → N + ̃
  0x00D5: [0x004F, 0x0303], // Õ → O + ̃
  0x00E3: [0x0061, 0x0303], // ã → a + ̃
  0x00F1: [0x006E, 0x0303], // ñ → n + ̃
  0x00F5: [0x006F, 0x0303], // õ → o + ̃
  // Diaeresis/Umlaut
  0x00C4: [0x0041, 0x0308], // Ä → A + ̈
  0x00CB: [0x0045, 0x0308], // Ë → E + ̈
  0x00CF: [0x0049, 0x0308], // Ï → I + ̈
  0x00D6: [0x004F, 0x0308], // Ö → O + ̈
  0x00DC: [0x0055, 0x0308], // Ü → U + ̈
  0x00E4: [0x0061, 0x0308], // ä → a + ̈
  0x00EB: [0x0065, 0x0308], // ë → e + ̈
  0x00EF: [0x0069, 0x0308], // ï → i + ̈
  0x00F6: [0x006F, 0x0308], // ö → o + ̈
  0x00FC: [0x0075, 0x0308], // ü → u + ̈
  // Cedilla
  0x00C7: [0x0043, 0x0327], // Ç → C + ̧
  0x00E7: [0x0063, 0x0327], // ç → c + ̧
};

/// Apply NFKD-like decomposition (Hangul + Latin accented characters)
String _applyNfkdDecomposition(String text) {
  final result = <int>[];
  for (final codePoint in text.runes) {
    // Check Hangul first
    if (codePoint >= _hangulSyllableBase && codePoint <= _hangulSyllableEnd) {
      result.addAll(_decomposeHangulSyllable(codePoint));
    }
    // Check Latin decomposition
    else if (_latinDecompositions.containsKey(codePoint)) {
      result.addAll(_latinDecompositions[codePoint]!);
    }
    // Keep as-is
    else {
      result.add(codePoint);
    }
  }
  return String.fromCharCodes(result);
}

String preprocessText(String text, String lang) {
  // Apply NFKD-like decomposition (especially for Hangul syllables → Jamo)
  text = _applyNfkdDecomposition(text);

  // Remove emojis
  text = text.replaceAll(
    RegExp(
      r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|'
      r'[\u{1F700}-\u{1F77F}]|[\u{1F780}-\u{1F7FF}]|[\u{1F800}-\u{1F8FF}]|'
      r'[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}]|'
      r'[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F1E6}-\u{1F1FF}]',
      unicode: true,
    ),
    '',
  );

  // Replace various dashes and symbols
  const replacements = {
    '–': '-',
    '‑': '-',
    '—': '-',
    '_': ' ',
    '\u201C': '"',
    '\u201D': '"',
    '\u2018': "'",
    '\u2019': "'",
    '´': "'",
    '`': "'",
    '[': ' ',
    ']': ' ',
    '|': ' ',
    '/': ' ',
    '#': ' ',
    '→': ' ',
    '←': ' ',
  };
  for (final entry in replacements.entries) {
    text = text.replaceAll(entry.key, entry.value);
  }

  // Remove special symbols
  text = text.replaceAll(RegExp(r'[♥☆♡©\\]'), '');

  // Replace known expressions
  text = text.replaceAll('@', ' at ');
  text = text.replaceAll('e.g.,', 'for example, ');
  text = text.replaceAll('i.e.,', 'that is, ');

  // Fix spacing around punctuation
  text = text.replaceAll(' ,', ',');
  text = text.replaceAll(' .', '.');
  text = text.replaceAll(' !', '!');
  text = text.replaceAll(' ?', '?');
  text = text.replaceAll(' ;', ';');
  text = text.replaceAll(' :', ':');
  text = text.replaceAll(" '", "'");

  // Remove duplicate quotes
  while (text.contains('""')) {
    text = text.replaceAll('""', '"');
  }
  while (text.contains("''")) {
    text = text.replaceAll("''", "'");
  }
  while (text.contains('``')) {
    text = text.replaceAll('``', '`');
  }

  // Remove extra spaces
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Add period if needed
  if (text.isNotEmpty &&
      !RegExp(r'[.!?;:,\x27\x22\u2018\u2019)\]}…。」』】〉》›»]$').hasMatch(text)) {
    text += '.';
  }

  // Validate language
  if (!isValidLang(lang)) {
    throw ArgumentError(
      'Invalid language: $lang. Available: ${availableLangs.join(", ")}',
    );
  }

  // Wrap text with language tags
  text = '<$lang>$text</$lang>';

  return text;
}

class UnicodeProcessor {
  final Map<int, int> indexer;

  UnicodeProcessor._(this.indexer);

  static Future<UnicodeProcessor> fromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Indexer file not found at $path');
    }
    final jsonString = await file.readAsString();
    final json = jsonDecode(jsonString);

    final indexer = json is List
        ? {
            for (var i = 0; i < json.length; i++)
              if (json[i] is int && json[i] >= 0) i: json[i] as int,
          }
        : (json as Map<String, dynamic>).map(
            (k, v) => MapEntry(int.parse(k), v as int),
          );

    return UnicodeProcessor._(indexer);
  }

  Map<String, dynamic> process(List<String> textList, List<String> langList) {
    // Preprocess texts with language tags
    final processedTexts = <String>[];
    for (var i = 0; i < textList.length; i++) {
      processedTexts.add(preprocessText(textList[i], langList[i]));
    }

    final lengths = processedTexts.map((t) => t.runes.length).toList();
    // Helper to get max length
    int maxLen = 0;
    for (var len in lengths) {
      if (len > maxLen) maxLen = len;
    }

    final textIds = processedTexts.map((text) {
      final row = List<int>.filled(maxLen, 0);
      final runes = text.runes.toList();
      for (var i = 0; i < runes.length; i++) {
        row[i] = indexer[runes[i]] ?? 0;
      }
      return row;
    }).toList();

    return {'textIds': textIds, 'textMask': _lengthToMask(lengths)};
  }

  List<List<List<double>>> _lengthToMask(List<int> lengths, [int? maxLen]) {
    if (maxLen == null) {
      maxLen = 0;
      for (var len in lengths) {
        if (len > maxLen!) maxLen = len;
      }
    }

    return lengths
        .map((len) => [List.generate(maxLen!, (i) => i < len ? 1.0 : 0.0)])
        .toList();
  }
}
