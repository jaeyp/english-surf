import 'package:flutter/material.dart';
import '../../domain/entities/sentence.dart';
import '../../application/providers/sentence_providers.dart'; // LanguageMode

class SentenceListItem extends StatelessWidget {
  final Sentence sentence;
  final LanguageMode languageMode;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SentenceListItem({
    super.key,
    required this.sentence,
    required this.languageMode,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Determine text based on mode
    final mainText = languageMode == LanguageMode.originalToTranslation
        ? sentence.original.text
        : sentence.translation;

    final subText = languageMode == LanguageMode.originalToTranslation
        ? sentence.translation
        : sentence.original.text;

    // Swipe-to-Action Implementation
    return Dismissible(
      key: ValueKey(sentence.id),
      background: _buildSwipeActionLeft(),
      secondaryBackground: _buildSwipeActionRight(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Left Swipe (Delete)
          final confirmed = await _showDeleteConfirmation(context);
          if (confirmed && onDelete != null) {
            onDelete!();
          }
          return confirmed;
        } else {
          // Right Swipe (Edit)
          if (onEdit != null) {
            onEdit!();
          }
          return false; // Edit action navigates, so don't dismiss
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        color: const Color(0xFFF1F8E9), // Light Pastel Green Background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontSize: 12, // Smaller font
                    color: Colors.grey.shade300, // Very faint color
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeActionLeft() {
    return Container(
      color: Colors.redAccent,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Widget _buildSwipeActionRight() {
    return Container(
      color: Colors.blueAccent,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.edit, color: Colors.white),
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
