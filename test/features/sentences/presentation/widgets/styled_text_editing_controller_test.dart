import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:english_surf/features/sentences/presentation/widgets/styled_text_editing_controller.dart';
import 'package:english_surf/features/sentences/domain/value_objects/text_style.dart'
    as domain;
import 'package:english_surf/features/sentences/domain/enums/text_style_type.dart';

void main() {
  group('StyledTextEditingController Smart Tracking', () {
    test('should shift styles forward when text is inserted before them', () {
      final style = domain.TextStyle(
        type: TextStyleType.bold,
        start: 5,
        end: 10,
      );
      final controller = StyledTextEditingController(
        text: 'Hello World',
        styles: [style],
      );

      // Simulate inserting "Great " at the beginning (length 6)
      controller.value = const TextEditingValue(
        text: 'Great Hello World',
        selection: TextSelection.collapsed(offset: 6),
      );

      expect(controller.styles.first.start, 5 + 6);
      expect(controller.styles.first.end, 10 + 6);
    });

    test('should expand styles when text is inserted inside them', () {
      final style = domain.TextStyle(
        type: TextStyleType.bold,
        start: 6,
        end: 11,
      );
      final controller = StyledTextEditingController(
        text: 'Hello World',
        styles: [style],
      );

      // "World" is at 6..11. Change to "Wonder World" (insert "nder " at index 8)
      controller.value = const TextEditingValue(
        text: 'Hello Wonder World',
        selection: TextSelection.collapsed(offset: 13),
      );

      expect(controller.styles.first.start, 6);
      expect(controller.styles.first.end, 11 + 7); // 7 chars added
    });

    test('should remove style if the text containing it is deleted', () {
      final style = domain.TextStyle(
        type: TextStyleType.bold,
        start: 6,
        end: 11,
      );
      final controller = StyledTextEditingController(
        text: 'Hello World',
        styles: [style],
      );

      // Delete " World"
      controller.value = const TextEditingValue(
        text: 'Hello',
        selection: TextSelection.collapsed(offset: 5),
      );

      expect(controller.styles, isEmpty);
    });
  });
}
