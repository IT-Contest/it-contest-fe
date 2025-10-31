import 'package:flutter/material.dart';
import 'input.dart';

class QuestPrioritySection extends StatefulWidget {
  final int? initialPriority;
  final String? initialPeriod;
  const QuestPrioritySection({
    super.key,
    required this.onPriorityChanged,
    required this.onPeriodChanged,
    this.initialPriority,
    this.initialPeriod,
  });

  final ValueChanged<int> onPriorityChanged;
  final ValueChanged<String> onPeriodChanged;

  @override
  State<QuestPrioritySection> createState() => _QuestPrioritySectionState();
}

class _QuestPrioritySectionState extends State<QuestPrioritySection> {
  String? selectedPeriod;
  late final TextEditingController _priorityController;

  @override
  void initState() {
    super.initState();
    selectedPeriod = widget.initialPeriod;
    _priorityController = TextEditingController(
      text: widget.initialPriority?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _priorityController.dispose();
    super.dispose();
  }

  void _handlePriorityChange(String value) {
    final intVal = int.tryParse(value);
    if (intVal != null) {
      widget.onPriorityChanged(intVal);
    }
  }

  void _handlePeriodSelect(String period) {
    setState(() => selectedPeriod = period);
    widget.onPeriodChanged(period);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "우선순위",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        PriorityInputSection(
          controller: _priorityController,
          onChanged: _handlePriorityChange,
          selectedPeriod: selectedPeriod,
          onPeriodSelected: _handlePeriodSelect,
        ),
      ],
    );
  }
}
