import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/sentence_providers.dart';
import '../widgets/sentence_card.dart';

class StudyModeScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  final bool isTestMode;

  const StudyModeScreen({
    super.key,
    this.initialIndex = 0,
    this.isTestMode = false,
  });

  @override
  ConsumerState<StudyModeScreen> createState() => _StudyModeScreenState();
}

class _StudyModeScreenState extends ConsumerState<StudyModeScreen> {
  late PageController _pageController;
  late int _currentIndex;
  Timer? _timer;
  int _timeLeft = 5;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    if (widget.isTestMode) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 5;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _nextPage();
          }
        });
      }
    });
  }

  void _nextPage() {
    final sentences = ref.read(filteredSentencesProvider).value ?? [];
    if (_currentIndex < sentences.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // Timer will be restarted by onPageChanged
    } else {
      _timer?.cancel(); // Stop at the end
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentencesAsync = ref.watch(filteredSentencesProvider);
    final languageMode =
        ref.watch(languageModeProvider).value ??
        LanguageMode.translationToOriginal;

    return sentencesAsync.when(
      data: (sentences) {
        if (sentences.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Study Mode')),
            body: const Center(child: Text('No sentences to study.')),
          );
        }

        // Extremely safe index calculation
        final safeIndex = _currentIndex < sentences.length
            ? (_currentIndex < 0 ? 0 : _currentIndex)
            : sentences.length - 1;

        if (safeIndex != _currentIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _currentIndex = safeIndex;
              });
            }
          });
        }

        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        final currentSentence = sentences[safeIndex];

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: isLandscape
                ? 40
                : null, // Reduced height in landscape
            title: isLandscape
                ? null // Hide title in landscape to save vertical space
                : Text('${safeIndex + 1} / ${sentences.length}'),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () =>
                      context.push('/edit', extra: currentSentence),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete'),
                        content: const Text('Are you sure?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref
                          .read(sentenceListProvider.notifier)
                          .deleteSentence(currentSentence.id);
                      if (sentences.length <= 1) {
                        if (context.mounted) Navigator.pop(context);
                      }
                    }
                  },
                ),
              ],
            ),
            leadingWidth: 100,
            actions: [
              if (isLandscape)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      '${safeIndex + 1} / ${sentences.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: sentences.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                          if (widget.isTestMode) {
                            _startTimer();
                          }
                        },
                        itemBuilder: (context, index) {
                          if (index >= sentences.length) {
                            return const SizedBox.shrink();
                          }
                          return SentenceCard(
                            sentence: sentences[index],
                            languageMode: languageMode,
                            padding: EdgeInsets.symmetric(
                              horizontal: isLandscape ? 32.0 : 16.0,
                              vertical: isLandscape ? 8.0 : 16.0,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _buildTimerOverlay(),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTimerOverlay() {
    if (!widget.isTestMode) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: Text(
          '$_timeLeft',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
