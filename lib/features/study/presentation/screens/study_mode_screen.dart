import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../sentences/domain/entities/sentence.dart';
import '../../../sentences/domain/value_objects/sentence_text.dart';
import '../../../sentences/domain/enums/difficulty.dart';
import '../../../sentences/domain/enums/sort_type.dart';
import '../../../sentences/application/providers/sentence_providers.dart';
import '../../../sentences/data/providers/sentence_providers.dart'; // For settingsRepositoryProvider
import '../../../sentences/presentation/widgets/sentence_card.dart';
import '../../../sentences/domain/enums/app_language.dart';
import '../../presentation/controllers/study_mode_tts_controller.dart';

class StudyModeScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  final bool isTestMode;
  final bool isAudioMode;
  final AppLanguage? originalLanguage;
  final AppLanguage? translationLanguage;

  const StudyModeScreen({
    super.key,
    this.initialIndex = 0,
    this.isTestMode = false,
    this.isAudioMode = false,
    this.originalLanguage,
    this.translationLanguage,
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

  // Audio Mode State
  int _repeatCount = 1;
  int _currentRepeat = 0;

  bool _showRepetitionPicker = false;
  int _audioSessionId = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    if (widget.isTestMode) {
      if (widget.isAudioMode) {
        // Audio Mode: Start Audio Loop
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startAudioSession();
        });
      } else {
        // Text Mode: Start Timer
        _startTimer();
      }
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

  Future<void> _startAudioSession() async {
    if (!mounted || !widget.isTestMode || !widget.isAudioMode) return;

    // Reset repeat counter for new page
    setState(() {
      _currentRepeat = 0;
      _isPaused = false;
      _audioSessionId++; // New session
    });

    _playAudioLoop(_audioSessionId);
  }

  Future<void> _playAudioLoop(int sessionId) async {
    if (!mounted || _isPaused || _showRepetitionPicker) return;

    // Check if this loop is still valid
    if (sessionId != _audioSessionId) return;

    if (_currentRepeat >= _repeatCount) {
      _nextPage();
      return;
    }

    try {
      // Get current sentence
      final sentences = await _getSentences();
      if (sentences.isEmpty || _currentIndex >= sentences.length) return;
      final sentence = sentences[_currentIndex];

      // Play Audio
      final controller = ref.read(studyModeTtsControllerProvider);

      // Determine text to play based on language mode?
      // Usually users study Translation -> Original, so play Original?
      // Or play based on active side? Typically audio is Original.
      final textToPlay = sentence.original.text;

      // We need to wait for playback to finish
      await controller.play(
        textToPlay,
        await ref.read(settingsRepositoryProvider).getTtsSpeaker(),
      );

      // Verify Session ID again after async playback
      if (!mounted || _isPaused || sessionId != _audioSessionId) return;

      setState(() {
        _currentRepeat++;
      });

      // Small delay between repetitions
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted && !_isPaused && sessionId == _audioSessionId) {
        _playAudioLoop(sessionId); // Recursive call for next repetition
      }
    } catch (e) {
      // If error, just advance to next page or stop?
      // Let's advance to avoid getting stuck
      if (mounted && sessionId == _audioSessionId) _nextPage();
    }
  }

  // Helper to fetch sentences (since build logic is complex)
  Future<List<Sentence>> _getSentences() async {
    // This is a bit tricky since sentences are derived in build.
    // Better way: Access the provider directly using stored IDs.
    if (_initialSentenceIds == null) return [];
    final allSentences = await ref.read(sentenceListProvider.future);
    return _initialSentenceIds!
        .map((id) => allSentences.firstWhere((s) => s.id == id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch the filtered list ONLY to initialize the stable IDs
    final filteredSentencesAsync = ref.watch(filteredSentencesProvider);

    // 2. Watch the full raw list to get reactive updates for each card
    final rawSentencesAsync = ref.watch(sentenceListProvider);

    // 3. Watch the TTS controller to bind its lifecycle (Auto-Stop on dispose)
    ref.watch(studyModeTtsControllerProvider);

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

    // Sync persistent repeat count (Audio Mode)
    final persistentRepeatCount =
        ref.watch(audioRepeatCountProvider).value ?? 1;
    if (_repeatCount != persistentRepeatCount && !_showRepetitionPicker) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _repeatCount = persistentRepeatCount;
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
                            if (widget.isAudioMode) {
                              _startAudioSession();
                            } else {
                              _startTimer();
                            }
                          }
                        },
                        itemBuilder: (context, index) {
                          return SentenceCard(
                            key: ValueKey(
                              'sentence_card_${sentences[index].id}',
                            ),
                            sentence: sentences[index],
                            languageMode: languageMode,
                            originalLanguage: widget.originalLanguage,
                            translationLanguage: widget.translationLanguage,
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
                                  _pauseTimer(); // Pauses Timer and also essentially pauses Audio loop via _isPaused check?
                                  // We should explicitly set _isPaused = true for audio loop check
                                  setState(() => _isPaused = true);
                                } else {
                                  _resumeTimer();
                                  // For audio, resume loop
                                  setState(() => _isPaused = false);
                                  if (widget.isAudioMode)
                                    _playAudioLoop(_audioSessionId);
                                }
                              }
                            },
                            onFavoriteToggle: () => ref
                                .read(sentenceListProvider.notifier)
                                .toggleFavorite(sentences[index].id),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              widget.isAudioMode
                  ? _buildAudioRepetitionOverlay()
                  : _buildTimerOverlay(),
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

  Widget _buildAudioRepetitionOverlay() {
    if (!widget.isTestMode) return const SizedBox.shrink();

    // Requested: "high numbers far from button". Button is at bottom/right.
    // So 10 should be at top (if vertical) or left (if horizontal).
    // Reversed list: [10, 5, 3, 2, 1]. Map order: 10, 5, 3, 2, 1.
    final options = [10, 5, 3, 2, 1];

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final pickerButtons = options.map((c) {
      final isCurrent = c == _repeatCount;
      return Padding(
        padding: EdgeInsets.only(
          bottom: isLandscape ? 0 : 8.0,
          right: isLandscape ? 8.0 : 0,
        ),
        child: GestureDetector(
          onTap: () async {
            await ref.read(audioRepeatCountProvider.notifier).setCount(c);
            if (mounted) {
              setState(() {
                _repeatCount = c;
                _showRepetitionPicker = false;
                // Restart current card audio session with new count?
                // Probably yes.
                _startAudioSession();
              });
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCurrent
                  ? Colors.blue.withValues(alpha: 0.8)
                  : Colors.blue.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '$c',
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
                if (_showRepetitionPicker) ...pickerButtons,
                _buildMainRepetitionButton(),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_showRepetitionPicker) ...pickerButtons,
                _buildMainRepetitionButton(),
              ],
            ),
    );
  }

  Widget _buildMainRepetitionButton() {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _showRepetitionPicker = !_showRepetitionPicker;
          // Pause if picking?
          if (_showRepetitionPicker) {
            _isPaused = true;
          } else {
            _isPaused = false;
            _playAudioLoop(_audioSessionId); // Resume current session
          }
        });
      },
      onTap: () {
        if (_showRepetitionPicker) {
          setState(() {
            _showRepetitionPicker = false;
            _isPaused = false;
            _playAudioLoop(_audioSessionId); // Resume current session
          });
        } else {
          // Toggle Pause logic
          setState(() {
            _isPaused = !_isPaused;
            if (!_isPaused)
              _playAudioLoop(_audioSessionId); // Resume current session
          });
        }
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _showRepetitionPicker
              ? Colors.grey.withValues(alpha: 0.5)
              : Colors.blue.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: _showRepetitionPicker
              ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1)
              : null,
        ),
        child: _isPaused
            ? const Icon(Icons.pause, color: Colors.white, size: 24)
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.repeat, color: Colors.white, size: 14),
                    Text(
                      '$_repeatCount', // Show total repeat count usage
                      style: TextStyle(
                        color: _showRepetitionPicker
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
