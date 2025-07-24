import 'package:flutter/material.dart';

class CategoryInput extends StatefulWidget {
  const CategoryInput({Key? key, required this.onChanged}) : super(key: key);
  final ValueChanged<List<String>> onChanged;

  @override
  State<CategoryInput> createState() => _CategoryInputState();
}

class _CategoryInputState extends State<CategoryInput> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _categories = [];

  void _notifyParent() {
    widget.onChanged(List<String>.from(_categories));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "카테고리 분류",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onSubmitted: (value) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty && !_categories.contains(trimmed)) {
              setState(() {
                _categories.add(trimmed);
                _controller.clear();
              });
              _notifyParent();
            }
          },
          decoration: InputDecoration(
            hintText: "카테고리를 직접 입력해 주세요",
            hintStyle: const TextStyle(color: Color(0xFFB7B7B7), fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFB7B7B7)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFB7B7B7)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFF7D4CFF), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._categories.map((category) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF643EFF)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("#$category", style: const TextStyle(color: Color(0xFF643EFF))),
              );
            }).toList(),
            if (_categories.isNotEmpty)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF643EFF),
                  side: const BorderSide(color: Color(0xFF643EFF)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  visualDensity: VisualDensity(vertical: -2),
                ),
                onPressed: () {
                  setState(() => _categories.removeLast());
                  _notifyParent();
                },
                child: const Text("삭제하기", style: TextStyle(fontSize: 14, color: Color(0xFF643EFF))),
              ),
          ],
        ),
      ],
    );
  }
}