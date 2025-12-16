import 'package:flutter/material.dart';
import '../../domain/entities/sentence.dart';

class SentenceListItem extends StatelessWidget {
  final Sentence sentence;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SentenceListItem({
    super.key,
    required this.sentence,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Swipe-to-Action 구현
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
          return false; // 편집은 화면 이동이므로 리스트에서 삭제되지 않음
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        color: const Color(0xFFF1F8E9), // 연한 파스텔 녹색 배경
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 리스트뷰에서는 Plain Text로 보여주기로 했으나,
                // UI-SPEC 변경으로 Rich Text를 사용하지 않고 Plain Text를 사용하기로 함.
                // 하지만 SentenceTextView를 재사용할지, 그냥 Text를 쓸지 결정 필요.
                // UI-SPEC: "리스트뷰: 스타일 없는 Plain Text로 표시"
                Text(
                  sentence.original.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  sentence.translation,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
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
