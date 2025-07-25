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
      bool isAmStart = startTime.period == DayPeriod.am;
      bool isAmEnd = endTime.period == DayPeriod.am;
      TimeMode _mode = TimeMode.range;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Select time',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(child: _buildTabButton('All day', TimeMode.allDay, _mode, () => setState(() => _mode = TimeMode.allDay))),
                            Expanded(child: _buildTabButton('Time', TimeMode.time, _mode, () => setState(() => _mode = TimeMode.time))),
                            Expanded(child: _buildTabButton('Range', TimeMode.range, _mode, () => setState(() => _mode = TimeMode.range))),
                          ],
                        ),

                        const SizedBox(height: 16),
                        Row(
                          children: const [
                            Expanded(child: Align(alignment: Alignment.centerLeft, child: Text('Start'))),
                            Expanded(child: Align(alignment: Alignment.centerLeft, child: Text('End'))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_mode == TimeMode.allDay)
                          const SizedBox.shrink()
                        else if (_mode == TimeMode.time)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildTimeSelector(startTime, isAmStart, (hour, minute, isAm) {
                                setState(() {
                                  startTime = TimeOfDay(hour: isAm ? hour : hour + 12, minute: minute);
                                  isAmStart = isAm;
                                });
                              }),
                              const Spacer(),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTimeSelector(startTime, isAmStart, (hour, minute, isAm) {
                                setState(() {
                                  startTime = TimeOfDay(hour: isAm ? hour : hour + 12, minute: minute);
                                  isAmStart = isAm;
                                });
                              }),
                              const Text('→'),
                              _buildTimeSelector(endTime, isAmEnd, (hour, minute, isAm) {
                                setState(() {
                                  endTime = TimeOfDay(hour: isAm ? hour : hour + 12, minute: minute);
                                  isAmEnd = isAm;
                                });
                              }),
                            ],
                          ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context), // Cancel only closes
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (_mode == TimeMode.allDay) {
                                  startTime = const TimeOfDay(hour: 0, minute: 0);
                                  endTime = const TimeOfDay(hour: 23, minute: 59);
                                } else if (_mode == TimeMode.time) {
                                  final adjustedMinute = (startTime.minute + 1) % 60;
                                  final adjustedHour = (startTime.minute + 1) >= 60 ? (startTime.hour + 1) % 24 : startTime.hour;
                                  endTime = TimeOfDay(hour: adjustedHour, minute: adjustedMinute);
                                }
                                Navigator.pop(
                                  context,
                                  TimeRangeResult(startTime: startTime, endTime: endTime),
                                );
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    },
  );
}

Widget _buildTimeSelector(TimeOfDay time, bool isAm, Function(int hour, int minute, bool isAm) onTimeChanged) {
  int hour = time.hourOfPeriod;
  int minute = time.minute;
  return Flexible(
    child: Row(
      children: [
        Container(
          constraints: BoxConstraints(minWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: hour,
                items: List.generate(12, (index) => index + 1)
                    .map((h) => DropdownMenuItem(value: h, child: Text(h.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 12))))
                    .toList(),
                onChanged: (val) => onTimeChanged(val!, minute, isAm),
              ),
              const Text(' : ', style: TextStyle(fontSize: 12)),
              DropdownButton<int>(
                value: minute,
                items: List.generate(60, (index) => index)
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 12))))
                    .toList(),
                onChanged: (val) => onTimeChanged(hour, val!, isAm),
              ),
              Container(
                width: 32,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => onTimeChanged(hour, minute, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAm ? const Color(0xFF7C4DFF) : Colors.white,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                        ),
                        child: Text('AM', textAlign: TextAlign.center, style: TextStyle(color: isAm ? Colors.white : Colors.black, fontSize: 11)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onTimeChanged(hour, minute, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: !isAm ? const Color(0xFF7C4DFF) : Colors.white,
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                        ),
                        child: Text('PM', textAlign: TextAlign.center, style: TextStyle(color: !isAm ? Colors.white : Colors.black, fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildTabButton(String label, TimeMode mode, TimeMode selectedMode, VoidCallback onTap) {
  final isSelected = mode == selectedMode;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF7C4DFF) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
      ),
    ),
  );
}

class TimeRangeResult {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  TimeRangeResult({required this.startTime, required this.endTime});
}