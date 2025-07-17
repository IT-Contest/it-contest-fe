import 'package:flutter/material.dart';

class QuestAddSection extends StatelessWidget {
  final VoidCallback? onAdd;
  const QuestAddSection({Key? key, this.onAdd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onAdd,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF7958FF), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.fromLTRB(88, 19, 88, 19),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
    );
  }
} 