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
    int? selectedPriority = int.tryParse(controller.text);

    return Column(
      children: [
        // 🔹 우선순위 토글 버튼 (1~5) — TextField 대신 이거만 교체
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final priority = index + 1;
            final isSelected = selectedPriority == priority;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isSelected
                        ? const Color(0xFF6B3FFF)
                        : const Color(0xFFB7B7B7),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF6B3FFF)
                          : const Color(0xFFB7B7B7),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: isSelected ? const Color(0xFFEDE6FF) : null,
                  ),
                  onPressed: () {
                    controller.text = priority.toString();
                    onChanged(controller.text);
                  },
                  child: Text(priority.toString(),
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 12),

        // 🔹 주기 버튼 — 기존 코드 그대로 둠
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ["일일", "주간", "월간", "연간"].map((label) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: selectedPeriod == label
                        ? const Color(0xFF6B3FFF)
                        : const Color(0xFFB7B7B7),
                    side: BorderSide(
                      color: selectedPeriod == label
                          ? const Color(0xFF6B3FFF)
                          : const Color(0xFFB7B7B7),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                    selectedPeriod == label ? const Color(0xFFEDE6FF) : null,
                  ),
                  onPressed: () => onPeriodSelected(label),
                  child: Text(label, style: const TextStyle(fontSize: 16)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
