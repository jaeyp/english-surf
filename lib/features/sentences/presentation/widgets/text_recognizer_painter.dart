import 'package:flutter/material.dart';
import '../utils/ocr_processor.dart';

class TextRecognizerPainter extends CustomPainter {
  final List<DisplayBlock> displayBlocks;
  final Set<String> selectedTextBlocks;

  TextRecognizerPainter(this.displayBlocks, this.selectedTextBlocks);

  @override
  void paint(Canvas canvas, Size size) {
    for (final block in displayBlocks) {
      // The block.rect is already in screen coordinates (from OcrProcessor)
      // We just need to inflate it slightly for the bubble effect
      final rect = block.rect.inflate(6.0);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12.0));

      final isSelected = selectedTextBlocks.contains(block.text);

      // 1. Draw Bubble Background
      final Paint bubblePaint = Paint()
        ..color = isSelected
            ? Colors.green.withValues(alpha: 0.9)
            : const Color(0xFFEEEEEE).withValues(alpha: 0.95)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rrect, bubblePaint);

      // 2. Draw Bubble Border
      final Paint borderPaint = Paint()
        ..color = isSelected ? Colors.green.shade900 : Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRRect(rrect, borderPaint);

      // 3. Draw Text
      final textStyle = TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      );

      final textSpan = TextSpan(text: block.text, style: textStyle);

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        maxLines: 50, // Allow many lines
        textAlign: TextAlign.left,
      );

      textPainter.layout(
        minWidth: 0,
        maxWidth: rect.width - 16.0, // Internal padding
      );

      // Align text: Left side with padding, Vertically centered
      final offset = Offset(
        rect.left + 8.0,
        rect.top + (rect.height - textPainter.height) / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(TextRecognizerPainter oldDelegate) {
    return oldDelegate.displayBlocks != displayBlocks ||
        oldDelegate.selectedTextBlocks != selectedTextBlocks;
  }
}
