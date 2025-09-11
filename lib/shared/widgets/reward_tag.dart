import 'package:flutter/material.dart';

class RewardTag extends StatelessWidget {
  final String label;
  final bool border;
  const RewardTag({required this.label, this.border = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: border ? Colors.white : const Color(0xFF7958FF),
        border: border ? Border.all(color: const Color(0xFF7958FF)) : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: border ? const Color(0xFF7958FF) : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}