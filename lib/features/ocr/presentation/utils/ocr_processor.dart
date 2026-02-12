import 'dart:ui';
import 'dart:math' as math;
import '../../domain/models/ocr_block.dart';
import '../../../../features/sentences/domain/enums/script_type.dart';
import 'coordinates_translator.dart';

/// Constants for OCR Logic
class OcrConstants {
  static const int minTextLength = 5;

  // Merge Thresholds (relative to average line height)
  static const double gapThreshold = 0.5;
  static const double leftIndentMin = 0.5;
  static const double leftIndentMax = 8.0;
  static const double rightIndentThreshold = 2.5;

  // Layout Constants
  static const double layoutHorizontalMargin = 16.0;
  static const double layoutLineHeight = 24.0;
  static const int layoutCharsPerLine = 40;
  static const double layoutVerticalPadding = 12.0;
  static const double layoutStartY = 120.0;
  static const double layoutBlockGap = 16.0;
  static const int layoutMaxEstimatedLines = 10;
}

class DisplayBlock {
  final String text;
  final Rect rect;

  DisplayBlock({required this.text, required this.rect});
}

class OcrProcessor {
  /// Processes raw OCR blocks into refined DisplayBlocks.
  static List<DisplayBlock> processBlocks(
    List<OcrBlock> rawBlocks,
    Size canvasSize,
    Size imageSize,
    int rotationDegrees, {
    Rect? focusRegion,
    bool shouldMerge = true,
  }) {
    if (rawBlocks.isEmpty) return [];

    // 1. Prepare: Map coordinates, clean text, filter noise, sort
    List<DisplayBlock> blocks = _prepareBlocks(
      rawBlocks,
      canvasSize,
      imageSize,
      rotationDegrees,
      focusRegion,
    );

    if (blocks.isEmpty) return [];

    // 2. Merge Logic: Group into paragraphs then merge
    List<DisplayBlock> mergedBlocks = [];
    if (!shouldMerge) {
      mergedBlocks = blocks;
    } else {
      final paragraphs = _groupBlocksIntoParagraphs(blocks);
      mergedBlocks = _mergeParagraphBlocks(paragraphs);
    }

    // 3. Layout: Stack blocks for display
    return _layoutBlocks(mergedBlocks, canvasSize);
  }

  // ---------------------------------------------------------------------------
  // Phase 1: Preparation (Map, Filter, Sort)
  // ---------------------------------------------------------------------------

  static List<DisplayBlock> _prepareBlocks(
    List<OcrBlock> rawBlocks,
    Size canvasSize,
    Size imageSize,
    int rotationDegrees,
    Rect? focusRegion,
  ) {
    List<DisplayBlock> displayBlocks = [];

    // Calculate absolute focus rect if region is provided
    Rect? absoluteFocusRect;
    if (focusRegion != null) {
      absoluteFocusRect = Rect.fromLTRB(
        focusRegion.left * canvasSize.width,
        focusRegion.top * canvasSize.height,
        focusRegion.right * canvasSize.width,
        focusRegion.bottom * canvasSize.height,
      );
    }

    for (var block in rawBlocks) {
      // Filter noise: too short
      if (block.text.length < OcrConstants.minTextLength) continue;

      final rect = _mapToScreen(
        block.rect,
        canvasSize,
        imageSize,
        rotationDegrees,
      );

      // Filter by Focus Region
      if (absoluteFocusRect != null &&
          !absoluteFocusRect.contains(rect.center)) {
        continue;
      }

      // Clean text
      final cleanedText = block.text
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      displayBlocks.add(DisplayBlock(text: cleanedText, rect: rect));
    }

    // Sort by Reading Order (Top-Down, Left-Right)
    displayBlocks.sort((a, b) {
      final yDiff = a.rect.top.compareTo(b.rect.top);
      if (yDiff != 0) return yDiff;
      return a.rect.left.compareTo(b.rect.left);
    });

    return displayBlocks;
  }

  // ---------------------------------------------------------------------------
  // Phase 2: Grouping & Merging
  // ---------------------------------------------------------------------------

