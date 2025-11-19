import 'package:flutter/material.dart';

class PriorityTipBox extends StatelessWidget {
  const PriorityTipBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF7D4CFF), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tipTitle("TIP"),
          const SizedBox(height: 12),
          tipLine([gray("퀘스트는 "), purple("구체적으로 작성"), gray("해서 실천해보세요!")]),
          tipLine([gray("ex. 책읽기 "), red("(X)"), gray(" → OO책 100페이지까지 읽기 "), blue("(O)")]),
          tipLine([gray("우선 순위는 숫자로 1부터 5까지 넣을 수 있어요.")]),
          tipLine([gray("숫자가 작을수록 우선 순위가 높습니다.")]),
          tipLine([gray("분류를 지정해서 어떤 종류의 계획인지 정리해보세요!")]),
        ],
      ),
    );
  }

  Widget tipLine(List<TextSpan> spans) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(TextSpan(children: spans)),
    );
  }

  Widget tipTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF7D4CFF),
      ),
    );
  }

  TextSpan gray(String text) => TextSpan(
        text: text,
        style: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 14),
      );

  TextSpan purple(String text) => TextSpan(
        text: text,
        style: const TextStyle(color: Color(0xFF7D4CFF), fontSize: 14, fontWeight: FontWeight.bold),
      );

  TextSpan red(String text) => TextSpan(
        text: text,
        style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
      );

  TextSpan blue(String text) => TextSpan(
        text: text,
        style: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
      );
}