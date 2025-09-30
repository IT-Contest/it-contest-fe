import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'package:it_contest_fe/features/mainpage/view/widgets/onboarding_intro_card.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/party_and_friends_section.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/quest_alert_section.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/user_profile_card.dart';
import 'package:it_contest_fe/features/mainpage/viewmodel/mainpage_viewmodel.dart';

import '../../../features/quest/service/party_service.dart';
import '../../../shared/alarm/widgets/party_invitation_card.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final PartyService _partyService = PartyService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<MainPageViewModel>();
      await vm.loadMainQuests();
      await vm.loadUserInfo(); // 프로필 + 퀘스트 카운트 정보 로드

      // ✅ 가장 최근 파티 초대장 확인
      await _checkLatestPartyInvitation();
    });
  }

  Future<void> _checkLatestPartyInvitation() async {
    final token = await const FlutterSecureStorage().read(key: "accessToken");
    if (token == null) return;

    final invitations = await _partyService.fetchInvitedParties(token);

    if (invitations.isNotEmpty) {
      // 최신순 정렬 (createdAt 필드가 있다고 가정)
      invitations.sort((a, b) {
        final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate); // 최신순
      });

      final latestInvitation = invitations.first;

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Align(
            alignment: Alignment.topCenter, // ✅ 상단에 붙이기 (원하면 center로)
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity, // ✅ 가로를 꽉 채움
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: SingleChildScrollView( // ✅ 스크롤 가능하게
                  child: PartyInvitationCard(
                    partyData: latestInvitation,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
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
              const SizedBox(height: 16),

              // ✅ 온보딩 카드
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

              // ✅ 유저 프로필 + 퀘스트 알림
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

              // ✅ 파티 & 친구 섹션
              const PartyAndFriendsSection(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
