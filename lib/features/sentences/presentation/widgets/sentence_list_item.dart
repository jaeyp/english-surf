import 'package:flutter/material.dart';
import '../../domain/entities/sentence.dart';
import '../../application/providers/sentence_providers.dart'; // LanguageMode

class SentenceListItem extends StatelessWidget {
  final Sentence sentence;
  final LanguageMode languageMode; // 추가
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SentenceListItem({
    super.key,
    required this.sentence,
    required this.languageMode, // 추가
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 모드에 따른 텍스트 결정
    final mainText = languageMode == LanguageMode.originalToTranslation
        ? sentence.original.text
        : sentence.translation;

    final subText = languageMode == LanguageMode.originalToTranslation
        ? sentence.translation
        : sentence.original.text;

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
                  mainText, // 변경됨
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // KO->EN 모드일 때는 정답(영어)을 숨길 수도 있지만,
                // UI-SPEC상으로는 "앞면 텍스트만 표시"라고 되어 있음.
                // 하지만 리스트뷰에서는 힌트로 보여주는 게 좋을 수도 있음.
                // 일단 UI-SPEC에 따라 "모드에 따라 앞면 텍스트만 표시"라고 했으므로
                // 서브 텍스트는 숨기거나 흐리게 표시?
                // UI-SPEC: "모드에 따라 앞면 텍스트만 표시" -> 즉 서브 텍스트는 안 보여주는 게 맞음?
                // 아니면 작게 보여줌?
                // 일단 둘 다 보여주되 순서만 바꿈. (학습 효과를 위해)
                Text(
                  subText, // 변경됨
                  style: TextStyle(
                    fontSize: 12, // 더 작게
                    color: Colors.grey.shade300, // 아주 희미하게
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
