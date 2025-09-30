import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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
    if (selectedPriority == null || selectedPriority < 1 || selectedPriority > 5) {
      selectedPriority = null;
    }

    return Column(
      children: [
        // 🔹 우선순위 드롭다운
        DropdownButtonHideUnderline(
          child: DropdownButton2<int>(
            value: selectedPriority,
            hint: const Text(
              "숫자를 선택해 주세요",
              style: TextStyle(
                color: Color(0xFFD1D5DB)
              ),
            ),
            items: List.generate(5, (index) {
              final priority = index + 1;
              return DropdownMenuItem(
                value: priority,
                child: Text(
                    "$priority순위",
                  style: const TextStyle(
                  color: Color(0xFF6B7280)
                  )
                ),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                controller.text = value.toString();
                onChanged(controller.text);
              }
            },
            buttonStyleData: ButtonStyleData(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD1D5DB)),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 48,
              width: double.infinity, // 👉 부모 크기만큼 차지
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              maxHeight: 200,
              offset: const Offset(0, -4), // y값을 조정 (음수면 위로, 양수면 더 아래로)
            ),
            iconStyleData: IconStyleData(
              icon: Image.asset(
                "assets/icons/card_down.png", // ✅ 커스텀 화살표 아이콘
                width: 20,
                height: 20,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 🔹 주기 버튼 (일일/주간/월간/연간)
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
                        : const Color(0xFFD1D5DB),
                    side: BorderSide(
                      color: selectedPeriod == label
                          ? const Color(0xFF6B3FFF)
                          : const Color(0xFFD1D5DB),
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
