import 'package:flutter/material.dart';
import 'package:it_contest_fe/shared/widgets/bottom_nav_bar.dart';

import '../features/mainpage/view/analysis_page_widget.dart';
import '../features/mainpage/view/benefit_page_widget.dart';
import '../features/mainpage/view/home_page_widget.dart';
import '../features/mainpage/view/profile_page_widget.dart';
import '../features/quest/view/quest_screen.dart';
import '../features/mainpage/view/main_screen.dart'; // Added import for MainScreen

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
      // HomePageWidget이 정의되어 있지 않아 오류 발생 중
      // const HomePageWidget(),
      const MainScreen(), // 실제 홈 역할을 하는 MainScreen으로 변경
      const QuestScreen(),
      const AnalysisPageWidget(),   // 분석
      const BenefitPageWidget(),    // 혜택
      const ProfilePageWidget(),    // 프로필
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