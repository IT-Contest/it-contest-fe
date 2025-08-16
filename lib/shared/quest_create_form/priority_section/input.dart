import 'package:flutter/material.dart';

class PriorityInputSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? selectedPeriod;
  final ValueChanged<String> onPeriodSelected;

  const PriorityInputSection({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "숫자를 직접 입력해 주세요",
            hintStyle: TextStyle(color: Color(0xFFB7B7B7), fontSize: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFB7B7B7)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFB7B7B7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFF7D4CFF), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          keyboardType: TextInputType.number,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ["일일", "주간", "월간", "연간"].map((label) {
            return PeriodChip(
              label: label,
              isSelected: selectedPeriod == label,
              onTap: () => onPeriodSelected(label),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PeriodChip({super.key, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: isSelected ? const Color(0xFF6B3FFF) : const Color(0xFFB7B7B7),
            side: BorderSide(color: isSelected ? const Color(0xFF6B3FFF) : const Color(0xFFB7B7B7)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onTap,
          child: Text(label),
        ),
      ),
    );
  }
}