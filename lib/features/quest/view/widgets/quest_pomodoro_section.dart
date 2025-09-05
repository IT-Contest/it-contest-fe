import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../viewmodel/quest_pomodoro_viewmodel.dart';

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
    
    // 타이머 진행률 계산 (ViewModel의 total 기준)
    final totalSeconds = vm.total.inSeconds.toDouble();
    final remainingSeconds = vm.remaining.inSeconds.toDouble();
    // 남은 시간 기준 진행률: 1.0(시작) → 0.0(끝)로 감소
    final progress = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
    
    // 집중 모드 완료 다이얼로그 표시
    if (vm.showFocusCompleteDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.showFocusCompleteDialog = false;
        _showFocusCompleteDialog(context);
      });
    }
    
    // 사이클 완료 다이얼로그 표시
    if (vm.showCycleCompleteDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.showCycleCompleteDialog = false;
        _showCycleCompleteDialog(context);
      });
    }
    
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
                    // 시간 표시
                    Text(
                      _formatDuration(vm.remaining),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4C1FFF),
                        letterSpacing: -0.56,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: !vm.isRunning 
                              ? (vm.mode == PomodoroMode.focus ? vm.startFocus : vm.startRest)
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
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 80,
                          height: 44,
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
                                fontSize: 16,
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
              Row(
                children: const [
                  Text('뽀모도로 타이머 TIP', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7958FF))),
                  Spacer(),
                  Text('집중 보상', style: TextStyle(color: Color(0xFF7958FF))),
                  SizedBox(width: 8),
                  _RewardTag(label: '경험치 +10'),
                  SizedBox(width: 4),
                  _RewardTag(label: '골드 +5', border: true),
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
      -math.pi / 2, // 12시 시작
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
        sweep,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RewardTag extends StatelessWidget {
  final String label;
  final bool border;
  const _RewardTag({required this.label, this.border = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: border ? Colors.white : const Color(0xFF7958FF),
        border: border ? Border.all(color: const Color(0xFF7958FF)) : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: border ? const Color(0xFF7958FF) : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
                onPressed: () => Navigator.of(context).pop(),
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
                    '경험치 +10',
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
                onPressed: () => Navigator.of(context).pop(),
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