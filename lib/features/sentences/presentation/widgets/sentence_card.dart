import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/sentence.dart';
import '../../application/providers/sentence_providers.dart'; // LanguageMode
import 'sentence_text_view.dart';

class SentenceCard extends StatefulWidget {
  final Sentence sentence;
  final LanguageMode languageMode;

  const SentenceCard({
    super.key,
    required this.sentence,
    required this.languageMode,
  });

  @override
  State<SentenceCard> createState() => _SentenceCardState();
}

class _SentenceCardState extends State<SentenceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    // Determine content for front/back based on mode
    final isOriginalFront =
        widget.languageMode == LanguageMode.originalToTranslation;

    return GestureDetector(
      onTap: _flipCard,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isBack = angle >= pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildCardFace(
                      isFront: false,
                      // Back Content: Always include notes
                      content: isOriginalFront
                          ? _buildTranslationContent(
                              showNotes: true,
                            ) // Orig->Trans: Back shows Translation + Notes
                          : _buildOriginalContent(
                              showNotes: true,
                            ), // Trans->Orig: Back shows Original + Notes
                    ),
                  )
                : _buildCardFace(
                    isFront: true,
                    // Front Content: No notes
                    content: isOriginalFront
                        ? _buildOriginalContent(
                            showNotes: false,
                          ) // Orig->Trans: Front shows Original
                        : _buildTranslationContent(
                            showNotes: false,
                          ), // Trans->Orig: Front shows Translation
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardFace({required bool isFront, required Widget content}) {
    return Card(
      elevation: 4,
      color: const Color(0xFFF1F8E9), // Light Pastel Green
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        height: 400, // Fixed height for card
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Center(child: content)),
            if (isFront) ...[
              const SizedBox(height: 16),
              const Text(
                '💡 Tap to see answer',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOriginalContent({bool showNotes = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SentenceTextView(sentenceText: widget.sentence.original, fontSize: 24),
        if (showNotes) ...[
          if (widget.sentence.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            SelectableText(
              widget.sentence.notes,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
          if (widget.sentence.examples.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Examples:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            ...widget.sentence.examples.map(
              (example) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: SelectableText(
                  example,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildTranslationContent({bool showNotes = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectableText(
          widget.sentence.translation,
          style: const TextStyle(
            fontSize: 22,
            height: 1.5,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        if (showNotes) ...[
          if (widget.sentence.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            SelectableText(
              widget.sentence.notes,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
          if (widget.sentence.examples.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Examples:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            ...widget.sentence.examples.map(
              (example) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: SelectableText(
                  example,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
