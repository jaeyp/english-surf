import 'dart:ui';

class OcrBlock {
  final String text;
  final Rect rect;
  final List<String> cornerPoints;

  OcrBlock({
    required this.text,
    required this.rect,
    this.cornerPoints = const [],
  });
}
