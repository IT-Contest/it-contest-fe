import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  DateTime? selectedDate = initialDate;
  DateTime focusedDate = initialDate;

  return showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              height: 480,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context, () {
                    setState(() {
                      selectedDate = null;
                    });
                  }, () {
                    setState(() {
                      selectedDate = DateTime.now();
                      focusedDate = DateTime.now();
                    });
                  }, () => Navigator.of(context).pop()),
                  const SizedBox(height: 10),
                  // 커스텀 캘린더 헤더
                  _buildCalendarHeader(context, focusedDate, (newYear) {
                    setState(() {
                      focusedDate = DateTime(newYear, focusedDate.month, focusedDate.day);
                    });
                  }, (isNext) {
                    setState(() {
                      focusedDate = DateTime(
                        focusedDate.year,
                        isNext ? focusedDate.month + 1 : focusedDate.month - 1,
                        1,
                      );
                    });
                  }),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TableCalendar(
                      firstDay: firstDate,
                      lastDay: lastDate,
                      focusedDay: focusedDate,
                      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                      onDaySelected: (newSelectedDay, newFocusedDay) {
                        setState(() {
                          selectedDate = newSelectedDay;
                          focusedDate = newFocusedDay;
                        });
                      },
                      onPageChanged: (newFocusedDay) {
                        setState(() {
                          focusedDate = newFocusedDay;
                        });
                      },
                      headerVisible: false,
                      rowHeight: 40,
                      daysOfWeekHeight: 20,
                      calendarStyle: CalendarStyle(
                        cellMargin: const EdgeInsets.all(2.0), // 셀 간격 축소
                        cellPadding: const EdgeInsets.all(4.0), // 셀 패딩 추가
                        todayDecoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF6A4DFF), width: 1.5),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(color: Color(0xFF6A4DFF), fontSize: 16), // 폰트 크기 통일
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF6A4DFF),
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(fontSize: 16, color: Colors.white), // 폰트 크기 추가
                        defaultTextStyle: const TextStyle(color: Colors.black, fontSize: 16), // 폰트 크기 증가
                        weekendTextStyle: const TextStyle(color: Colors.black, fontSize: 16), // 폰트 크기 통일
                        outsideTextStyle: TextStyle(color: Colors.grey[400], fontSize: 16), // 폰트 크기 통일
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekendStyle: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFooter(context, selectedDate),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildHeader(BuildContext context, VoidCallback onClear, VoidCallback onToday, VoidCallback onClose) {
  return Row(
    children: [
      const Text(
        'Select date',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF888888),
        ),
      ),
      const Spacer(),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.close, color: Colors.red, size: 14),
            label: const Text('Clear', style: TextStyle(color: Colors.red, fontSize: 12)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4),
          OutlinedButton.icon(
            onPressed: onToday,
            icon: const Icon(Icons.arrow_downward, size: 14),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8), // 위아래 여백 추가
              child: Text(
                'Today',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                  letterSpacing: -0.24,
                ),
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black), // 테두리 색을 검은색으로 변경
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    ],
  );
}

Widget _buildFooter(BuildContext context, DateTime? selectedDate) {
  return Row(
    children: [
      Expanded(
        flex: 1,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('취소', style: TextStyle(color: Colors.black, fontSize: 16)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: ElevatedButton(
          onPressed: () {
            if (selectedDate != null) {
              Navigator.of(context).pop(selectedDate);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A4DFF),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('완료', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    ],
  );
}

// 커스텀 캘린더 헤더 위젯
Widget _buildCalendarHeader(BuildContext context, DateTime focusedDate, ValueChanged<int> onYearChanged, ValueChanged<bool> onMonthChanged) {
  final years = List.generate(21, (i) => DateTime.now().year - 10 + i);
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: DropdownButton<int>(
            value: focusedDate.year,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            items: years.map((year) => DropdownMenuItem(
              value: year,
              child: Text(
                '$year',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: year == focusedDate.year ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            )).toList(),
            onChanged: (year) {
              if (year != null) onYearChanged(year);
            },
            underline: const SizedBox(),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onMonthChanged(false),
        ),
        Text(
          DateFormat.MMMM().format(focusedDate),
          style: const TextStyle(fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => onMonthChanged(true),
        ),
      ],
    ),
  );
}