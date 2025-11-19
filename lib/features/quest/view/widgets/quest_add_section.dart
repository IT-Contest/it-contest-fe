// quest_add_section.dart
import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/quest/view/widgets/quest_type_bottom_sheet.dart';

import '../../../../shared/analytics/service/analytics_service.dart';

class QuestAddSection extends StatelessWidget {
  final VoidCallback onTap;

  const QuestAddSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {

          // Analytics 이벤트 기록
          AnalyticsService.logQuestAddClicked();

          // 키보드 포커스 해제
          FocusScope.of(context).unfocus();
          QuestTypeBottomSheet.show(
            context,
            onPersonalQuestTap: onTap,
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF7958FF), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.white,
          padding: EdgeInsets.zero,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, color: Color(0xFF7958FF), size: 24),
              SizedBox(width: 10),
              Text(
                '새 퀘스트 추가',
                style: TextStyle(
                  color: Color(0xFF7958FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}