import 'package:flutter/material.dart';

class QuestTitleInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? initialValue;
  const QuestTitleInput({super.key, required this.onChanged, this.initialValue});

  @override
  State<QuestTitleInput> createState() => _QuestTitleInputState();
}

class _QuestTitleInputState extends State<QuestTitleInput> {
  late final TextEditingController _controller;
  bool _isOverLimit = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

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
            hintStyle: const TextStyle(color: Color(0xFFB7B7B7), fontSize: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
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