import 'package:flutter/material.dart';

class EmptyQuestWidget extends StatelessWidget {
  final String imagePath;
  final String message;

  const EmptyQuestWidget({
    super.key,
    required this.imagePath,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 3), // 위 여백 적게
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 160,
                height: 160,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(flex: 5), // 아래 여백 많게
      ],
    );
  }
}
