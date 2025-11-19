import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// 🔹 기간별 날짜 계산 헬퍼 함수
DateTime _calculatePeriodEndDate(DateTime startDate, String period) {
  switch (period) {
    case '주간':
      return startDate.add(const Duration(days: 6)); // 7일 중 마지막 날
    case '월간':
      return DateTime(startDate.year, startDate.month + 1, startDate.day - 1);
    case '연간':
      return DateTime(startDate.year + 1, startDate.month, startDate.day - 1);
    default: // '일일'
      return startDate;
  }
}

// 🔹 주기별 유효 날짜 판단
bool _isValidDateForPeriod(DateTime date, DateTime baseStartDate, String period) {
  if (period == '일일') return true;

  DateTime periodStart = baseStartDate;
  DateTime periodEnd = _calculatePeriodEndDate(baseStartDate, period);

  switch (period) {
    case '주간':
      int daysDiff = date.difference(periodStart).inDays;
      return daysDiff >= 0 && daysDiff % 7 == 0;
    case '월간':
      return date.day == periodStart.day &&
          date.isAfter(periodStart.subtract(const Duration(days: 1)));
    case '연간':
      return date.month == periodStart.month &&
          date.day == periodStart.day &&
          date.year >= periodStart.year;
    default:
      return true;
  }
}

// 🔹 메인 커스텀 데이트 피커
Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? questPeriod, // '일일', '주간', '월간', '연간'
  DateTime? startDate,
}) async {
  DateTime? selectedDate = initialDate;
  DateTime focusedDate = initialDate;

  if (initialDate.isBefore(firstDate)) {
    focusedDate = firstDate;
  } else if (initialDate.isAfter(lastDate)) {
    focusedDate = lastDate;
  }

  return showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView( // ✅ 오버플로우 방지
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context, () {
                      setState(() => selectedDate = null);
                    }, () {
                      setState(() {
                        DateTime today = DateTime.now();
                        if (today.isBefore(firstDate)) {
                          selectedDate = firstDate;
                          focusedDate = firstDate;
                        } else if (today.isAfter(lastDate)) {
                          selectedDate = lastDate;
                          focusedDate = lastDate;
                        } else {
                          selectedDate = today;
                          focusedDate = today;
                        }
                      });
                    }, () => Navigator.of(context).pop()),

                    const SizedBox(height: 10),

                    // 🔹 연/월 선택 헤더
                    _buildCalendarHeader(context, focusedDate, (newYear) {
                      setState(() {
                        DateTime newDate = DateTime(newYear, focusedDate.month, focusedDate.day);
                        if (newDate.isBefore(firstDate)) {
                          focusedDate = firstDate;
                        } else if (newDate.isAfter(lastDate)) {
                          focusedDate = lastDate;
                        } else {
                          focusedDate = newDate;
                        }
                      });
                    }, (isNext) {
                      setState(() {
                        DateTime newDate = DateTime(
                          focusedDate.year,
                          isNext ? focusedDate.month + 1 : focusedDate.month - 1,
                          1,
                        );
                        if (newDate.isBefore(firstDate)) {
                          focusedDate = firstDate;
                        } else if (newDate.isAfter(lastDate)) {
                          focusedDate = lastDate;
                        } else {
                          focusedDate = newDate;
                        }
                      });
                    }),

                    const SizedBox(height: 10),

                    // 🔹 달력 본체
                    Flexible(
                      fit: FlexFit.loose, // ✅ 공간을 여유롭게 사용
                      child: TableCalendar(
                        firstDay: firstDate,
                        lastDay: lastDate,
                        focusedDay: focusedDate,
                        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                        onDaySelected: (newSelectedDay, newFocusedDay) {
                          if (questPeriod != null && questPeriod != '일일' && startDate != null) {
                            if (_isValidDateForPeriod(newSelectedDay, startDate!, questPeriod!)) {
                              setState(() {
                                selectedDate = newSelectedDay;
                                focusedDate = newFocusedDay;
                              });
                            }
                          } else {
                            setState(() {
                              selectedDate = newSelectedDay;
                              focusedDate = newFocusedDay;
                            });
                          }
                        },
                        onPageChanged: (newFocusedDay) {
                          setState(() => focusedDate = newFocusedDay);
                        },
                        headerVisible: false,
                        rowHeight: 40,
                        daysOfWeekHeight: 20,
                        calendarStyle: CalendarStyle(
                          cellMargin: const EdgeInsets.all(2.0),
                          cellPadding: const EdgeInsets.all(4.0),
                          todayDecoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF6A4DFF), width: 1.5),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: const TextStyle(color: Color(0xFF6A4DFF), fontSize: 16),
                          selectedDecoration: const BoxDecoration(
                            color: Color(0xFF6A4DFF),
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
                          defaultTextStyle: const TextStyle(color: Colors.black, fontSize: 16),
                          weekendTextStyle: const TextStyle(color: Colors.black, fontSize: 16),
                          outsideTextStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                          disabledTextStyle: TextStyle(color: Colors.grey[300], fontSize: 16),
                        ),
                        enabledDayPredicate: (day) {
                          if (questPeriod != null && questPeriod != '일일' && startDate != null) {
                            return _isValidDateForPeriod(day, startDate!, questPeriod!);
                          }
                          return true;
                        },
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
            ),
          );
        },
      );
    },
  );
}

// 🔹 상단 헤더 (Clear, Today, Close)
Widget _buildHeader(
    BuildContext context, VoidCallback onClear, VoidCallback onToday, VoidCallback onClose) {
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
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4),
          OutlinedButton.icon(
            onPressed: onToday,
            icon: const Icon(Icons.arrow_downward, size: 14),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
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
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 0),
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

// 🔹 하단 버튼 (취소 / 완료)
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

// 🔹 연도/월 이동용 캘린더 헤더
Widget _buildCalendarHeader(
    BuildContext context,
    DateTime focusedDate,
    ValueChanged<int> onYearChanged,
    ValueChanged<bool> onMonthChanged,
    ) {
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
            items: years
                .map((year) => DropdownMenuItem(
              value: year,
              child: Text(
                '$year',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: year == focusedDate.year
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ))
                .toList(),
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
