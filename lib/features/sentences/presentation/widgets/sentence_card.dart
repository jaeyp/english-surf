import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/sentence.dart';
import '../../application/providers/sentence_providers.dart'; // LanguageMode
import 'sentence_text_view.dart';

class SentenceCard extends StatefulWidget {
  final Sentence sentence;
  final LanguageMode languageMode;
  final EdgeInsets padding;
  final ValueChanged<bool>? onFlip;
  final VoidCallback? onFavoriteToggle;

  const SentenceCard({
    super.key,
    required this.sentence,
    required this.languageMode,
    this.padding = EdgeInsets.zero,
    this.onFlip,
    this.onFavoriteToggle,
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
    widget.onFlip?.call(!_isFront);
  }

  @override
  Widget build(BuildContext context) {
    // Determine content for front/back based on mode
    final isOriginalFront =
        widget.languageMode == LanguageMode.originalToTranslation;

    return GestureDetector(
      onTap: _flipCard,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: widget.padding,
        child: Center(
          child: SizedBox(
            height: 400, // Keep fixed height for visual card
            width: double.infinity,
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
                            content: isOriginalFront
                                ? _buildTranslationContent(showNotes: true)
                                : _buildOriginalContent(showNotes: true),
                          ),
                        )
                      : _buildCardFace(
                          isFront: true,
                          content: isOriginalFront
                              ? _buildOriginalContent(showNotes: false)
                              : _buildTranslationContent(showNotes: false),
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFace({required bool isFront, required Widget content}) {
    return Card(
      elevation: 4,
      color: const Color(0xFFF1F8E9), // Light Pastel Green
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 400, // Fixed height for card
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(child: content),
                        ),
                      );
                    },
                  ),
                ),
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
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              icon: Icon(
                widget.sentence.isFavorite ? Icons.star : Icons.star_border,
                size: 28,
                color: widget.sentence.isFavorite ? Colors.teal : Colors.grey,
              ),
              onPressed: widget.onFavoriteToggle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledNotes(String notes) {
    if (notes.isEmpty) return const SizedBox.shrink();

    final lines = notes.split('\n');

    return Column(
      children: lines.map((line) {
        final splitIndex = line.indexOf(':');

        if (splitIndex != -1) {
          final expression = line.substring(0, splitIndex);
          final rest = line.substring(splitIndex);

          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 14, height: 1.4),
                children: [
                  TextSpan(
                    text: expression,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: rest,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Fallback if no ':' found
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              line,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          );
        }
      }).toList(),
    );
  }

  double _getAdaptiveFontSize(
    int textLength, {
    required bool isOriginal,
    required bool showNotes,
  }) {
    double baseSize;
    double offset = 0;
    if (isOriginal) {
      if (textLength < 100) {
        baseSize = 24;
        offset = 2;
      } else if (textLength < 200) {
        baseSize = 22;
        offset = 1;
      } else {
        baseSize = 20;
      }
    } else {
      // Translation tends to be shorter/denser in Korean
      if (textLength < 80) {
        baseSize = 22;
        offset = 1;
      } else if (textLength < 160) {
        baseSize = 20;
        offset = 1;
      } else {
        baseSize = 18;
      }
    }

    if (!showNotes) return baseSize;

    return baseSize - offset;
  }

  Widget _buildOriginalContent({bool showNotes = false}) {
    final fontSize = _getAdaptiveFontSize(
      widget.sentence.original.text.length,
      isOriginal: true,
      showNotes: showNotes,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: showNotes
              ? const EdgeInsets.fromLTRB(4, 12, 4, 4)
              : const EdgeInsets.only(top: 12),
          child: SentenceTextView(
            sentenceText: widget.sentence.original,
            fontSize: fontSize,
          ),
        ),
        if (showNotes) ...[
          if (widget.sentence.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildStyledNotes(widget.sentence.notes),
          ],
          if (widget.sentence.paraphrases.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Paraphrases:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.sentence.paraphrases.map(
              (paraphrase) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  paraphrase,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
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
    final fontSize = _getAdaptiveFontSize(
      widget.sentence.translation.length,
      isOriginal: false,
      showNotes: showNotes,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: showNotes
              ? const EdgeInsets.fromLTRB(4, 12, 4, 4)
              : const EdgeInsets.only(top: 12),
          child: Text(
            widget.sentence.translation,
            style: TextStyle(
              fontSize: fontSize,
              height: showNotes ? 1.4 : 1.5,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        if (showNotes) ...[
          if (widget.sentence.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildStyledNotes(widget.sentence.notes),
          ],
          if (widget.sentence.paraphrases.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Paraphrases:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.sentence.paraphrases.map(
              (paraphrase) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  paraphrase,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
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
