import 'package:flutter/material.dart';

class QuestCard extends StatelessWidget {
  final String title;
  final int exp;
  final int gold;
  final bool done;
  final VoidCallback? onCheck;
  final bool highlightTitle;
  final bool showBackground;
  final bool useFilledIconBg;
  final double padding;
  final bool isSelected; // 선택 상태 파라미터 추가

  const QuestCard({
    required this.title,
    required this.exp,
    required this.gold,
    this.done = false,
    this.onCheck,
    this.highlightTitle = false,
    this.showBackground = true,
    this.useFilledIconBg = true,
    this.padding = 14,
    this.isSelected = false, // 기본값은 false
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: showBackground ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF643EFF) : const Color(0xFFE0E0E0), // isSelected 값에 따라 색상 변경
          width: isSelected ? 2 : 1, // 선택 시 테두리 두께 강조
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: useFilledIconBg ? const Color(0xFFF2ECFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              done ? 'assets/icons/list_O.png' : 'assets/icons/list_X.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: done
                        ? const Color(0xFF643EFF)
                        : (highlightTitle ? const Color(0xFF643EFF) : Colors.black87),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _RewardTag(label: '경험치 +$exp'),
                    const SizedBox(width: 8),
                    _RewardTag(label: '골드 +$gold', border: true),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCheck,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: done ? const Color(0xFF643EFF) : const Color(0xFFFAFAFA),
                border: Border.all(
                  color: const Color(0xFF7958FF),
                  width: 1,
                ),
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardTag extends StatelessWidget {
  final String label;
  final bool border;
  const _RewardTag({required this.label, this.border = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: border ? Colors.white : const Color(0xFF643EFF),
        border: border ? Border.all(color: const Color(0xFF643EFF)) : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: border ? const Color(0xFF643EFF) : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 