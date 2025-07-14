import 'package:it_contest_fe/features/onboarding/view/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:it_contest_fe/shared/widgets/bottom_nav_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const OnboardingScreen(),
      const Center(child: Text('홈')),
      const Center(child: Text('퀘스트')),
      const Center(child: Text('분석')),
      const Center(child: Text('혜택')),
      const Center(child: Text('프로필')),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}