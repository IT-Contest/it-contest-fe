import 'package:flutter/material.dart';

class QuestDeleteConfirmationModal extends StatelessWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;

  const QuestDeleteConfirmationModal({
    super.key,
    this.onDelete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 제목
          const Text(
            '주의',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 20),
          
          // 경고 메시지
          const Text(
            '완료된 퀘스트의 경우 지급되었던\n경험치와 골드가 차감됩니다.\n그래도 삭제하시겠습니까?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // 버튼들
          Row(
            children: [
              // 삭제 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onDelete != null) {
                      onDelete!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F73FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '삭제',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // 취소 버튼
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onCancel != null) {
                      onCancel!();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8F73FF),
                    side: const BorderSide(color: Color(0xFF8F73FF), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    VoidCallback? onDelete,
    VoidCallback? onCancel,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuestDeleteConfirmationModal(
        onDelete: onDelete,
        onCancel: onCancel,
      ),
    );
  }
}