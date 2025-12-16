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
    // 모드에 따른 앞/뒷면 내용 결정
    final isOriginalFront =
        widget.languageMode == LanguageMode.originalToTranslation;

    return GestureDetector(
      onTap: _flipCard,
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
                      // 뒷면 내용: 항상 상세 내용(notes) 포함
                      content: isOriginalFront
                          ? _buildTranslationContent(
                              showNotes: true,
                            ) // Orig->Trans: 뒷면 번역+노트
                          : _buildOriginalContent(
                              showNotes: true,
                            ), // Trans->Orig: 뒷면 원문+노트
                    ),
                  )
                : _buildCardFace(
                    isFront: true,
                    // 앞면 내용: 상세 내용(notes) 미포함
                    content: isOriginalFront
                        ? _buildOriginalContent(
                            showNotes: false,
                          ) // Orig->Trans: 앞면 원문
                        : _buildTranslationContent(
                            showNotes: false,
                          ), // Trans->Orig: 앞면 번역
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
        if (showNotes && widget.sentence.notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            widget.sentence.notes,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildTranslationContent({bool showNotes = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.sentence.translation,
          style: const TextStyle(
            fontSize: 22,
            height: 1.5,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        if (showNotes && widget.sentence.notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            widget.sentence.notes,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
