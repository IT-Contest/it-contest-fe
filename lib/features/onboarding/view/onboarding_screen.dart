import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:it_contest_fe/features/onboarding/view/widgets/custom_date_picker.dart';
import 'package:it_contest_fe/features/onboarding/view/widgets/time_range_picker.dart';
import 'package:it_contest_fe/features/onboarding/view/widgets/invite_bottom_sheet.dart';
import 'package:it_contest_fe/features/onboarding/view/widgets/date_time_section.dart';
import 'package:it_contest_fe/features/onboarding/service/onboarding_service.dart';
import 'package:it_contest_fe/features/quest/service/quest_service.dart';
import 'package:it_contest_fe/features/quest/model/quest_create_request.dart';
import 'package:provider/provider.dart';
import 'package:it_contest_fe/features/onboarding/viewmodel/onboarding_viewmodel.dart';
import '../../../shared/widgets/custom_app_bar.dart';

/// 온보딩 화면: 퀘스트 생성 및 설정 UI
// Wrap the app with MaterialApp and provide localization
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', ''),
      ],
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: const _OnboardingScreenBody(),
    );
  }
}

class _OnboardingScreenBody extends StatelessWidget {
  const _OnboardingScreenBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 메인화면과 동일하게 헤더바 아래 구분선은 CustomAppBar에서 처리
          // 본문 영역 (스크롤 가능)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  _buildTitleSection(),
                  const SizedBox(height: 16),
                  _QuestNameInput(onChanged: vm.setQuestName),
                  const SizedBox(height: 16),
                  _PrioritySection(onChanged: vm.setPriority),
                  const SizedBox(height: 16),
                  _CategoryInput(onChanged: vm.setHashtags),
                  const SizedBox(height: 16),
                  DateTimeSection(
                    onStartDateChanged: vm.setStartDate,
                    onDueDateChanged: vm.setDueDate,
                    onStartTimeChanged: vm.setStartTime,
                    onEndTimeChanged: vm.setEndTime,
                  ),
                  const SizedBox(height: 16),
                  _buildInviteSection(context),
                  const SizedBox(height: 16),
                  _buildCreateButton(context, vm),
                  const SizedBox(height: 32),
                  _buildAdBanner(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 타이틀 영역: 퀘스트 생성 안내 및 보상 정보 (디자인 반영)
  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF7D4CFF), width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            "퀘스트를 만들어볼까요?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              text: "완료시 ",
              style: TextStyle(fontSize: 18, color: Colors.grey),
              children: [
                TextSpan(
                  text: "0,000exp",
                  style: TextStyle(
                    color: Color(0xFF7D4CFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: " 지급"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 파티원 초대 영역
  Widget _buildInviteSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "파티원 초대",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF7D4CFF), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("파티원 초대 TIP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7D4CFF))),
              SizedBox(height: 8),
              Text("친구를 초대하고 파티를 맺어 계획을 진행하면", style: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B))),
              SizedBox(height: 2),
              Text.rich(TextSpan(children: [
                TextSpan(text: "더 많은 리워드", style: TextStyle(color: Color(0xFF7D4CFF), fontWeight: FontWeight.bold, fontSize: 13)),
                TextSpan(text: "를 얻을 수 있어요!", style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 13)),
              ])),
              SizedBox(height: 2),
              Text.rich(TextSpan(children: [
                TextSpan(text: "파티원 초대시 ", style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 13)),
                TextSpan(text: "000exp", style: TextStyle(color: Color(0xFF7D4CFF), fontWeight: FontWeight.bold, fontSize: 13)),
                TextSpan(text: " 추가 지급", style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 13)),
              ])),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            showInviteBottomSheet(context);
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF9F9F9F)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
          ),
          child: const Text('파티 초대하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF9F9F9F))),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 시작하기 버튼
  Widget _buildCreateButton(BuildContext context, OnboardingViewModel vm) {
    return ElevatedButton.icon(
      onPressed: vm.isLoading
          ? null
          : () async {
              final success = await vm.createQuest();
              if (success) {
                Navigator.pushReplacementNamed(context, '/main');
              } else if (vm.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(vm.errorMessage!)),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7958FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
      ),
      label: vm.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : const Text(
              "퀘스트 플래너 시작하기",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return " ${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // 광고 배너 영역
  Widget _buildAdBanner() {
    return Container(
      height: 120,
      color: Colors.grey.shade400,
      child: const Center(child: Text("광고 영역")),
    );
  }
}

String periodKorToEng(String period) {
  switch (period) {
    case "일일":
      return "DAILY";
    case "주간":
      return "WEEKLY";
    case "월간":
      return "MONTHLY";
    case "연간":
      return "YEARLY";
    default:
      return "DAILY";
  }
}

class _PrioritySection extends StatefulWidget {
  const _PrioritySection({Key? key, required this.onChanged}) : super(key: key);
  final ValueChanged<int> onChanged;

  @override
  State<_PrioritySection> createState() => _PrioritySectionState();
}

class _PrioritySectionState extends State<_PrioritySection> {
  String? selectedPeriod;
  final TextEditingController _priorityController = TextEditingController();

  @override
  void dispose() {
    _priorityController.dispose();
    super.dispose();
  }

  void _handlePriorityChange(String value) {
    final intVal = int.tryParse(value);
    if (intVal != null) {
      widget.onChanged(intVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<OnboardingViewModel>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "우선순위",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF7D4CFF), width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tipTitle("우선순위 TIP"),
                const SizedBox(height: 12),
                tipLine([gray("퀘스트는 "), purple("구체적으로 작성"), gray("해서 실천해보세요!")]),
                tipLine([gray("ex. 책읽기 "), red("(X)"), gray(" → OO책 100페이지까지 읽기 "), blue("(O)")]),
                tipLine([gray("우선 순위는 숫자로 1부터 5까지 넣을 수 있어요.")]),
                tipLine([gray("숫자가 작을수록 우선 순위가 높습니다.")]),
                tipLine([gray("분류를 지정해서 어떤 종류의 계획인지 정리해보세요!")]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _priorityController,
          decoration: InputDecoration(
            hintText: "숫자를 직접 입력해 주세요",
            hintStyle: const TextStyle(color: Color(0xFFB7B7B7), fontSize: 14),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFB7B7B7)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFB7B7B7)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFF7D4CFF), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          keyboardType: TextInputType.number,
          onChanged: _handlePriorityChange,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PeriodChip(
              label: "일일",
              isSelected: selectedPeriod == "일일",
              onTap: () {
                setState(() => selectedPeriod = "일일");
                vm.setQuestType(periodKorToEng("일일"));
              },
            ),
            _PeriodChip(
              label: "주간",
              isSelected: selectedPeriod == "주간",
              onTap: () {
                setState(() => selectedPeriod = "주간");
                vm.setQuestType(periodKorToEng("주간"));
              },
            ),
            _PeriodChip(
              label: "월간",
              isSelected: selectedPeriod == "월간",
              onTap: () {
                setState(() => selectedPeriod = "월간");
                vm.setQuestType(periodKorToEng("월간"));
              },
            ),
            _PeriodChip(
              label: "연간",
              isSelected: selectedPeriod == "연간",
              onTap: () {
                setState(() => selectedPeriod = "연간");
                vm.setQuestType(periodKorToEng("연간"));
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _QuestNameInput extends StatefulWidget {
  const _QuestNameInput({Key? key, required this.onChanged}) : super(key: key);
  final ValueChanged<String> onChanged;

  @override
  State<_QuestNameInput> createState() => _QuestNameInputState();
}

class _QuestNameInputState extends State<_QuestNameInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isOverLimit = false;

  final OutlineInputBorder commonBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Color(0xFFB7B7B7)), // Gray/300
  );

  void _handleInputChange(String value) {
    setState(() {
      _isOverLimit = value.length > 100;
    });
    widget.onChanged(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "퀘스트명",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          onChanged: _handleInputChange,
          decoration: InputDecoration(
            hintText: "퀘스트명을 입력해 주세요 (최대 100자 이내)",
            hintStyle: const TextStyle(color: Color(0xFFB7B7B7), fontSize: 14), // Gray/300
            border: commonBorder,
            enabledBorder: commonBorder,
            focusedBorder: commonBorder.copyWith(
              borderSide: const BorderSide(color: Color(0xFF7D4CFF), width: 2), // Primary/600
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (_isOverLimit)
          const Text(
            "퀘스트명이 100자 이상입니다.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }
}

Widget tipTitle(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0xFF7D4CFF),
    ),
  );
}

Widget tipLine(List<InlineSpan> children) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)), // 그레이/600
        children: children,
      ),
    ),
  );
}

