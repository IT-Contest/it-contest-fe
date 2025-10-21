import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/quest/view/widgets/pomodoro_full_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'dart:math' as math;
import '../../../../shared/analytics/service/analytics_service.dart';
import '../../../../shared/widgets/reward_tag.dart';
import '../../../profile/service/notification_service.dart';
import '../../viewmodel/quest_pomodoro_viewmodel.dart';
import '../../../mainpage/viewmodel/mainpage_viewmodel.dart';

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

    // Analytics 이벤트 기록
    AnalyticsService.logPomodoroCycleCompleted();

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

    // 타이머 진행률 계산 (ViewModel의 total 기준)
    final totalSeconds = vm.total.inSeconds.toDouble();
    final remainingSeconds = vm.remaining.inSeconds.toDouble();
    // 남은 시간 기준 진행률: 1.0(시작) → 0.0(끝)로 감소
    final progress = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);

    return Column(
      children: [
        // 타이틀/집중모드 바깥으로 분리
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '뽀모도로 타이머',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF4C1FFF),
                ),
              ),
              Row(
                children: [
                  Image.asset('assets/icons/timer.png', width: 28, height: 28),
                  const SizedBox(width: 6),
                  Text(
                    vm.mode == PomodoroMode.focus ? '집중 모드' : '휴식 모드',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF7958FF),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // 원형 타이머
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 내부 흰색 원 (먼저 그리기)
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PomodoroFullScreen()),
                            );
                          },
                          icon: Image.asset(
                            "assets/icons/full.png",
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ],
                    ),

                    // 시간 표시
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
                    // 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: !vm.isRunning
                              ? (vm.mode == PomodoroMode.focus ? vm.startFocus : () => vm.startRest(playSound: true))
                              : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7958FF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            onPressed: vm.isRunning ? () => _showStopConfirmDialog(context) : null,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF7958FF), width: 1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              // 그라데이션 진행률 원 (흰색 원 위에 그리기)
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
            children: [
              // TIP 제목
              const Text(
                '뽀모도로 타이머 TIP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7958FF),
                ),
              ),
              const SizedBox(height: 12),

              // 집중 보상 (밑으로 이동)
              Row(
                children: const [
                  Text(
                    '집중 보상',
                    style: TextStyle(
                      color: Colors.black, // 보라색 → 검정색
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 16),
                  RewardTag(label: '경험치 +5'), // 백엔드와 맞춤
                ],
              ),
              const SizedBox(height: 8),

              // 설명 텍스트
              const Text(
                '뽀모도로 기본은 25분 집중하고 5분 휴식을 진행하는 방법입니다! 더 많은 뽀모도로 사이클을 완료할수록 그만큼 많은 보상이 지급됩니다! 그럼 화이팅!🔥',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// 그라데이션 진행률을 그리는 CustomPainter
class GradientProgressPainter extends CustomPainter {
  final double progress;
  final Gradient gradient;
  final double strokeWidth;

  GradientProgressPainter({
    required this.progress,
    required this.gradient,
    this.strokeWidth = 36.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 배경 트랙(옅은 보라) 그리기
    final bgPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    // 진행 트랙(그라데이션)
    final fgPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 전체 배경 링(0~360도)
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi,
      false,
      bgPaint,
    );

    // 진행 링: progress=1.0이면 가득, 0.0이면 0
    final sweep = (progress.clamp(0.0, 1.0)) * 2 * math.pi;
    if (sweep > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        -sweep,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! GradientProgressPainter) return true;
    // 진행률 차이가 0.001 이상일 때만 리페인트 (성능 최적화)
    return (progress - oldDelegate.progress).abs() > 0.001;
  }
}

// 정지 확인 모달 다이얼로그
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
    // 다이얼로그 뜨자마자 푸시 발송 (사용자 설정 확인 포함)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();

      final pomodoroEnabled = prefs.getBool('pomodoroNotification') ?? true;
      final vibrationEnabled = prefs.getBool('vibration') ?? false; // ✅ 진동 설정

      if (pomodoroEnabled) {
        await NotificationService.showPomodoroComplete();
        print('[CycleCompleteDialog] Pomodoro completion push sent');
      }

      // 진동이 켜져 있으면 사이클 완료 시 진동 울리기
      if (vibrationEnabled) {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 2000); // 2초 진동
          print('📳 [CycleCompleteDialog] Vibration triggered');
        }
      }
    });


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
            const Text(
              '뽀모도로 사이클을 완료했습니다!',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final vm = Provider.of<QuestPomodoroViewModel>(context, listen: false);
                  Navigator.of(context).pop();

                  // 👉 이제 이 시점에서는 알림을 보내지 않음
                  // 단순히 다음 사이클 시작만 함
                  vm.startFocus();

                  // 메인페이지 유저 정보 새로고침
                  try {
                    final mainPageViewModel = Provider.of<MainPageViewModel>(context, listen: false);
                    await mainPageViewModel.refreshUserInfo();
                  } catch (e) {
                    print('❌ [CycleComplete] refresh failed: $e');
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

                  // 🔔 알림 설정
                  const Text(
                    "알림 설정",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF643EFF),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔊 알림음 듣기
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
                          width: 40,
                          height: 24,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: vm.alarmSound
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
                            alignment: vm.alarmSound
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 12,
                              height: 12,
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

                  // 📳 진동으로 알림 받기
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

                  // ⏱ 타이머 시간 변경
                  const Text(
                    "타이머 시간 변경",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF643EFF),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("집중"),
                      DropdownButton<int>(
                        value: vm.focusTotal.inMinutes,
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black),
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

                  // ✅ 완료 / 취소 버튼
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7958FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("완료", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF7958FF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("취소", style: TextStyle(color: Color(0xFF7958FF))),
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