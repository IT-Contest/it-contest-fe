import 'package:flutter/material.dart';
import 'input.dart';
import 'tip_box.dart';

class QuestPrioritySection extends StatefulWidget {
  const QuestPrioritySection({
    super.key,
    required this.onPriorityChanged,
    required this.onPeriodChanged,
    this.showTipBox = true,
  });

  final ValueChanged<int> onPriorityChanged;
  final ValueChanged<String> onPeriodChanged;
  final bool showTipBox;

  @override
  State<QuestPrioritySection> createState() => _QuestPrioritySectionState();
}

class _QuestPrioritySectionState extends State<QuestPrioritySection> {
  String? selectedPeriod;
  final TextEditingController _priorityController = TextEditingController();

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
        if (widget.showTipBox) const PriorityTipBox(),
        if (widget.showTipBox) const SizedBox(height: 20),
        if (!widget.showTipBox) const SizedBox(height: 0),
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