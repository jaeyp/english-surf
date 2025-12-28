import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../domain/entities/sentence.dart';
import '../../application/providers/sentence_providers.dart'; // LanguageMode

class SentenceListItem extends ConsumerStatefulWidget {
  final Sentence sentence;
  final LanguageMode languageMode;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelect;
  final VoidCallback? onLongPress;

  const SentenceListItem({
    super.key,
    required this.sentence,
    required this.languageMode,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorite,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelect,
    this.onLongPress,
  });

  @override
  ConsumerState<SentenceListItem> createState() => _SentenceListItemState();
}

class _SentenceListItemState extends ConsumerState<SentenceListItem>
    with SingleTickerProviderStateMixin {
  late final SlidableController _slidableController;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
    // Listen to closure to notify parent to sync list
    _slidableController.actionPaneType.addListener(
      _handleSlidableOpenedChanged,
    );
  }

  @override
  void dispose() {
    _slidableController.actionPaneType.removeListener(
      _handleSlidableOpenedChanged,
    );
    _slidableController.dispose();
    super.dispose();
  }

  void _handleSlidableOpenedChanged() {
    // When the action pane is closed (Value == none), refresh the list if needed
    if (_slidableController.actionPaneType.value == ActionPaneType.none) {
      widget.onToggleFavorite?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine text based on mode using Dart 3 switch expression
    final (mainText, subText) = switch (widget.languageMode) {
      LanguageMode.originalToTranslation => (
        widget.sentence.original.text,
        widget.sentence.translation,
      ),
      LanguageMode.translationToOriginal => (
        widget.sentence.translation,
        widget.sentence.original.text,
      ),
    };

    // Swipe-to-Action Implementation using flutter_slidable
    return SizedBox(
      width: double.infinity,
      child: Slidable(
        key: ValueKey(widget.sentence.id),
        controller: _slidableController,
        enabled: !widget.isSelectionMode,
        // Right side menu (End to Start swipe)
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.6, // Ratio of the total width for 3 buttons
          children: [
            // Favorite Action
            SlidableAction(
              onPressed: (context) {
                ref
                    .read(sentenceListProvider.notifier)
                    .toggleFavorite(widget.sentence.id);
              },
              autoClose: false, // Keep the menu open after toggling favorite
              backgroundColor: Colors.white,
              foregroundColor: widget.sentence.isFavorite
                  ? Colors.red
                  : Colors.grey,
              icon: widget.sentence.isFavorite ? Icons.star : Icons.star_border,
              label: 'Favorite',
            ),
            // Edit Action
            SlidableAction(
              onPressed: (context) {
                if (widget.onEdit != null) widget.onEdit!();
              },
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            // Delete Action
            SlidableAction(
              onPressed: (context) async {
                final confirmed = await _showDeleteConfirmation(context);
                if (confirmed && widget.onDelete != null) {
                  widget.onDelete!();
                }
              },
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: widget.isSelected ? 4 : 2,
          color: widget.isSelected
              ? Colors.blue.shade50
              : const Color(0xFFF1F8E9), // Highlight if selected
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: widget.isSelected
                ? const BorderSide(color: Colors.blueAccent, width: 2)
                : BorderSide.none,
          ),
          child: Container(
            width: double.infinity,
            child: InkWell(
              onTap: widget.isSelectionMode
                  ? () => widget.onSelect?.call(!widget.isSelected)
                  : widget.onTap,
              onLongPress: widget.onLongPress,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (widget.isSelectionMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Checkbox(
                          value: widget.isSelected,
                          onChanged: widget.onSelect,
                          activeColor: Colors.blueAccent,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Display as Plain Text in List View
                          Text(
                            mainText,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Display sub-text (translation/original) faintly for learning purposes
                          Text(
                            subText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors
                                  .grey
                                  .shade400, // Slightly fainter for better hierarchy
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Sentence'),
              content: const Text(
                'Are you sure you want to delete this sentence?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
