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

    // 1. 각 문자별로 적용될 스타일 목록을 매핑
    // List<Set<TextStyleType>>
    final List<Set<TextStyleType>> charStyles = List.generate(
      text.length,
      (_) => {},
    );

    for (var style in styles) {
      // 범위 유효성 검사
      final start = style.start.clamp(0, text.length);
      final end = style.end.clamp(0, text.length);

      for (int i = start; i < end; i++) {
        charStyles[i].add(style.type);
      }
    }

    // 2. 연속된 스타일을 가진 문자들을 그룹화하여 TextSpan 생성
    final List<TextSpan> spans = [];

    if (text.isEmpty) return spans;

    StringBuffer currentText = StringBuffer();
    Set<TextStyleType> currentStyleSet = charStyles[0];
    currentText.write(text[0]);

    for (int i = 1; i < text.length; i++) {
      final nextStyleSet = charStyles[i];

      // 스타일이 같으면 계속 텍스트 추가
      if (_setEquals(currentStyleSet, nextStyleSet)) {
        currentText.write(text[i]);
      } else {
        // 스타일이 달라지면 지금까지의 텍스트를 Span으로 추가하고 초기화
        spans.add(_createSpan(currentText.toString(), currentStyleSet));
        currentText.clear();
        currentText.write(text[i]);
        currentStyleSet = nextStyleSet;
      }
    }

    // 마지막 남은 텍스트 추가
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

    // 스타일 적용 우선순위 및 조합 로직
    if (types.contains(TextStyleType.bold)) {
      fontWeight = FontWeight.bold;
      color = const Color(0xFF1B5E20); // 짙은 녹색
    }

    if (types.contains(TextStyleType.highlight)) {
      backgroundColor = const Color(0xFFFFF59D); // 노란색 배경
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
