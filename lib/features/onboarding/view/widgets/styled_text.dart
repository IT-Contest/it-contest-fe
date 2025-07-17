import 'package:flutter/material.dart';

// 스타일 분기된 텍스트 위젯 모음
Widget tipTitle(String text) => Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Color(0xFF7D4CFF),
      ),
    );

Widget tipLine(List<Widget> spans) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Wrap(children: spans),
    );

Widget gray(String text) => Text(
      text,
      style: TextStyle(color: Colors.grey[700], fontSize: 15),
    );

Widget purple(String text) => const Text(
      "구체적으로 작성",
      style: TextStyle(color: Color(0xFF7D4CFF), fontSize: 15),
    );

Widget red(String text) => Text(
      text,
      style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
    );

Widget blue(String text) => Text(
      text,
      style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),
    );