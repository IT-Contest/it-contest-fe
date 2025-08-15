import 'package:flutter/material.dart';

class PartyTitleInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const PartyTitleInput({super.key, required this.onChanged});

  @override
  State<PartyTitleInput> createState() => _PartyTitleInputState();
}

class _PartyTitleInputState extends State<PartyTitleInput> {
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
        const Text("파티명", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          onChanged: _handleInputChange,
          decoration: InputDecoration(
            hintText: "파티명을 입력해 주세요 (최대 100자 이내)",
            hintStyle: const TextStyle(color: Color(0xFFB7B7B7), fontSize: 16, fontWeight: FontWeight.bold),
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
          const Text("파티명이 100자 이상입니다.", style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
} 