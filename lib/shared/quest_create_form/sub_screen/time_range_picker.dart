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
                        const Expanded(
                          child: Text('Start', style: TextStyle(color: Colors.black54)),
                        ),
                        if (mode == TimeMode.range) ...[
                          const SizedBox(width: 24), // 화살표 아이콘 공간
                          const Expanded(
                            child: Text('End', style: TextStyle(color: Colors.black54)),
                          ),
                        ]
                      ],
                    ),
                  if (mode != TimeMode.allDay) const SizedBox(height: 8),
                  if (mode == TimeMode.time)
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeDisplay(context, startTime, handleStartTimeChange),
                        ),
                      ],
                    )
                  else if (mode == TimeMode.range)
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeDisplay(context, startTime, handleStartTimeChange),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
                        ),
                        Expanded(
                          child: _buildTimeDisplay(context, endTime, handleEndTimeChange),
                        ),
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

  return LayoutBuilder(
    builder: (context, constraints) {
      // 사용 가능한 너비에 따라 동적으로 크기 조절
      final double availableWidth = constraints.maxWidth;
      final double fontSize = availableWidth > 140 ? 20 : 16;
      final double horizontalPadding = availableWidth > 140 ? 8.0 : 4.0;
      final double verticalPadding = availableWidth > 140 ? 10.0 : 8.0;
      final double ampmPadding = availableWidth > 140 ? 8.0 : 6.0;
      final double ampmFontSize = availableWidth > 140 ? 12 : 10;
      
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: selectTime,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${time.hourOfPeriod.toString().padLeft(2, '0')} : ${time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.grey.shade300))
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (time.hour >= 12) {
                          onTimeChanged(TimeOfDay(hour: time.hour - 12, minute: time.minute));
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: ampmPadding, vertical: ampmPadding),
                        decoration: BoxDecoration(
                          color: isAm ? const Color(0xFF6A4DFF) : Colors.transparent,
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('AM', style: TextStyle(color: isAm ? Colors.white : Colors.black, fontSize: ampmFontSize, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (time.hour < 12) {
                          onTimeChanged(TimeOfDay(hour: time.hour + 12, minute: time.minute));
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: ampmPadding, vertical: ampmPadding),
                        decoration: BoxDecoration(
                          color: !isAm ? const Color(0xFF6A4DFF) : Colors.transparent,
                          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8)),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('PM', style: TextStyle(color: !isAm ? Colors.white : Colors.black, fontSize: ampmFontSize, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    },
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