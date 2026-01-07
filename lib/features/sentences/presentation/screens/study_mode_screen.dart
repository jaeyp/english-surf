import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/sentence.dart';
import '../../domain/value_objects/sentence_text.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/sort_type.dart';
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
  int _timeLeft = 10;
  int _timerDuration = 10;
  bool _isFlipped = false;
  bool _isPaused = false;
  bool _showDurationPicker = false;

  // Stable list of IDs to prevent cards from disappearing during the session
  List<int>? _initialSentenceIds;

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
    if (!mounted) return;
    setState(() {
      _timeLeft = _timerDuration;
      _isFlipped = false;
    });
    _resumeTimer();
  }

  void _resumeTimer() {
    _timer?.cancel();
    if (!mounted || !widget.isTestMode) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_isFlipped || _showDurationPicker) {
          timer.cancel(); // Safety: cancel if flipped or picker open
          return;
        }

        setState(() {
          if (_isPaused) return; // Stop countdown if paused

          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _nextPage();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _nextPage() {
    if (_initialSentenceIds == null || _initialSentenceIds!.isEmpty) return;

    if (_currentIndex < _initialSentenceIds!.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (widget.isTestMode) {
      // Repeat logic for Test Mode
      final filterState = ref.read(sentenceFilterProvider).value;
      if (filterState?.sortType == SortType.random) {
        setState(() {
          _initialSentenceIds!.shuffle();
        });
      }
      _pageController.jumpToPage(0);
    } else {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch the filtered list ONLY to initialize the stable IDs
    final filteredSentencesAsync = ref.watch(filteredSentencesProvider);

    // 2. Watch the full raw list to get reactive updates for each card
    final rawSentencesAsync = ref.watch(sentenceListProvider);

    final languageMode =
        ref.watch(languageModeProvider).value ??
        LanguageMode.translationToOriginal;

    // Initialize stable IDs once data is available
    if (_initialSentenceIds == null && filteredSentencesAsync.hasValue) {
      _initialSentenceIds = filteredSentencesAsync.value!
          .map((s) => s.id)
          .toList();
    }

    // Sync persistent timer duration
    final persistentDuration = ref.watch(timerDurationProvider).value ?? 10;
    if (_timerDuration != persistentDuration && !_showDurationPicker) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _timerDuration = persistentDuration;
            if (widget.isTestMode && _timeLeft > persistentDuration) {
              _timeLeft = persistentDuration;
            }
          });
        }
      });
    }

    return rawSentencesAsync.when(
      data: (allSentences) {
        if (_initialSentenceIds == null || _initialSentenceIds!.isEmpty) {
          // If we had no filtered sentences to begin with
          if (filteredSentencesAsync.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Study Mode')),
            body: const Center(child: Text('No sentences to study.')),
          );
        }

        // Map stable IDs to their latest data from the raw list
        final sentences = _initialSentenceIds!
            .map((id) {
              return allSentences.firstWhere(
                (s) => s.id == id,
                orElse: () => Sentence(
                  id: id,
                  order: 0,
                  original: const SentenceText(text: 'Deleted'),
                  translation: 'Deleted content',
                  difficulty: Difficulty.beginner,
                ),
              );
            })
            .where((s) => s.original.text != 'Deleted')
            .toList();

        if (sentences.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Study Mode')),
            body: const Center(child: Text('No sentences to study.')),
          );
        }

        // Safe index calculation
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
            toolbarHeight: isLandscape ? 40 : null,
            title: isLandscape
                ? null
                : Text('${safeIndex + 1} / ${sentences.length}'),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    currentSentence.isFavorite ? Icons.star : Icons.star_border,
                    size: 20,
                    color: currentSentence.isFavorite ? Colors.red : null,
                  ),
                  onPressed: () => ref
                      .read(sentenceListProvider.notifier)
                      .toggleFavorite(currentSentence.id),
                ),
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
                      final idToDelete = currentSentence.id;
                      await ref
                          .read(sentenceListProvider.notifier)
                          .deleteSentence(idToDelete);

                      if (context.mounted) {
                        Navigator.pop(context); // Return to list view
                      }
                    }
                  },
                ),
              ],
            ),
            leadingWidth: 160,
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
                          return SentenceCard(
                            key: ValueKey(
                              'sentence_card_${sentences[index].id}',
                            ),
                            sentence: sentences[index],
                            languageMode: languageMode,
                            padding: EdgeInsets.symmetric(
                              horizontal: isLandscape ? 32.0 : 16.0,
                              vertical: isLandscape ? 8.0 : 16.0,
                            ),
                            onFlip: (isFlipped) {
                              if (widget.isTestMode) {
                                setState(() {
                                  _isFlipped = isFlipped;
                                });
                                if (isFlipped) {
                                  _pauseTimer();
                                } else {
                                  _resumeTimer();
                                }
                              }
                            },
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

    final durations = [5, 10, 15, 20, 30, 60];
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final pickerButtons = durations.reversed.map((d) {
      final isCurrent = d == _timerDuration;
      return Padding(
        padding: EdgeInsets.only(
          bottom: isLandscape ? 0 : 8.0,
          right: isLandscape ? 8.0 : 0,
        ),
        child: GestureDetector(
          onTap: () async {
            await ref.read(timerDurationProvider.notifier).setDuration(d);
            if (mounted) {
              setState(() {
                _timerDuration = d;
                _showDurationPicker = false;
                _startTimer();
              });
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCurrent
                  ? Colors.green.withValues(alpha: 0.8)
                  : Colors.green.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '$d',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Positioned(
      bottom: 20,
      right: 20,
      child: isLandscape
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_showDurationPicker) ...pickerButtons,
                _buildMainTimerButton(),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_showDurationPicker) ...pickerButtons,
                _buildMainTimerButton(),
              ],
            ),
    );
  }

  Widget _buildMainTimerButton() {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _showDurationPicker = !_showDurationPicker;
          if (_showDurationPicker) {
            _pauseTimer();
          } else {
            _resumeTimer();
          }
        });
      },
      onTap: () {
        if (_showDurationPicker) {
          setState(() {
            _showDurationPicker = false;
            _resumeTimer();
          });
        } else {
          setState(() {
            _isPaused = !_isPaused;
          });
        }
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _showDurationPicker
              ? Colors.grey.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: _showDurationPicker
              ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1)
              : null,
        ),
        child: _isPaused
            ? const Icon(Icons.pause, color: Colors.white, size: 24)
            : Center(
                child: Text(
                  '$_timeLeft',
                  key: const ValueKey('timer_text'),
                  style: TextStyle(
                    color: _showDurationPicker
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}
