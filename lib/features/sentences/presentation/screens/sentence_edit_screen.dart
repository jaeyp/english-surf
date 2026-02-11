import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/sentence.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/value_objects/sentence_text.dart';
import '../../domain/value_objects/text_style.dart' as domain;
import '../../domain/enums/text_style_type.dart';
import '../../application/providers/sentence_providers.dart';

import '../widgets/styled_text_editing_controller.dart';
import '../../data/providers/ai_providers.dart';
import '../../application/providers/folder_providers.dart';

class SentenceEditScreen extends ConsumerStatefulWidget {
  final Sentence? sentence;
  final String? initialOriginalText;
  final String? initialTranslationText;

  const SentenceEditScreen({
    super.key,
    this.sentence,
    this.initialOriginalText,
    this.initialTranslationText,
  });

  @override
  ConsumerState<SentenceEditScreen> createState() => _SentenceEditScreenState();
}

class _SentenceEditScreenState extends ConsumerState<SentenceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late StyledTextEditingController _originalController;
  late TextEditingController _translationController;
  late TextEditingController _notesController;
  late List<TextEditingController> _paraphraseControllers;
  late Difficulty _difficulty;
  bool _isAiGenerating = false;

  @override
  void initState() {
    super.initState();
    final s = widget.sentence;
    final initialStyles = s?.original.styles.toList() ?? [];

    String initialOriginal =
        s?.original.text ?? widget.initialOriginalText ?? '';
    String initialTranslation =
        s?.translation ?? widget.initialTranslationText ?? '';

    // Fallback Smart Fill: If separate translation wasn't provided, check original for Korean
    if (s == null &&
        widget.initialTranslationText == null &&
        widget.initialOriginalText != null) {
      final ocrText = widget.initialOriginalText!;
      if (RegExp(r'[가-힣]').hasMatch(ocrText)) {
        initialTranslation = ocrText;
        initialOriginal = ''; // clear original since it was moved
      }
    }

    _originalController = StyledTextEditingController(
      text: initialOriginal,
      styles: initialStyles,
    );
    _translationController = TextEditingController(text: initialTranslation);
    _notesController = TextEditingController(text: s?.notes ?? '');
    _difficulty = s?.difficulty ?? Difficulty.beginner;
    _paraphraseControllers =
        s?.paraphrases.map((e) => TextEditingController(text: e)).toList() ??
        [];
    if (_paraphraseControllers.isEmpty) {
      _paraphraseControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _originalController.dispose();
    _translationController.dispose();
    _notesController.dispose();
    for (var controller in _paraphraseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addParaphrase() {
    setState(() {
      _paraphraseControllers.add(TextEditingController());
    });
  }

  void _removeParaphrase(int index) {
    setState(() {
      _paraphraseControllers.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final sentences = await ref.read(sentenceListProvider.future);
    final id =
        widget.sentence?.id ??
        (sentences.isEmpty
            ? 1
            : sentences.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1);
    final order =
        widget.sentence?.order ??
        (sentences.isEmpty
            ? 1
            : sentences.map((s) => s.order).reduce((a, b) => a > b ? a : b) +
                  1);

    final newSentence = Sentence(
      id: id,
      order: order,
      original: SentenceText(
        text: _originalController.text,
        styles: _originalController.styles,
      ),
      translation: _translationController.text,
      difficulty: _difficulty,
      notes: _notesController.text,
      paraphrases: _paraphraseControllers
          .map((c) => c.text)
          .where((t) => t.isNotEmpty)
          .toList(),
      // For new cards, use the current folder; for edits, preserve the original folderId
      folderId: widget.sentence?.folderId ?? ref.read(currentFolderProvider),
      isFavorite: widget.sentence?.isFavorite ?? false,
    );

    if (widget.sentence == null) {
      await ref.read(sentenceListProvider.notifier).addSentence(newSentence);
    } else {
      await ref.read(sentenceListProvider.notifier).updateSentence(newSentence);
    }

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _generateAiContent() async {
    final originalText = _originalController.text.trim();

    final currentTranslation = _translationController.text.trim();

    // CASE 1: Reverse Generation (Translation populated, Original empty)
    if (originalText.isEmpty && currentTranslation.isNotEmpty) {
      setState(() => _isAiGenerating = true);
      try {
        final aiRepo = await ref.read(aiRepositoryProvider.future);
        final englishText = await aiRepo.generateEnglishOriginal(
          translation: currentTranslation,
        );
        setState(() {
          _originalController.text = englishText;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('English sentence generated!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error generating English: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isAiGenerating = false);
        }
      }
      return;
    }

    // CASE 2: Standard Auto-Fill (Original populated)
    if (originalText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an English sentence first')),
      );
      return;
    }

    setState(() => _isAiGenerating = true);

    try {
      final aiRepo = await ref.read(aiRepositoryProvider.future);

      // Extract styled text sections (bold or highlight) as target expressions
      final originalTextValue = _originalController.text;
      final targetExpressions = _originalController.styles
          .map((s) {
            if (s.start >= 0 &&
                s.end <= originalTextValue.length &&
                s.start < s.end) {
              return originalTextValue.substring(s.start, s.end).trim();
            }
            return '';
          })
          .where((t) => t.isNotEmpty)
          .toList();

      final result = await aiRepo.generateSentenceContent(
        originalText,
        targetExpressions: targetExpressions.isEmpty ? null : targetExpressions,
        existingTranslation: currentTranslation.isNotEmpty
            ? currentTranslation
            : null,
      );

      setState(() {
        _translationController.text = result.translation;
        _notesController.text = result.notes;

        if (result.difficulty != null) {
          _difficulty = result.difficulty!;
        }

        // Populate paraphrases
        final paraphrasesList = result.paraphrases
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList();

        if (paraphrasesList.isNotEmpty) {
          _paraphraseControllers.clear();
          for (var item in paraphrasesList) {
            final cleanItem = item
                .replaceFirst(RegExp(r'^(\d+\.|\-|\*)\s*'), '')
                .trim();
            if (cleanItem.isNotEmpty) {
              _paraphraseControllers.add(
                TextEditingController(text: cleanItem),
              );
            }
          }
          if (_paraphraseControllers.isEmpty) {
            _paraphraseControllers.add(TextEditingController());
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI content generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('AI Generation Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isAiGenerating = false);
      }
    }
  }

  Future<void> _generateNotes() async {
    final originalText = _originalController.text.trim();
    if (originalText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an English sentence first')),
      );
      return;
    }

    setState(() => _isAiGenerating = true);

    try {
      final aiRepo = await ref.read(aiRepositoryProvider.future);
      final notes = await aiRepo.generateNotes(originalText);

      setState(() {
        _notesController.text = notes;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notes refreshed!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating notes: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isAiGenerating = false);
      }
    }
  }

  Future<void> _generateParaphrases() async {
    final originalText = _originalController.text.trim();
    if (originalText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an English sentence first')),
      );
      return;
    }

    setState(() => _isAiGenerating = true);

    try {
      final aiRepo = await ref.read(aiRepositoryProvider.future);
      final translation = _translationController.text;
      final paraphrasesText = await aiRepo.generateParaphrases(
        originalText: originalText,
        translation: translation,
      );

      setState(() {
        // Populate paraphrases
        final paraphrasesList = paraphrasesText
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList();

        if (paraphrasesList.isNotEmpty) {
          // Remove ALL empty controllers to keep the list clean
          _paraphraseControllers.removeWhere((c) => c.text.trim().isEmpty);

          for (var item in paraphrasesList) {
            if (item.isNotEmpty) {
              _paraphraseControllers.add(TextEditingController(text: item));
            }
          }

          if (_paraphraseControllers.isEmpty) {
            _paraphraseControllers.add(TextEditingController());
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Paraphrases refreshed!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating paraphrases: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAiGenerating = false);
      }
    }
  }

  void _applyStyle(TextStyleType type) {
    final selection = _originalController.selection;
    if (selection.isCollapsed) return;

    final start = selection.start;
    final end = selection.end;

    setState(() {
      // 1. Remove overlapping styles of the same type that are completely within the new selection
      _originalController.styles.removeWhere(
        (s) => s.type == type && s.start >= start && s.end <= end,
      );

      // 2. Add the new style
      _originalController.styles.add(
        domain.TextStyle(type: type, start: start, end: end),
      );

      // 3. Simple merge: Sort by start then type
      _originalController.styles.sort((a, b) => a.start.compareTo(b.start));
    });
  }

  void _clearStyles() {
    final selection = _originalController.selection;
    if (selection.isCollapsed) return;

    final start = selection.start;
    final end = selection.end;

    setState(() {
      _originalController.styles.removeWhere((s) {
        final overlaps = (s.start < end && s.end > start);
        return overlaps;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.sentence == null ? 'Add Sentence' : 'Edit Sentence',
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Expression:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: _isAiGenerating
                              ? null
                              : _generateAiContent,
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: const Text('AI Auto-fill'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1B5E20),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildOriginalField(),
                    const SizedBox(height: 24),
                    const Text(
                      'Translation:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _translationController,
                      maxLines: null,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Enter Korean translation',
                        filled: true,
                        fillColor: const Color(0xFFF1F8E9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Translation is required'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Difficulty:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Difficulty>(
                      initialValue: _difficulty,
                      dropdownColor: const Color(
                        0xFFF1F8E9,
                      ), // Background of the popup menu
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF1F8E9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: Difficulty.values.map((d) {
                        return DropdownMenuItem(
                          value: d,
                          child: Text(
                            d.name.toUpperCase(),
                            style: const TextStyle(color: Colors.black87),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _difficulty = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notes:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: _isAiGenerating ? null : _generateNotes,
                          icon: const Icon(Icons.refresh, size: 24),
                          tooltip: 'Refresh Notes with AI',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: null,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Grammar or vocabulary notes',
                        filled: true,
                        fillColor: const Color(0xFFF1F8E9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Paraphrases:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: _isAiGenerating
                                  ? null
                                  : _generateParaphrases,
                              icon: const Icon(Icons.refresh, size: 24),
                              tooltip: 'Refresh Paraphrases with AI',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            IconButton(
                              onPressed: _addParaphrase,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ..._paraphraseControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                minLines: 1,
                                maxLines: 5, // Grow dynamically up to 5 lines
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  hintText: 'Paraphrase ${index + 1}',
                                  filled: true,
                                  fillColor: const Color(0xFFF1F8E9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4), // Reduced from 8
                            IconButton(
                              onPressed: () => _removeParaphrase(index),
                              padding: EdgeInsets.zero, // Remove padding
                              constraints:
                                  const BoxConstraints(), // Tight constraints
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            if (_isAiGenerating)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF1B5E20)),
                            SizedBox(height: 16),
                            Text(
                              'AI is generating content...',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginalField() {
    return Column(
      children: [
        TextFormField(
          controller: _originalController,
          maxLines: null,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Enter English sentence',
            helperText: 'Select text to apply styling (Bold/Highlight)',
            filled: true,
            fillColor: const Color(0xFFF1F8E9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Sentence is required' : null,
          contextMenuBuilder: (context, editableTextState) {
            final List<ContextMenuButtonItem> buttonItems =
                editableTextState.contextMenuButtonItems;

            buttonItems.insert(
              0,
              ContextMenuButtonItem(
                label: 'Bold',
                onPressed: () {
                  _applyStyle(TextStyleType.bold);
                  editableTextState.hideToolbar();
                },
              ),
            );

            buttonItems.insert(
              1,
              ContextMenuButtonItem(
                label: 'Highlight',
                onPressed: () {
                  _applyStyle(TextStyleType.highlight);
                  editableTextState.hideToolbar();
                },
              ),
            );

            buttonItems.insert(
              2,
              ContextMenuButtonItem(
                label: 'Clear',
                onPressed: () {
                  _clearStyles();
                  editableTextState.hideToolbar();
                },
              ),
            );

            return AdaptiveTextSelectionToolbar.buttonItems(
              anchors: editableTextState.contextMenuAnchors,
              buttonItems: buttonItems,
            );
          },
        ),
      ],
    );
  }
}
