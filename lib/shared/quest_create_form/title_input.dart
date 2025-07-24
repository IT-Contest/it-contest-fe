import 'package:flutter/material.dart';

class QuestTitleInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const QuestTitleInput({super.key, required this.onChanged});

  @override
  State<QuestTitleInput> createState() => _QuestTitleInputState();
}

class _QuestTitleInputState extends State<QuestTitleInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isOverLimit = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleInputChange(String value) {
    setState(() {
      _isOverLimit = value.length > 100;
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("퀘스트명", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          onChanged: _handleInputChange,
          decoration: InputDecoration(
            hintText: "퀘스트명을 입력해 주세요 (최대 100자 이내)",
            hintStyle: const TextStyle(color: Color(0xFFB7B7B7), fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFB7B7B7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF7D4CFF), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (_isOverLimit)
          const Text("퀘스트명이 100자 이상입니다.", style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}