  static List<List<DisplayBlock>> _groupBlocksIntoParagraphs(
    List<DisplayBlock> blocks,
  ) {
    List<List<DisplayBlock>> paragraphs = [];
    List<DisplayBlock> currentParagraph = [blocks.first];
    bool forceSplitNext = false;

    for (int i = 0; i < blocks.length - 1; i++) {
      final a = blocks[i];
      final b = blocks[i + 1];
      final avgH = (a.rect.height + b.rect.height) / 2;

      // Calculate Paragraph Context (Longest line so far in current paragraph)
      // In mirrored world, Left is End. Smallest Left = Most Right End = Longest Line.
      final paraMinLeft = currentParagraph
          .map((blk) => blk.rect.left)
          .reduce(math.min);

      bool split = false;
      // String reason = ""; // Debug reason, can be removed or logged if needed

      // 0. Check forced split from previous iteration
      if (forceSplitNext) {
        split = true;
        // reason = "Forced Split";
        forceSplitNext = false;
      }

      // Rule 0: Script Mismatch
      // If blocks use different scripts (e.g., Latin vs Korean), force a split.
      if (!split) {
        if (_detectScriptType(a.text) != _detectScriptType(b.text)) {
          split = true;
          // reason = "Script Mismatch";
        }
      }

      // Rule 1: Vertical Gap
      if (!split) {
        final gap = b.rect.top - a.rect.bottom;
        if (gap > avgH * OcrConstants.gapThreshold) {
          split = true;
          // reason = "Vertical Gap";
        }
      }

      // Rule 2: Left Indentation (Paragraph Start)
      if (!split) {
        final rightDiff =
            a.rect.right - b.rect.right; // Positive if B is indented
        if (rightDiff > avgH * OcrConstants.leftIndentMin &&
            rightDiff < avgH * OcrConstants.leftIndentMax) {
          split = true;
          // reason = "Left Indent";
        }
      }

      // Rule 3: Right Indentation (Paragraph End / Short Line)
      if (!split) {
        final leftDiff = a.rect.left - paraMinLeft;
        if (leftDiff > avgH * OcrConstants.rightIndentThreshold) {
          // Defer split: Merge A & B, but force split AFTER B
          forceSplitNext = true;
          // reason = "Right Indent (Deferred Split)";
        }
      }

      // Execute Split or Merge
      if (split) {
        paragraphs.add(currentParagraph);
        currentParagraph = [b];
      } else {
        currentParagraph.add(b);
      }
    }
    paragraphs.add(currentParagraph);
    return paragraphs;
  }

  static List<DisplayBlock> _mergeParagraphBlocks(
    List<List<DisplayBlock>> paragraphs,
  ) {
    List<DisplayBlock> mergedBlocks = [];
    for (var paragraph in paragraphs) {
      if (paragraph.isEmpty) continue;

      DisplayBlock merged = paragraph.first;
      for (int i = 1; i < paragraph.length; i++) {
        merged = _mergeTwoBlocks(merged, paragraph[i]);
      }
      mergedBlocks.add(merged);
    }
    return mergedBlocks;
  }

  static DisplayBlock _mergeTwoBlocks(DisplayBlock a, DisplayBlock b) {
    final newRect = a.rect.expandToInclude(b.rect);
    final separator = (a.text.endsWith('-')) ? '' : ' ';
    final newText = '${a.text}$separator${b.text}';
    return DisplayBlock(text: newText, rect: newRect);
  }

  // ---------------------------------------------------------------------------
  // Phase 3: Layout
  // ---------------------------------------------------------------------------

  static List<DisplayBlock> _layoutBlocks(
    List<DisplayBlock> blocks,
    Size canvasSize,
  ) {
    List<DisplayBlock> stackedBlocks = [];
    double currentY = OcrConstants.layoutStartY;

    for (final b in blocks) {
      final estimatedLines = (b.text.length / OcrConstants.layoutCharsPerLine)
          .ceil()
          .clamp(1, OcrConstants.layoutMaxEstimatedLines);

      final estimatedHeight =
          (estimatedLines * OcrConstants.layoutLineHeight) +
          OcrConstants.layoutVerticalPadding;

      stackedBlocks.add(
        DisplayBlock(
          text: b.text,
          rect: Rect.fromLTRB(
            OcrConstants.layoutHorizontalMargin,
            currentY,
            canvasSize.width - OcrConstants.layoutHorizontalMargin,
            currentY + estimatedHeight,
          ),
        ),
      );

      currentY += estimatedHeight + OcrConstants.layoutBlockGap;
    }

    return stackedBlocks;
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  static Rect _mapToScreen(
    Rect boundingBox,
    Size canvasSize,
    Size imageSize,
    int rotation,
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

  /// Detect the script type of text for merge logic.
  static ScriptType _detectScriptType(String text) {
    if (RegExp(r'[가-힣]').hasMatch(text)) return ScriptType.korean;
    return ScriptType.latin;
  }
}
