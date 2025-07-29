import 'package:flutter/material.dart';
import 'package:it_contest_fe/shared/quest_create_form/date_time_section.dart';

class PartyCreatePage extends StatelessWidget {
  const PartyCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.grey.shade300;
    final grayText = const Color(0xFFAAAAAA);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '파티 생성',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(color: borderColor, height: 1, thickness: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InputSection(
              title: '파티명',
              hint: '파티명을 입력해 주세요 (최대 100자 이내)',
              subText: '파티명이 100자 이상입니다.',
              borderColor: borderColor,
            ),
            _InputSection(
              title: '퀘스트명',
              hint: '퀘스트명을 입력해 주세요 (최대 100자 이내)',
              subText: '퀘스트명이 100자 이상입니다.',
              borderColor: borderColor,
            ),
            _InputSection(
              title: '우선순위',
              hint: '숫자를 입력해주세요',
              borderColor: borderColor,
            ),
            const SizedBox(height: 4),
            _PriorityButtons(borderColor: borderColor),
            const SizedBox(height: 16),
            _InputSection(
              title: '카테고리 분류',
              hint: '카테고리를 직접 입력해주세요',
              borderColor: borderColor,
            ),

            // ✅ 여기에 DateTimeSection 추가
            const SizedBox(height: 24),
            const DateTimeSection(),
            const SizedBox(height: 24),

            const Text('파티원 초대', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor),
                foregroundColor: grayText,
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('파티 초대하기'),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text.rich(
                TextSpan(
                  text: '완료 시 ',
                  style: TextStyle(color: Colors.black87),
                  children: [
                    TextSpan(
                      text: '0,000exp',
                      style: TextStyle(
                        color: Color(0xFF5C2EFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' 지급'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Image.asset('assets/icons/party_add.png', width: 20, height: 20),
              label: const Text('파티 생성', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C2EFF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey,
              alignment: Alignment.center,
              child: const Text('광고 영역', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// 🧩 InputSection 위젯
class _InputSection extends StatelessWidget {
  final String title;
  final String hint;
  final String? subText;
  final Color borderColor;

  const _InputSection({
    required this.title,
    required this.hint,
    required this.borderColor,
    this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: Color(0xFFAAAAAA)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
            filled: true,
            fillColor: Colors.grey.shade100,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
        ),
        if (subText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              subText!,
              style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// 🧩 Priority 버튼 위젯
class _PriorityButtons extends StatelessWidget {
  final Color borderColor;
  const _PriorityButtons({required this.borderColor});

  @override
  Widget build(BuildContext context) {
    final grayText = const Color(0xFFAAAAAA);
    final List<String> labels = ['일일', '주간', '월간', '연간'];

    return Wrap(
      spacing: 8,
      children: labels.map((label) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 32 - 24) / 4,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: borderColor),
              foregroundColor: grayText,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
            child: Text(label, style: TextStyle(color: grayText)),
          ),
        );
      }).toList(),
    );
  }
}
