import 'package:flutter/material.dart';
import '../../domain/value_objects/text_style.dart' as domain;
import '../../domain/enums/text_style_type.dart';

class StyledTextEditingController extends TextEditingController {
  List<domain.TextStyle> styles;
  String _lastText = '';

  StyledTextEditingController({super.text, required this.styles}) {
    _lastText = text;
    addListener(_handleTextChange);
  }

  void _handleTextChange() {
    if (text == _lastText) return;

    final newText = text;
    final oldText = _lastText;
    _lastText = newText;

    if (styles.isEmpty) return;

    // Determine what changed using selection (crude but works for basic editing)
    final diff = newText.length - oldText.length;
    final selection = this.selection;

    if (diff != 0 && selection.isValid) {
      // Approximate where the change happened
      final changeEnd = selection.end;
      final changeStart = diff > 0 ? changeEnd - diff : changeEnd;

      final updatedStyles = <domain.TextStyle>[];

      for (var style in styles) {
        int start = style.start;
        int end = style.end;

        if (diff > 0) {
          // Addition
          if (changeStart < start) {
            // Added strictly before the style: shift both
            start += diff;
            end += diff;
          } else if (changeStart <= end) {
            // Added inside or at the boundaries: expand end
            end += diff;
          }
        } else {
          // Deletion
          final deletedLen = -diff;
          final deletionEnd = changeStart + deletedLen;

          // If the deletion overlap with the style
          if (deletionEnd <= start) {
            // Deleted before style: shift both
            start -= deletedLen;
            end -= deletedLen;
          } else if (changeStart >= end) {
            // Deleted after style: do nothing
          } else {
            // Deletion overlaps with style
            // 1. Calculate how much of the style was deleted
            final overlapStart = start < changeStart ? changeStart : start;
            final overlapEnd = end < deletionEnd ? end : deletionEnd;
            final overlapped = overlapEnd - overlapStart;

            if (changeStart <= start) {
              // Deletion started before or at start
              start = changeStart;
            }
            end -= overlapped;
          }
        }

        // Validity check: skip styles that were completely deleted or collapsed
        if (start < end && start >= 0 && end <= newText.length) {
          updatedStyles.add(style.copyWith(start: start, end: end));
        }
      }
      styles = updatedStyles;
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (styles.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    final String text = value.text;
    final List<TextSpan> children = [];

    for (int i = 0; i < text.length; i++) {
      Color color = style?.color ?? Colors.black;
      FontWeight fontWeight = style?.fontWeight ?? FontWeight.normal;
      Color? backgroundColor;

      final charStyles = styles.where((s) => i >= s.start && i < s.end);

      for (var s in charStyles) {
        if (s.type == TextStyleType.bold) {
          fontWeight = FontWeight.bold;
          color = const Color(0xFF1B5E20);
        } else if (s.type == TextStyleType.highlight) {
          backgroundColor = const Color(0xFFFFF59D);
        }
      }

      children.add(
        TextSpan(
          text: text[i],
          style: style?.copyWith(
            color: color,
            fontWeight: fontWeight,
            backgroundColor: backgroundColor,
          ),
        ),
      );
    }

    return TextSpan(style: style, children: children);
  }
}
