import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/quest/view/widgets/quest_pomodoro_section.dart';
import 'package:provider/provider.dart';
import '../../../../shared/ad_banner.dart';
import '../../../../shared/widgets/reward_tag.dart';
import '../../service/admob_service.dart';
import '../../viewmodel/quest_pomodoro_viewmodel.dart';
import '../../../mainpage/viewmodel/mainpage_viewmodel.dart';

class PomodoroFullScreen extends StatelessWidget {
  const PomodoroFullScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ 배경색 그라데이션
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3FAFF), // 위쪽 색
              Color(0xFFEEEBFF), // 아래쪽 색
            ],
          ),
        ),
        child: Column(
          children: [
            // ✅ AppBar 대체 커스텀 헤더
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 40, left: 8, right: 8, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new, // ✅ Flutter 제공 <
                      color: Colors.black,
                      size: 26, // 👉 크기 조절 (24~28 권장)
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "뽀모도로 전체 화면",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 48), // 오른쪽 공간 맞추기
                ],
              ),
            ),
            // ✅ AppBar 구분선
            Container(height: 1, color: Color(0xFFB7B7B7)),

            const SizedBox(height: 16),
            // 현재 모드 표시 (동적으로 변경)
            Consumer<QuestPomodoroViewModel>(
              builder: (context, vm, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/timer.png',
                      width: 20,
                      height: 20,
                      color: const Color(0xFF7958FF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vm.mode == PomodoroMode.focus ? '집중 모드' : '휴식 모드',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF7958FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // ✅ 기존 900줄짜리 QuestPomodoroSection 불러오기
            const Expanded(child: QuestPomodoroSection()),
          ],
        ),
      ),
    );
  }
}

class QuestPomodoroSection extends StatelessWidget {
  const QuestPomodoroSection({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showStopConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return _StopConfirmDialog();
      },
    );
  }

  void _showFocusCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _FocusCompleteDialog();
      },
    );
  }

  void _showCycleCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _CycleCompleteDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuestPomodoroViewModel>(context);

    // 콜백 설정
    vm.onFocusComplete = () => _showFocusCompleteDialog(context);
    vm.onCycleComplete = () => _showCycleCompleteDialog(context);

    final totalSeconds = vm.total.inSeconds.toDouble();
    final remainingSeconds = vm.remaining.inSeconds.toDouble();
    final progress = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);

    return Column(
      children: [
        const SizedBox(height: 32),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            _showSettingsDialog(context);
                          },
                          icon: Image.asset(
                            "assets/icons/setting.png",
                            width: 32,
                            height: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context); // ✅ 축소 버튼 → 돌아가기
                          },
                          icon: Image.asset(
                            "assets/icons/before.png", // ✅ 축소 아이콘
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDuration(vm.remaining),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4C1FFF),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: !vm.isRunning
                                ? (vm.mode == PomodoroMode.focus
                                ? vm.startFocus
                                : () => vm.startRest(playSound: true))
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7958FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              '시작',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 70,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: vm.isRunning
                                ? () => _showStopConfirmDialog(context)
                                : null,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF7958FF), width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              '정지',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xFF7958FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                ignoring: true,
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: CustomPaint(
                    painter: GradientProgressPainter(
                      progress: progress,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFC4A2FF), Color(0xFF77E6FF)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF7958FF), width: 1),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '뽀모도로 타이머 TIP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7958FF),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '집중 보상',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 16),
                  RewardTag(label: '경험치 +5'),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '뽀모도로 기본은 25분 집중하고 5분 휴식을 진행하는 방법입니다! 더 많은 뽀모도로 사이클을 완료할수록 그만큼 많은 보상이 지급됩니다! 그럼 화이팅!🔥',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        const AdBanner(
          kind: BannerKind.banner300x50,
        ),
      ],
    );
  }
}

