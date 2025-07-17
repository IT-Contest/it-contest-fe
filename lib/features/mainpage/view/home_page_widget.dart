import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Provider 사용
import 'package:it_contest_fe/features/mainpage/view/widgets/daily_quest_list.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/onboarding_intro_card.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/party_and_friends_section.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/quest_alert_section.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/user_profile_card.dart';
import 'package:it_contest_fe/features/mainpage/viewmodel/mainpage_viewmodel.dart'; // ✅ ViewModel import

class HomePageWidget extends StatelessWidget {
  const HomePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainPageViewModel>();

    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경도 흰색이면 좋음
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 상단바 부분만 흰색 배경으로 감싸줌
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.menu, color: Colors.deepPurple),
                        Image.asset('assets/images/logo.jpg', height: 40),
                        Consumer<MainPageViewModel>(
                          builder: (context, viewModel, _) {
                            return GestureDetector(
                              onTap: () => viewModel.toggleAlarm(),
                              child: Image.asset(
                                viewModel.hasAlarm
                                    ? 'assets/icons/alarm_btn2.png'
                                    : 'assets/icons/alarm_btn1.png',
                                width: 28,
                                height: 28,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.grey),
                ],
              ),
            ),

            // 👇 아래 본문 콘텐츠
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OnboardingIntroCard(
                onStart: () {
                  Navigator.pushNamed(context, '/onboarding');
                },
                onClose: () {
                  print('온보딩 카드 닫힘');
                },
              ),
            ),
            const SizedBox(height: 16),
            const UserProfileCard(),
            const SizedBox(height: 16),
            const QuestAlertSection(),
            const SizedBox(height: 16),
            const DailyQuestList(),
            const SizedBox(height: 16),
            const PartyAndFriendsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

}
