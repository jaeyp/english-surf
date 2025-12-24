import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'coordinates_translator.dart';

class DisplayBlock {
  final String text;
  final Rect rect;

  DisplayBlock({required this.text, required this.rect});
}

class OcrProcessor {
  /// Processes raw ML Kit text blocks into refined DisplayBlocks.
  /// 1. Filters out noise (short text).
  /// 2. Merges adjacent lines into paragraphs (using punctuation and gap heuristics).
  /// 3. Forces full width and computes dynamic height.
  static List<DisplayBlock> processBlocks(
    RecognizedText recognizedText,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation,
  ) {
    final rawBlocks = recognizedText.blocks;
    if (rawBlocks.isEmpty) return [];

    // 1. Convert to DisplayBlock with mapped coordinates
    List<DisplayBlock> displayBlocks = [];

    for (var block in rawBlocks) {
      // Filter noise: < 10 chars
      if (block.text.length < 10) continue;

      final rect = _mapToScreen(
        block.boundingBox,
        canvasSize,
        imageSize,
        rotation,
      );
      // Replace newlines with spaces for cleaner display
      final cleanedText = block.text
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      displayBlocks.add(DisplayBlock(text: cleanedText, rect: rect));
    }

    // 2. Sort by Y position (Top to Bottom)
    displayBlocks.sort((a, b) => a.rect.top.compareTo(b.rect.top));

    // 3. Merge Heuristic (with paragraph awareness)
    List<DisplayBlock> mergedBlocks = [];
    if (displayBlocks.isEmpty) return [];

    DisplayBlock current = displayBlocks.first;

    for (int i = 1; i < displayBlocks.length; i++) {
      final next = displayBlocks[i];

      if (_shouldMerge(current, next)) {
        current = _merge(current, next);
      } else {
        mergedBlocks.add(current);
        current = next;
      }
    }
    mergedBlocks.add(current);

    // 4. Force Full Width and Compute Dynamic Height
    const double kHorizontalMargin = 16.0;
    const double kLineHeight = 22.0;
    const int kCharsPerLine = 45;
    const double kVerticalPadding = 16.0;

    return mergedBlocks.map((b) {
      final estimatedLines = (b.text.length / kCharsPerLine).ceil().clamp(
        1,
        10,
      );
      final estimatedHeight = (estimatedLines * kLineHeight) + kVerticalPadding;

      return DisplayBlock(
        text: b.text,
        rect: Rect.fromLTRB(
          kHorizontalMargin,
          b.rect.top,
          canvasSize.width - kHorizontalMargin,
          b.rect.top + estimatedHeight,
        ),
      );
    }).toList();
  }

  /// Check if block A should merge with block B.
  static bool _shouldMerge(DisplayBlock a, DisplayBlock b) {
    // 0. Paragraph Boundary Check (Punctuation)
    final trimmedA = a.text.trim();
    if (trimmedA.endsWith('.') ||
        trimmedA.endsWith('!') ||
        trimmedA.endsWith('?') ||
        trimmedA.endsWith('"') ||
        trimmedA.endsWith("'")) {
      return false;
    }

    // 1. Vertical Distance Check (Stricter)
    final verticalGap = b.rect.top - a.rect.bottom;
    if (verticalGap > a.rect.height * 0.8) {
      return false;
    }
    if (verticalGap < -a.rect.height * 0.3) {
      return false;
    }

    // 2. Horizontal Alignment Check
    final horizontalIntersect =
        (a.rect.left < b.rect.right) && (a.rect.right > b.rect.left);
    if (!horizontalIntersect) {
      return false;
    }

    return true;
  }

  static DisplayBlock _merge(DisplayBlock a, DisplayBlock b) {
    final newRect = a.rect.expandToInclude(b.rect);
    final newText = '${a.text} ${b.text}';
    return DisplayBlock(text: newText, rect: newRect);
  }

  static Rect _mapToScreen(
    Rect boundingBox,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation,
  ) {
    final left = translateX(boundingBox.left, canvasSize, imageSize, rotation);
    final top = translateY(boundingBox.top, canvasSize, imageSize, rotation);
    final right = translateX(
      boundingBox.right,
      canvasSize,
      imageSize,
      rotation,
    );
    final bottom = translateY(
      boundingBox.bottom,
      canvasSize,
      imageSize,
      rotation,
    );
    return Rect.fromLTRB(left, top, right, bottom);
  }
}
