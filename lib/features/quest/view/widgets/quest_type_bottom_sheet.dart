import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:it_contest_fe/features/quest/viewmodel/quest_party_create_viewmodel.dart';
import 'package:it_contest_fe/features/quest/view/quest_party_create_screen.dart';
import 'package:it_contest_fe/features/quest/view/quest_personal_create_screen.dart';
import 'package:it_contest_fe/features/quest/viewmodel/quest_personal_create_viewmodel.dart';

class QuestTypeBottomSheet extends StatelessWidget {
  final VoidCallback onPersonalQuestTap;

  const QuestTypeBottomSheet({super.key, required this.onPersonalQuestTap});

static void show(
  BuildContext context, {
  required VoidCallback onPersonalQuestTap,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    backgroundColor: Colors.white,
    isScrollControlled: false,
    builder: (BuildContext context) {
      return QuestTypeBottomSheet(onPersonalQuestTap: onPersonalQuestTap);
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 32, 36, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const Center(
                child: Text(
                  "생성할 퀘스트 선택",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.black, size: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _QuestTypeButton(
                label: "개인 퀘스트\n생성하기",
                isFilled: true,
                onTap: () {
                  Navigator.of(context).pop(); // 먼저 닫고
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => QuestPersonalCreateViewModel(),
                            child: const QuestPersonalCreateScreen(),
                          ),
                        ),
                      );
                    }
                  });
                },
              
              ),
              const SizedBox(width: 28),
              _QuestTypeButton(
                label: "파티 퀘스트\n생성하기",
                isFilled: false,
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => QuestPartyCreateViewModel(),
                            child: const QuestPartyCreateScreen(),
                          ),
                        ),
                      );
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestTypeButton extends StatelessWidget {
  final String label;
  final bool isFilled;
  final VoidCallback onTap;

  const _QuestTypeButton({
    required this.label,
    required this.isFilled,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 100,
        decoration: BoxDecoration(
          color: isFilled ? const Color(0xFF8F73FF) : Colors.white,
          border: Border.all(color: const Color(0xFF8F73FF), width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isFilled ? Colors.white : const Color(0xFF8F73FF),
            ),
          ),
        ),
      ),
    );
  }
}