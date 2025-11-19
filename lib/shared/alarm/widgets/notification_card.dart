import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final Widget child;

  const NotificationCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD1D5DB), // ✅ Gray/300
          width: 1,                       // ✅ 테두리 두께 1
        ),
      ),
      child: child,
    );
  }
}
