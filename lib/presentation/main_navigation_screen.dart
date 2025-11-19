import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';   // ✅ uni_links 대신 app_links

import 'package:it_contest_fe/shared/widgets/bottom_nav_bar.dart';
import '../features/analysis/view/analysis_screen.dart';
import '../features/mainpage/view/benefit_page_widget.dart';
import '../features/mainpage/view/profile_page_widget.dart';
import '../features/quest/view/quest_screen.dart';
import '../features/mainpage/view/main_screen.dart';
import '../features/mainpage/service/mainpage_service.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;
  late final List<Widget> _screens;
  StreamSubscription<Uri>? _sub;
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _screens = [
      const MainScreen(),
      const QuestScreen(),
      const AnalysisView(),
      const BenefitPageWidget(),
      const ProfilePageWidget(),
    ];

    // 딥링크 리스너 등록
    _appLinks = AppLinks();
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.scheme == 'questplanner') {
        final token = uri.queryParameters['code'];
        if (token != null) {
          try {
            await context.read<MainpageService>().acceptFriendInvite(token);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('친구 추가가 완료되었습니다!')),
              );
            }
          } catch (e) {
            debugPrint("친구 수락 API 호출 실패: $e");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('친구 초대 처리 중 오류가 발생했습니다.')),
              );
            }
          }
        }
      }
    }, onError: (err) {
      debugPrint("딥링크 에러: $err");
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
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
