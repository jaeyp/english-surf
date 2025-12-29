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
  /// 1. Optionally filters by focus region (in image coordinates).
  /// 2. Filters out noise (short text).
  /// 3. Merges adjacent lines into paragraphs (using punctuation and gap heuristics).
  /// 4. Forces full width and computes dynamic height.
  ///
  /// [focusRegion] - Optional rect in normalized coordinates (0.0 to 1.0).
  ///   For portrait: filters by vertical position (e.g., (0, 0.33, 1, 0.33) for middle third)
  ///   For landscape: filters by horizontal position
  static List<DisplayBlock> processBlocks(
    RecognizedText recognizedText,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation, {
    Rect? focusRegion,
  }) {
    final rawBlocks = recognizedText.blocks;
    if (rawBlocks.isEmpty) return [];

    // 1. Convert to DisplayBlock with mapped coordinates
    List<DisplayBlock> displayBlocks = [];

    for (var block in rawBlocks) {
      // Filter noise: < 10 chars
      if (block.text.length < 10) continue;

      // Filter by focus region if provided (using normalized image coordinates)
      if (focusRegion != null) {
        final centerY = block.boundingBox.center.dy / imageSize.height;
        final centerX = block.boundingBox.center.dx / imageSize.width;

        // Check based on orientation
        final isLandscape = imageSize.width > imageSize.height;
        if (isLandscape) {
          // For landscape images, filter by horizontal position
          if (centerX < focusRegion.left || centerX > focusRegion.right) {
            continue;
          }
        } else {
          // For portrait images, filter by vertical position
          if (centerY < focusRegion.top || centerY > focusRegion.bottom) {
            continue;
          }
        }
      }

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
    const double kLineHeight = 20.0;
    const int kCharsPerLine = 45;
    const double kVerticalPadding = 8.0;

    // Stack blocks consecutively from top of focus region with fixed gap
    const double kStartY = 280.0; // Start from below safe area
    const double kGapBetweenBlocks = 24.0;

    List<DisplayBlock> stackedBlocks = [];
    double currentY = kStartY;

    for (final b in mergedBlocks) {
      final estimatedLines = (b.text.length / kCharsPerLine).ceil().clamp(
        1,
        10,
      );
      final estimatedHeight = (estimatedLines * kLineHeight) + kVerticalPadding;

      stackedBlocks.add(
        DisplayBlock(
          text: b.text,
          rect: Rect.fromLTRB(
            kHorizontalMargin,
            currentY,
            canvasSize.width - kHorizontalMargin,
            currentY + estimatedHeight,
          ),
        ),
      );

      currentY += estimatedHeight + kGapBetweenBlocks;
    }

    return stackedBlocks;
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
