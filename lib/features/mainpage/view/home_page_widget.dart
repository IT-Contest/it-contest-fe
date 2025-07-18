import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/daily_quest_list.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/onboarding_intro_card.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/party_and_friends_section.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/quest_alert_section.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/user_profile_card.dart';
import 'package:it_contest_fe/features/mainpage/viewmodel/mainpage_viewmodel.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<MainPageViewModel>();
      await vm.loadMainQuests();
      await vm.loadUserInfo(); // ✅ 프로필 + 퀘스트 카운트 정보 로드
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainPageViewModel>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3FAFF),
              Color(0xFFEEEBFF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ 온보딩 카드 조건부 렌더링
              if (vm.shouldShowOnboardingCard)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: OnboardingIntroCard(
                    onStart: () {
                      Navigator.pushNamed(context, '/onboarding');
                    },
                    onClose: () {
                      vm.closeOnboardingCard();
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // ✅ 유저 정보 및 퀘스트 알림
              Consumer<MainPageViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.user == null) return const SizedBox.shrink();

                  return Column(
                    children: [
                      UserProfileCard(user: viewModel.user!),
                      const SizedBox(height: 16),
                      QuestAlertSection(
                        dailyCount: viewModel.user!.dailyCount,
                        weeklyCount: viewModel.user!.weeklyCount,
                        monthlyCount: viewModel.user!.monthlyCount,
                        yearlyCount: viewModel.user!.yearlyCount,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),
              const DailyQuestList(),
              const SizedBox(height: 16),
              const PartyAndFriendsSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}