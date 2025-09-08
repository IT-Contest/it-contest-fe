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
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/home.png',
            width: 24,
            height: 24,
            color: currentIndex == 0 ? Color(0xFF7958FF) : Colors.black,
          ),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/help.png',
            width: 24,
            height: 24,
            color: currentIndex == 1 ? Color(0xFF7958FF) : Colors.black,
          ),
          label: '퀘스트',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/border_color.png',
            width: 24,
            height: 24,
            color: currentIndex == 2 ? Color(0xFF7958FF) : Colors.black,
          ),
          label: '분석',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/workspace_premium.png',
            width: 24,
            height: 24,
            color: currentIndex == 3 ? Color(0xFF7958FF) : Colors.black,
          ),
          label: '혜택',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/person.png',
            width: 24,
            height: 24,
            color: currentIndex == 4 ? Color(0xFF7958FF) : Colors.black,
          ),
          label: '프로필',
        ),
      ],
    );
  }
}