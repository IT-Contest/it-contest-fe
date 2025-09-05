// quest_add_section.dart
import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/quest/view/widgets/quest_type_bottom_sheet.dart'; 

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
          QuestTypeBottomSheet.show(
            context,
            onPersonalQuestTap: onTap,
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF7958FF), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.fromLTRB(88, 14, 88, 19),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.add, color: Color(0xFF7958FF), size: 24),
            ),
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
    );
  }
}