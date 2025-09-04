import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/quest/viewmodel/daily_quest_viewmodel.dart';
import 'package:provider/provider.dart';
import '../quest_search_screen.dart';

class QuestSearchSection extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const QuestSearchSection({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final viewModel = Provider.of<DailyQuestViewModel>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '퀘스트 검색하기',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.5,
            letterSpacing: -0.4,
            color: Color(0xFF4C1FFF),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  onSubmitted: (value) async {
                    await viewModel.fetchQuests();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuestSearchScreen(initialQuery: value),
                      ),
                    );
                  },
                  style: const TextStyle(
                    fontFamily: 'SUITE',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    letterSpacing: -0.32,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: '퀘스트를 검색해 주세요',
                    hintStyle: const TextStyle(
                      fontFamily: 'SUITE',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      letterSpacing: -0.32,
                      color: Color(0xFFBDBDBD),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () async {
                        await viewModel.fetchQuests();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuestSearchScreen(initialQuery: controller.text),
                          ),
                        );
                      },
                      child: const Icon(Icons.search, color: Color(0xFF643EFF)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF643EFF), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF643EFF), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF643EFF), width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 