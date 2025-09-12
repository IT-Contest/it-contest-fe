import 'package:flutter/material.dart';
import 'package:it_contest_fe/shared/quest_create_form/sub_screen/custom_date_picker.dart';
import 'package:it_contest_fe/shared/quest_create_form/sub_screen/time_range_picker.dart';

class DateTimeSection extends StatefulWidget {
  final ValueChanged<DateTime>? onStartDateChanged;
  final ValueChanged<DateTime>? onDueDateChanged;
  final ValueChanged<TimeOfDay>? onStartTimeChanged;
  final ValueChanged<TimeOfDay>? onEndTimeChanged;
  final DateTime? initialStartDate;
  final DateTime? initialDueDate;
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final String? questType; // 퀘스트 타입 추가 (DAILY, WEEKLY, MONTHLY, YEARLY)

  const DateTimeSection({
    super.key,
    this.onStartDateChanged,
    this.onDueDateChanged,
    this.onStartTimeChanged,
    this.onEndTimeChanged,
    this.initialStartDate,
    this.initialDueDate,
    this.initialStartTime,
    this.initialEndTime,
    this.questType,
  });

  @override
  State<DateTimeSection> createState() => _DateTimeSectionState();
}

class _DateTimeSectionState extends State<DateTimeSection> {
  DateTime? _startDate;
  DateTime? _dueDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _dueDate = widget.initialDueDate;
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
  }

  // Helper for displaying date parts
  String _getYear(DateTime? d) => d != null ? d.year.toString() : '';
  String _getMonth(DateTime? d) => d != null ? d.month.toString().padLeft(2, '0') : '';
  String _getDay(DateTime? d) => d != null ? d.day.toString().padLeft(2, '0') : '';

  String _getPeriod(TimeOfDay? t) => t == null ? '' : (t.hour < 12 ? '오전' : '오후');
  String _getHour(TimeOfDay? t) => t == null ? '' : ((t.hour % 12 == 0 ? 12 : t.hour % 12).toString().padLeft(2, '0'));
  String _getMinute(TimeOfDay? t) => t == null ? '' : t.minute.toString().padLeft(2, '0');

  // 퀘스트 타입에 따른 최소 마감일 계산
  DateTime _getMinimumDueDate(DateTime startDate) {
    switch (widget.questType) {
      case 'WEEKLY':
        return startDate.add(const Duration(days: 7));
      case 'MONTHLY':
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case 'YEARLY':
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
      default: // DAILY 또는 null
        return startDate;
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showCustomDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _dueDate ?? DateTime(2100), // 마감일이 설정되어 있으면 그것을 lastDate로 제한
    );
    if (picked != null) {
      final minimumDueDate = _getMinimumDueDate(picked);
      
      setState(() {
        _startDate = picked;
        // 마감일이 설정되지 않았거나, 현재 마감일이 최소 기간보다 이전인 경우 자동 조정
        if (_dueDate == null || _dueDate!.isBefore(minimumDueDate)) {
          _dueDate = minimumDueDate;
        }
      });
      
      widget.onStartDateChanged?.call(picked);
      if (_dueDate != null) {
        widget.onDueDateChanged?.call(_dueDate!);
      }
    }
  }

  Future<void> _pickDueDate() async {
    // 시작일이 설정되어 있다면 퀘스트 타입에 따른 최소 마감일을 계산
    DateTime firstDate;
    if (_startDate != null) {
      firstDate = _getMinimumDueDate(_startDate!);
    } else {
      firstDate = DateTime(2000);
    }

    final picked = await showCustomDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() => _dueDate = picked);
      widget.onDueDateChanged?.call(picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final result = await showTimeRangePickerDialog(
      context: context,
      initialStartTime: _startTime ?? TimeOfDay.now(),
      initialEndTime: _endTime ?? TimeOfDay.now(),
    );
    if (result != null) {
      setState(() {
        _startTime = result.startTime;
        _endTime = result.endTime;
      });
      widget.onStartTimeChanged?.call(result.startTime);
      widget.onEndTimeChanged?.call(result.endTime);
    }
  }

  Widget _dateBox(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFB7B7B7)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _timeBox(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFB7B7B7)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('시작 일자', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(flex: 90, child: _dateBox(_getYear(_startDate), _pickStartDate)),
              const SizedBox(width: 8),
              const Text('년', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(flex: 48, child: _dateBox(_getMonth(_startDate), _pickStartDate)),
              const SizedBox(width: 8),
              const Text('월', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(flex: 48, child: _dateBox(_getDay(_startDate), _pickStartDate)),
              const SizedBox(width: 8),
              const Text('일', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('마감 일자', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(flex: 90, child: _dateBox(_getYear(_dueDate), _pickDueDate)),
              const SizedBox(width: 8),
              const Text('년', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(flex: 48, child: _dateBox(_getMonth(_dueDate), _pickDueDate)),
              const SizedBox(width: 8),
              const Text('월', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(flex: 48, child: _dateBox(_getDay(_dueDate), _pickDueDate)),
              const SizedBox(width: 8),
              const Text('일', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('시작 시간', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(flex: 130, child: _timeBox(_getPeriod(_startTime).isEmpty ? '오전 / 오후' : _getPeriod(_startTime), () => _pickTime(isStart: true))),
            const SizedBox(width: 8),
            Expanded(flex: 48, child: _timeBox(_getHour(_startTime), () => _pickTime(isStart: true))),
            const SizedBox(width: 4),
            const Text('시', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Expanded(flex: 48, child: _timeBox(_getMinute(_startTime), () => _pickTime(isStart: true))),
            const SizedBox(width: 4),
            const Text('분', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        const Text('종료 시간', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(flex: 130, child: _timeBox(_getPeriod(_endTime).isEmpty ? '오전 / 오후' : _getPeriod(_endTime), () => _pickTime(isStart: false))),
            const SizedBox(width: 8),
            Expanded(flex: 48, child: _timeBox(_getHour(_endTime), () => _pickTime(isStart: false))),
            const SizedBox(width: 4),
            const Text('시', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Expanded(flex: 48, child: _timeBox(_getMinute(_endTime), () => _pickTime(isStart: false))),
            const SizedBox(width: 4),
            const Text('분', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}