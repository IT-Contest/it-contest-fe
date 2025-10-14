import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/mainpage/viewmodel/mainpage_viewmodel.dart';

class QuestCompletionModal extends StatelessWidget {
  final int expReward;
  final int goldReward;
  final bool isCompleted; // ✅ 완료(true)/취소(false)
  final VoidCallback? onClose;

  const QuestCompletionModal({
    super.key,
    required this.expReward,
    required this.goldReward,
    required this.isCompleted,
    this.onClose,
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
          // 제목과 닫기 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              Text(
                isCompleted ? '퀘스트 완료' : '퀘스트 취소', // ✅ 완료/취소 구분
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        final mainPageViewModel = context.read<MainPageViewModel>();
                        await mainPageViewModel.refreshUserInfo();
                      } catch (e) {
                        print('[홈화면 데이터 새로고침 실패] $e');
                      }
                      if (onClose != null) {
                        onClose!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Icon(Icons.close, color: Colors.black, size: 28),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ✅ 완료/취소에 따라 메시지 변경
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '퀘스트를 ',
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
                TextSpan(
                  text: isCompleted ? '완료' : '취소',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.blue.shade500 : Colors.red.shade500,
                  ),
                ),
                TextSpan(
                  text: isCompleted
                      ? '했습니다. 보상이 지급됩니다.'
                      : '했습니다. 기존 보상이 회수됩니다.',
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 보상 카드들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 경험치 카드
              Container(
                width: 200, // ✅ 원하는 너비
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF8F73FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/icons/arrow_circle_up.png',
                        width: 30,
                        height: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '경험치 ${isCompleted ? '+' : '-'} $expReward exp',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Expanded(
              //   child: Container(
              //     padding: const EdgeInsets.all(20),
              //     decoration: BoxDecoration(
              //       color: const Color(0xFF8F73FF),
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: Column(
              //       children: [
              //         Container(
              //           width: 48,
              //           height: 48,
              //           child: Center(
              //             child: Image.asset(
              //               'assets/icons/arrow_circle_up.png',
              //               width: 30,
              //               height: 30,
              //               color: Colors.white,
              //             ),
              //           ),
              //         ),
              //         const SizedBox(height: 12),
              //         Text(
              //           '경험치 ${isCompleted ? '+' : '-'} $expReward exp', // ✅ + 또는 - 표시
              //           style: const TextStyle(
              //             color: Colors.white,
              //             fontSize: 14,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(width: 12),
              //
              // // 골드 카드
              // Expanded(
              //   child: Container(
              //     padding: const EdgeInsets.all(20),
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(color: const Color(0xFF8F73FF), width: 2),
              //     ),
              //     child: Column(
              //       children: [
              //         Container(
              //           width: 48,
              //           height: 48,
              //           decoration: const BoxDecoration(
              //             color: Colors.white,
              //             shape: BoxShape.circle,
              //           ),
              //           child: Center(
              //             child: Image.asset(
              //               'assets/icons/database.png',
              //               width: 30,
              //               height: 30,
              //               color: const Color(0xFF8F73FF),
              //             ),
              //           ),
              //         ),
              //         const SizedBox(height: 12),
              //         Text(
              //           '${isCompleted ? '+' : '-'} $goldReward 골드', // ✅ + 또는 - 표시
              //           style: const TextStyle(
              //             color: Color(0xFF8F73FF),
              //             fontSize: 14,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static void show(
      BuildContext context, {
        required int expReward,
        required int goldReward,
        required bool isCompleted, // ✅ 전달 필요
        VoidCallback? onClose,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuestCompletionModal(
        expReward: expReward,
        goldReward: goldReward,
        isCompleted: isCompleted,
        onClose: onClose,
      ),
    );
  }
}
