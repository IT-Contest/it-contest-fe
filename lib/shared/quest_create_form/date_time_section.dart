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
  final String? questType; // DAILY, WEEKLY, MONTHLY, YEARLY
  final String? selectedPeriod; // 우선순위 섹션에서 선택된 기간 (일일, 주간, 월간, 연간)

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
    this.selectedPeriod,
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

  // Helper for displaying date/time parts
  String _getYear(DateTime? d) => d != null ? d.year.toString() : '';
  String _getMonth(DateTime? d) => d != null ? d.month.toString().padLeft(2, '0') : '';
  String _getDay(DateTime? d) => d != null ? d.day.toString().padLeft(2, '0') : '';

  String _getPeriod(TimeOfDay? t) => t == null ? '' : (t.hour < 12 ? '오전' : '오후');
  String _getHour(TimeOfDay? t) =>
      t == null ? '' : ((t.hour % 12 == 0 ? 12 : t.hour % 12).toString().padLeft(2, '0'));
  String _getMinute(TimeOfDay? t) => t == null ? '' : t.minute.toString().padLeft(2, '0');

  // ---------------- 날짜 선택 ----------------
  Future<void> _pickStartDate() async {
    final picked = await showCustomDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(), // 오늘 이후만 선택 가능
      lastDate: DateTime(2100),
      questPeriod: widget.selectedPeriod,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // 기간별로 마감일자 자동 설정
        if (widget.selectedPeriod != null && widget.selectedPeriod != '일일') {
          _dueDate = _calculatePeriodEndDate(picked, widget.selectedPeriod!);
        }
      });
      widget.onStartDateChanged?.call(picked);
      // 자동 설정된 마감일자도 콜백 호출
      if (_dueDate != null) {
        widget.onDueDateChanged?.call(_dueDate!);
      }
    }
  }

  // 기간별 마감일자 계산 헬퍼 함수
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

  Future<void> _pickDueDate() async {
    // 마감일자의 최소 날짜는 시작일자 또는 오늘 중 더 늦은 날짜
    final minDate = _startDate != null 
        ? (_startDate!.isAfter(DateTime.now()) ? _startDate! : DateTime.now())
        : DateTime.now();
    
    final picked = await showCustomDatePicker(
      context: context,
      initialDate: _dueDate ?? minDate,
      firstDate: minDate, // 시작일자 또는 오늘 이후만 선택 가능
      lastDate: DateTime(2100),
      questPeriod: widget.selectedPeriod,
      startDate: _startDate, // 시작일자를 기준으로 한 제한
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
      widget.onDueDateChanged?.call(picked);
    }
  }

  // ---------------- 시간 선택 ----------------
  Future<void> _pickStartTime() async {
    final result = await showTimeRangePickerDialog(
      context: context,
      initialStartTime: _startTime ?? TimeOfDay.now(),
      initialEndTime: _startTime ?? TimeOfDay.now(),
    );
    if (result != null) {
      setState(() => _startTime = result.startTime);
      widget.onStartTimeChanged?.call(result.startTime);
    }
  }

  Future<void> _pickEndTime() async {
    final result = await showTimeRangePickerDialog(
      context: context,
      initialStartTime: _endTime ?? TimeOfDay.now(),
      initialEndTime: _endTime ?? TimeOfDay.now(),
    );
    if (result != null) {
      setState(() => _endTime = result.endTime);
      widget.onEndTimeChanged?.call(result.endTime);
    }
  }

  // ---------------- UI Helper ----------------
  Widget _dateBox(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
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
          border: Border.all(color: const Color(0xFFD1D5DB)),
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

  // ---------------- Build ----------------
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 시작 일자
        const Text('시작 일자', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Row(
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

        const SizedBox(height: 16),

        // 마감 일자
        const Text('마감 일자', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Row(
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

        const SizedBox(height: 16),

        // 시작 시간
        const Text('시작 시간', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(flex: 130, child: _timeBox(_getPeriod(_startTime).isEmpty ? '오전 / 오후' : _getPeriod(_startTime), _pickStartTime)),
            const SizedBox(width: 8),
            Expanded(flex: 48, child: _timeBox(_getHour(_startTime), _pickStartTime)),
            const SizedBox(width: 4),
            const Text('시', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Expanded(flex: 48, child: _timeBox(_getMinute(_startTime), _pickStartTime)),
            const SizedBox(width: 4),
            const Text('분', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),

        const SizedBox(height: 16),

        // 종료 시간
        const Text('종료 시간', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(flex: 130, child: _timeBox(_getPeriod(_endTime).isEmpty ? '오전 / 오후' : _getPeriod(_endTime), _pickEndTime)),
            const SizedBox(width: 8),
            Expanded(flex: 48, child: _timeBox(_getHour(_endTime), _pickEndTime)),
            const SizedBox(width: 4),
            const Text('시', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Expanded(flex: 48, child: _timeBox(_getMinute(_endTime), _pickEndTime)),
            const SizedBox(width: 4),
            const Text('분', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