InlineSpan gray(String text) {
  return TextSpan(text: text, style: const TextStyle(color: Color(0xFF6B6B6B)));
}

InlineSpan purple(String text) {
  return TextSpan(text: text, style: const TextStyle(color: Color(0xFF7D4CFF), fontWeight: FontWeight.bold));
}

InlineSpan red(String text) {
  return TextSpan(text: text, style: const TextStyle(color: Colors.red));
}

InlineSpan blue(String text) {
  return TextSpan(text: text, style: const TextStyle(color: Colors.blue)); 
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: isSelected ? const Color(0xFF6B3FFF) : const Color(0xFFB7B7B7),
            side: BorderSide(color: isSelected ? const Color(0xFF6B3FFF) : const Color(0xFFB7B7B7)),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onTap,
          child: Text(label),
        ),
      ),
    );
  }
}

class _CategoryInput extends StatefulWidget {
  const _CategoryInput({Key? key, required this.onChanged}) : super(key: key);
  final ValueChanged<List<String>> onChanged;

  @override
  State<_CategoryInput> createState() => _CategoryInputState();
}

class _CategoryInputState extends State<_CategoryInput> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _categories = [];

  void _notifyParent() {
    widget.onChanged(List<String>.from(_categories));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "카테고리 분류",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onSubmitted: (value) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty && !_categories.contains(trimmed)) {
              setState(() {
                _categories.add(trimmed);
                _controller.clear();
              });
              _notifyParent();
            }
          },
          decoration: InputDecoration(
            hintText: "카테고리를 직접 입력해 주세요",
            hintStyle: const TextStyle(color: Color(0xFFB7B7B7), fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFB7B7B7)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFB7B7B7)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFF7D4CFF), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._categories.map((category) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF643EFF)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("#$category", style: const TextStyle(color: Color(0xFF643EFF))),
              );
            }).toList(),
            if (_categories.isNotEmpty)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF643EFF),
                  side: const BorderSide(color: Color(0xFF643EFF)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  visualDensity: VisualDensity(vertical: -2),
                ),
                onPressed: () {
                  setState(() => _categories.removeLast());
                  _notifyParent();
                },
                child: const Text("삭제하기", style: TextStyle(fontSize: 14, color: Color(0xFF643EFF))),
              ),
          ],
        ),
      ],
    );
  }
}