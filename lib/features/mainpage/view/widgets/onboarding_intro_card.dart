import 'package:flutter/material.dart';

class OnboardingIntroCard extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onClose;

  const OnboardingIntroCard({
    super.key,
    required this.onStart,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF7958FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '신규 사용자 온보딩 시작하기',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            '성향 테스트, 캐릭터 선택, 첫 퀘스트를 만들어보세요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFF7958FF),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(100, 56), // 버튼 크기 직접 지정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // 둥근 모서리
                  ),
                ),
                child: const Text(
                  '시작하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: onClose,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  minimumSize: const Size(48, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '닫기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
