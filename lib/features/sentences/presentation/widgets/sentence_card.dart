import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/sentence.dart';
import 'sentence_text_view.dart';

class SentenceCard extends StatefulWidget {
  final Sentence sentence;
  final bool isFront;

  const SentenceCard({super.key, required this.sentence, this.isFront = true});

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
    _isFront = widget.isFront;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isAnimating) return;

    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isUnder90 = angle < pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isUnder90
                ? _buildFront()
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardBase({required Widget child}) {
    return Card(
      elevation: 4,
      color: const Color(0xFFF1F8E9), // 연한 파스텔 녹색
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        height: 300, // TODO: Make this responsive or dynamic
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildFront() {
    return _buildCardBase(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SentenceTextView(
            sentenceText: widget.sentence.original,
            fontSize: 24,
          ),
          const SizedBox(height: 20),
          const Text(
            '💡 Tap to see answer',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return _buildCardBase(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.sentence.translation,
            style: const TextStyle(fontSize: 20, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          if (widget.sentence.notes.isNotEmpty) ...[
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
      ),
    );
  }
}
