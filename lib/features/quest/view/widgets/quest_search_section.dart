import 'package:flutter/material.dart';

class QuestSearchSection extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const QuestSearchSection({Key? key, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '퀘스트 검색하기',
          style: const TextStyle(
            //fontFamily: 'SUITE',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.5, // 30px line height / 20px font size
            letterSpacing: -0.4, // -2% of 20px = -0.4
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
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontFamily: 'SUITE',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    letterSpacing: -0.32, // -2% of 16px
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: '퀘스트를 검색해 주세요',
                    hintStyle: const TextStyle(
                      fontFamily: 'SUITE',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      letterSpacing: -0.32, // -2% of 16px
                      color: Color(0xFFBDBDBD), // Gray/50
                    ),
                    suffixIcon: const Icon(Icons.search, color: Color(0xFF643EFF)),
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