class _StopConfirmDialog extends StatelessWidget {
  const _StopConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목과 닫기 버튼
            Stack(
              children: [
                // 제목 (정확히 가운데 정렬)
                const Center(
                  child: Text(
                    '여기서 잠깐!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // X 버튼
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.black54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 안내 메시지 (좌측 정렬, 줄바꿈 없음)
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  children: [
                    const TextSpan(text: '정지하시면 이번 뽀모도로 사이클에서는 보상을 \n받으실 수 없으며, 진행 시간이 '),
                    const TextSpan(
                      text: '초기화됩니다.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '정말 정지하시겠습니까?',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 24),
            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F73FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 30),
                    ),
                    child: const Text(
                      '계속하고\n보상 얻기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // ViewModel의 stop 메서드 호출하고 타이머 초기화
                      final vm = Provider.of<QuestPomodoroViewModel>(context, listen: false);
                      vm.stop();
                      vm.resetTimer();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF8F73FF), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 30),
                    ),
                    child: const Text(
                      '정지하고\n보상 포기하기',
                      style: TextStyle(
                        color: Color(0xFF8F73FF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 집중 모드 완료 알림 다이얼로그
class _FocusCompleteDialog extends StatelessWidget {
  const _FocusCompleteDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 320,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목 (가운데 정렬)
            const Text(
              '🎉 집중 모드 완료!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4C1FFF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // 안내 메시지 (가운데 정렬)
            const Text(
              '집중 모드가 완료되었습니다!\n이제 5분 휴식 시간입니다.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // 확인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final vm = Provider.of<QuestPomodoroViewModel>(context, listen: false);
                  Navigator.of(context).pop();
                  // 휴식 타이머 자동 시작
                  vm.startRest();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7958FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '휴식 타이머 시작하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 사이클 완료 보상 다이얼로그
class _CycleCompleteDialog extends StatelessWidget {
  const _CycleCompleteDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 320,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목 (가운데 정렬)
            const Text(
              '🎊 사이클 완료!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4C1FFF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // 보상 메시지 (가운데 정렬)
            const Text(
              '뽀모도로 사이클을 완료했습니다!',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // 보상 아이콘들
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7958FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '경험치 +5',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF7958FF)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '골드 +5',
                    style: TextStyle(
                      color: Color(0xFF7958FF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 확인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final vm = Provider.of<QuestPomodoroViewModel>(context, listen: false);
                  Navigator.of(context).pop();
                  // 다음 집중 사이클 자동 시작
                  vm.startFocus();
                  
                  // 메인페이지 유저 정보 새로고침
                  try {
                    final mainPageViewModel = Provider.of<MainPageViewModel>(context, listen: false);
                    await mainPageViewModel.refreshUserInfo();
                    print('✅ [FullScreenCycleComplete] Main page user info refreshed');
                  } catch (e) {
                    print('❌ [FullScreenCycleComplete] Failed to refresh main page user info: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7958FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '다음 사이클 시작하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Consumer<QuestPomodoroViewModel>(
        builder: (context, vm, child) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "설정",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C1FFF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 알림 설정
                  const Text(
                    "알림 설정",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF643EFF),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 알림음 듣기
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("알림음 듣기"),
                      GestureDetector(
                        onTap: () {
                          vm.updateAlarmSound(!vm.alarmSound);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40, // ✅ Figma width
                          height: 24, // ✅ Figma height
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: vm.alarmSound
                                ? const Color(0xFF643EFF)
                                : Colors.white,
                            border: Border.all(
                              color: const Color(0xFF643EFF),
                              width: 1, // ✅ border 1px
                            ),
                            borderRadius: BorderRadius.circular(16), // ✅ radius 16
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 200),
                            alignment: vm.alarmSound
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 12, // ✅ circle width
                              height: 12, // ✅ circle height
                              decoration: BoxDecoration(
                                color: vm.alarmSound
                                    ? Colors.white
                                    : const Color(0xFF643EFF),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 진동으로 알림 받기
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("진동으로 알림 받기"),
                      GestureDetector(
                        onTap: () {
                          vm.updateVibration(!vm.vibration);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 24,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: vm.vibration
                                ? const Color(0xFF643EFF)
                                : Colors.white,
                            border: Border.all(
                              color: const Color(0xFF643EFF),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 200),
                            alignment: vm.vibration
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: vm.vibration
                                    ? Colors.white
                                    : const Color(0xFF643EFF),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 타이머 시간 변경
                  const Text(
                    "타이머 시간 변경",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF643EFF)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("집중"),
                      DropdownButton<int>(
                        value: vm.focusTotal.inMinutes,
                        dropdownColor: Colors.white, // ✅ 배경 흰색
                        style: const TextStyle(color: Colors.black), // ✅ 글자 검정
                        items: const [
                          DropdownMenuItem(value: 5, child: Text("5분")),
                          DropdownMenuItem(value: 10, child: Text("10분")),
                          DropdownMenuItem(value: 15, child: Text("15분")),
                          DropdownMenuItem(value: 20, child: Text("20분")),
                          DropdownMenuItem(value: 25, child: Text("25분")),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            vm.updateFocusTime(val);
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 완료 / 취소 버튼
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7958FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "완료",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF7958FF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "취소",
                            style: TextStyle(color: Color(0xFF7958FF)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
