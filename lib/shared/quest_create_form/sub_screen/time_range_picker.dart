import 'package:flutter/material.dart';

enum TimeMode { allDay, time, range }

Future<TimeRangeResult?> showTimeRangePickerDialog({
  required BuildContext context,
  required TimeOfDay initialStartTime,
  required TimeOfDay initialEndTime,
}) async {
  return showDialog<TimeRangeResult>(
    context: context,
    builder: (context) {
      TimeOfDay startTime = initialStartTime;
      TimeOfDay endTime = initialEndTime;
      TimeMode mode = TimeMode.range;

      return StatefulBuilder(
        builder: (context, setState) {
          void handleModeChange(TimeMode newMode) {
            setState(() => mode = newMode);
          }

          void handleStartTimeChange(TimeOfDay newTime) {
            setState(() => startTime = newTime);
          }

          void handleEndTimeChange(TimeOfDay newTime) {
            setState(() => endTime = newTime);
          }

          void handleOk() {
            TimeOfDay finalStartTime = startTime;
            TimeOfDay finalEndTime = endTime;

            if (mode == TimeMode.allDay) {
              finalStartTime = const TimeOfDay(hour: 0, minute: 0);
              finalEndTime = const TimeOfDay(hour: 23, minute: 59);
            } else if (mode == TimeMode.time) {
              finalEndTime = startTime; // If mode is 'time', end time is same as start time
            }
            Navigator.pop(
              context,
              TimeRangeResult(startTime: finalStartTime, endTime: finalEndTime),
            );
          }

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),
                  _buildTabs(context, mode, handleModeChange),
                  const SizedBox(height: 20),
                  if (mode != TimeMode.allDay)
                    Row(
                      children: [
                        const Text('Start', style: TextStyle(color: Colors.black54)),
                        const Spacer(),
                        if (mode == TimeMode.range) ...[
                          const Text('End', style: TextStyle(color: Colors.black54)),
                          const SizedBox(width: 80), // Spacer for alignment
                        ]
                      ],
                    ),
                  if (mode != TimeMode.allDay) const SizedBox(height: 8),
                  if (mode == TimeMode.time)
                    Row(
                      children: [
                        _buildTimeDisplay(context, startTime, handleStartTimeChange),
                        const Spacer(), // 남은 공간을 채우는 Spacer 추가
                      ],
                    )
                  else if (mode == TimeMode.range)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildTimeDisplay(context, startTime, handleStartTimeChange),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.arrow_forward, color: Colors.grey),
                        ),
                        _buildTimeDisplay(context, endTime, handleEndTimeChange),
                      ],
                    ),
                  const SizedBox(height: 24),
                  _buildFooter(context, handleOk),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildTabs(BuildContext context, TimeMode currentMode, ValueChanged<TimeMode> onModeChanged) {
  String getTextForMode(TimeMode mode) {
    switch (mode) {
      case TimeMode.allDay: return 'All day';
      case TimeMode.time: return 'Time';
      case TimeMode.range: return 'Range';
    }
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(25),
    ),
    child: Row(
      children: TimeMode.values.map((mode) {
        bool isSelected = mode == currentMode;
        return Expanded(
          child: GestureDetector(
            onTap: () => onModeChanged(mode),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE3D9FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  getTextForMode(mode),
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF6A4DFF) : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

Widget _buildTimeDisplay(BuildContext context, TimeOfDay time, ValueChanged<TimeOfDay> onTimeChanged) {
  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF6A4DFF)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != time) {
      onTimeChanged(picked);
    }
  }

  bool isAm = time.period == DayPeriod.am;

  return Container(
    padding: const EdgeInsets.fromLTRB(4, 0, 0, 0), // 오른쪽 패딩만 제거
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        GestureDetector(
          onTap: selectTime,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${time.hourOfPeriod.toString().padLeft(2, '0')} : ${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: Colors.grey.shade300))
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (time.hour >= 12) {
                    onTimeChanged(TimeOfDay(hour: time.hour - 12, minute: time.minute));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isAm ? const Color(0xFF6A4DFF) : Colors.transparent,
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
                  ),
                  child: Text('AM', style: TextStyle(color: isAm ? Colors.white : Colors.black, fontSize: 12)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (time.hour < 12) {
                    onTimeChanged(TimeOfDay(hour: time.hour + 12, minute: time.minute));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: !isAm ? const Color(0xFF6A4DFF) : Colors.transparent,
                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8)),
                  ),
                  child: Text('PM', style: TextStyle(color: !isAm ? Colors.white : Colors.black, fontSize: 12)),
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget _buildFooter(BuildContext context, VoidCallback onOk) {
  return Row(
    children: [
      Expanded(
        flex: 1,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('취소', style: TextStyle(color: Colors.black, fontSize: 16)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: ElevatedButton(
          onPressed: onOk,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A4DFF),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('완료', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    ],
  );
}

class TimeRangeResult {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  TimeRangeResult({required this.startTime, required this.endTime});
}