import 'package:flutter/material.dart';

class ProfilePageWidget extends StatelessWidget {
  const ProfilePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 상단바 직접 작성
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu, color: Colors.deepPurple),
                Image.asset('assets/images/logo.jpg', height: 40),
                const Icon(Icons.notifications_none, color: Colors.deepPurple),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.grey)
        ],
      ),
    );
  }
}
