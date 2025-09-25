import 'package:flutter/material.dart';

class PartyDeleteSuccessModal extends StatelessWidget {
  final VoidCallback? onClose;

  const PartyDeleteSuccessModal({
    super.key,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 성공 아이콘
          Container(
            width: 64,
            height: 64,
            // decoration: const BoxDecoration(
            //   color: Color(0xFF4CAF50),
            //   shape: BoxShape.circle,
            // ),
            child: Center(
              child: Image.asset(
                'assets/icons/trash_bucket.png',
                width: 52,
                height: 52,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 제목
          const Text(
            '파티 퀘스트가 삭제되었습니다.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),

          // 확인 버튼
          SizedBox(
            width: 160,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onClose != null) {
                  onClose!();
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
                '확인',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static void show(
      BuildContext context, {
        VoidCallback? onClose,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false, // 바깥 클릭 닫힘 방지
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: PartyDeleteSuccessModal(
            onClose: onClose,
          ),
        );
      },
    );
  }
}