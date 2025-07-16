import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/mainpage/view/analysis_page_widget.dart';
import 'package:it_contest_fe/features/mainpage/view/benefit_page_widget.dart';
import 'package:it_contest_fe/features/mainpage/view/home_page_widget.dart';
import 'package:it_contest_fe/features/mainpage/view/profile_page_widget.dart';
import 'package:it_contest_fe/features/mainpage/view/quest_page_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

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
          Container(height: 1, color: Colors.grey),

          // 아래 본문
          Expanded(child: _buildPageContent()),
        ],
      ),
    );
  }

  Widget _buildPageContent() {
    // 추후 페이지마다 분기
    switch (_selectedIndex) {
      case 0:
        return HomePageWidget();
      case 1:
        return QuestPageWidget();
      case 2:
        return AnalysisPageWidget();
      case 3:
        return BenefitPageWidget();
      case 4:
        return ProfilePageWidget();
      default:
        return Placeholder();
    }
  }
}
