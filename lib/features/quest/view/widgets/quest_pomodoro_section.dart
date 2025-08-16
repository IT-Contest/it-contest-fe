import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/quest_pomodoro_viewmodel.dart';

class QuestPomodoroSection extends StatelessWidget {
  const QuestPomodoroSection({Key? key}) : super(key: key);

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuestPomodoroViewModel>(context);
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
                  fontSize: 24,
                  color: Color(0xFF4C1FFF),
                ),
              ),
              Row(
                children: [
                  Image.asset('assets/icons/timer.png', width: 28, height: 28),
                  const SizedBox(width: 6),
                  const Text(
                    '집중 모드',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF7958FF),
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFD9CFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF7958FF), width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            children: [
              Text(
                _formatDuration(vm.remaining),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4C1FFF),
                  letterSpacing: -0.56, // -2% of 28px
                  height: 30/28, // 30px line height
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (vm.mode == PomodoroMode.focus && !vm.isRunning)
                          ? vm.startFocus
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
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: vm.isRunning ? vm.stop : null,
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
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  if (vm.restButtonEnabled) ...[
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 100,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: vm.startRest,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF7958FF), width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          '5분 타이머',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF7958FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
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