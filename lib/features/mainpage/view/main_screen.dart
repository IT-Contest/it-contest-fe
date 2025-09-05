import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/mainpage/view/analysis_page_widget.dart';
import 'package:it_contest_fe/features/mainpage/view/benefit_page_widget.dart';
import 'package:it_contest_fe/features/mainpage/view/home_page_widget.dart';
import 'package:it_contest_fe/features/mainpage/view/profile_page_widget.dart';
import 'package:it_contest_fe/features/mainpage/view/quest_page_widget.dart';
import 'package:it_contest_fe/shared/widgets/custom_app_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _buildPageContent(),
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
