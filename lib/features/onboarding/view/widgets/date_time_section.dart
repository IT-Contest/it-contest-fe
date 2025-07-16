import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/onboarding/view/widgets/custom_date_picker.dart';
import 'package:it_contest_fe/features/onboarding/view/widgets/time_range_picker.dart';

class DateTimeSection extends StatefulWidget {
  const DateTimeSection({super.key});

  @override
  State<DateTimeSection> createState() => _DateTimeSectionState();
}

class _DateTimeSectionState extends State<DateTimeSection> {
  final _startYearController = TextEditingController();
  final _startMonthController = TextEditingController();
  final _startDayController = TextEditingController();

  final _endYearController = TextEditingController();
  final _endMonthController = TextEditingController();
  final _endDayController = TextEditingController();

  TimeOfDay? startTime;
  TimeOfDay? endTime;
  DateTime? endDate;

  @override
  void dispose() {
    _startYearController.dispose();
    _startMonthController.dispose();
    _startDayController.dispose();
    _endYearController.dispose();
    _endMonthController.dispose();
    _endDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("시작 일자", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildStartDateRow(),
        const SizedBox(height: 16),
        const Text("마감 일자", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildDateRow(),
        const SizedBox(height: 16),
        const Text("시작 시간", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickTime,
          child: AbsorbPointer(child: _buildTimeRow(startTime, "시작 시간")),
        ),
        const SizedBox(height: 16),
        const Text("종료 시간", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickTime,
          child: AbsorbPointer(child: _buildTimeRow(endTime, "종료 시간")),
        ),
      ],
    );
  }

  Future<void> _pickTime() async {
    final result = await showTimeRangePickerDialog(
      context: context,
      initialStartTime: TimeOfDay(hour: 7, minute: 0),
      initialEndTime: TimeOfDay(hour: 9, minute: 0),
    );
    if (result != null) {
      setState(() {
        startTime = result.startTime;
        endTime = result.endTime;
      });
    }
  }

  Widget _buildStartDateRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _dateTapBox(_startYearController, "년"),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: _dateTapBox(_startMonthController, "월"),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: _dateTapBox(_startDayController, "일"),
        ),
      ],
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _dateTapBox(_endYearController, "년", isEndDate: true),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: _dateTapBox(_endMonthController, "월", isEndDate: true),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: _dateTapBox(_endDayController, "일", isEndDate: true),
        ),
      ],
    );
  }

  Widget _dateTapBox(TextEditingController controller, String label, {bool isEndDate = false}) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showCustomDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  controller.text = label == "년" ? picked.year.toString() : label == "월"
                      ? picked.month.toString().padLeft(2, '0') : picked.day.toString().padLeft(2, '0');

                  if (isEndDate) {
                    endDate = picked;
                    _endYearController.text = picked.year.toString();
                    _endMonthController.text = picked.month.toString().padLeft(2, '0');
                    _endDayController.text = picked.day.toString().padLeft(2, '0');
                  } else {
                    _startYearController.text = picked.year.toString();
                    _startMonthController.text = picked.month.toString().padLeft(2, '0');
                    _startDayController.text = picked.day.toString().padLeft(2, '0');
                  }
                });
              }
            },
            child: AbsorbPointer(child: _dateBox(controller: controller)),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildTimeRow(TimeOfDay? time, String label) {
    final int h = time?.hour ?? 0;
    final ampm = time == null ? "오전 / 오후" : (h < 12 ? "오전" : "오후");
    final hour = time == null ? "" : ((h % 12 == 0) ? 12 : h % 12).toString().padLeft(2, '0');
    final minute = time == null ? "" : (time.minute.toString().padLeft(2, '0'));

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _textField(ampm),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: _textField(hour),
        ),
        const SizedBox(width: 4),
        const Text("시"),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: _textField(minute),
        ),
        const SizedBox(width: 4),
        const Text("분"),
      ],
    );
  }

  Widget _textField(String text) {
    final isPlaceholder = text == "오전 / 오후";
    return SizedBox(
      height: 48,
      child: TextField(
        controller: TextEditingController(text: text),
        readOnly: true,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isPlaceholder ? Colors.grey : Colors.black,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB7B7B7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB7B7B7)),
          ),
        ),
      ),
    );
  }

  Widget _dateBox({required TextEditingController controller}) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        readOnly: true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB7B7B7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB7B7B7)),
          ),
        ),
      ),
    );
  }
}