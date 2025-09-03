import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Color(0xFF7958FF),
      unselectedItemColor: Colors.black,
      backgroundColor: Colors.white,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.help_outline), // or custom icon
          label: '퀘스트',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit),
          label: '분석',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.workspace_premium),
          label: '혜택',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '프로필',
        ),
      ],
    );
  }
}