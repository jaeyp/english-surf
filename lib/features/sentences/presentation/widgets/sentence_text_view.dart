import 'package:flutter/material.dart';
import '../../domain/value_objects/sentence_text.dart';
import '../../domain/enums/text_style_type.dart';

class SentenceTextView extends StatelessWidget {
  final SentenceText sentenceText;
  final double fontSize;

  const SentenceTextView({
    super.key,
    required this.sentenceText,
    this.fontSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: fontSize, color: Colors.black, height: 1.5),
        children: _buildTextSpans(),
      ),
    );
  }

  List<TextSpan> _buildTextSpans() {
    final text = sentenceText.text;
    final styles = sentenceText.styles;

    if (styles.isEmpty) {
      return [TextSpan(text: text)];
    }

    // 1. Map styles to each character
    // List<Set<TextStyleType>>
    final List<Set<TextStyleType>> charStyles = List.generate(
      text.length,
      (_) => {},
    );

    for (var style in styles) {
      // Validate range
      final start = style.start.clamp(0, text.length);
      final end = style.end.clamp(0, text.length);

      for (int i = start; i < end; i++) {
        charStyles[i].add(style.type);
      }
    }

    // 2. Group consecutive characters with the same style to create TextSpans
    final List<TextSpan> spans = [];

    if (text.isEmpty) return spans;

    StringBuffer currentText = StringBuffer();
    Set<TextStyleType> currentStyleSet = charStyles[0];
    currentText.write(text[0]);

    for (int i = 1; i < text.length; i++) {
      final nextStyleSet = charStyles[i];

      // If styles are the same, continue adding text
      if (_setEquals(currentStyleSet, nextStyleSet)) {
        currentText.write(text[i]);
      } else {
        // If style changes, add the current text as a Span and reset
        spans.add(_createSpan(currentText.toString(), currentStyleSet));
        currentText.clear();
        currentText.write(text[i]);
        currentStyleSet = nextStyleSet;
      }
    }

    // Add remaining text
    if (currentText.isNotEmpty) {
      spans.add(_createSpan(currentText.toString(), currentStyleSet));
    }

    return spans;
  }

  bool _setEquals(Set<TextStyleType> set1, Set<TextStyleType> set2) {
    if (set1.length != set2.length) return false;
    return set1.containsAll(set2);
  }

  TextSpan _createSpan(String text, Set<TextStyleType> types) {
    Color color = Colors.black;
    FontWeight fontWeight = FontWeight.normal;
    Color? backgroundColor;

    // Style application priority and combination logic
    if (types.contains(TextStyleType.bold)) {
      fontWeight = FontWeight.bold;
      color = const Color(0xFF1B5E20); // Dark Green
    }

    if (types.contains(TextStyleType.highlight)) {
      backgroundColor = const Color(0xFFFFF59D); // Yellow Background
    }

    return TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontWeight: fontWeight,
        backgroundColor: backgroundColor,
      ),
    );
  }
}
