import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/terms/view/terms_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../onboarding/view/onboarding_screen.dart';
import '../model/terms_model.dart';
import '../service/terms_service.dart';

class TermsAgreementScreen extends StatefulWidget {
  const TermsAgreementScreen({super.key});

  @override
  State<TermsAgreementScreen> createState() => _TermsAgreementScreenState();
}

class _TermsAgreementScreenState extends State<TermsAgreementScreen> {
  // 서버에서 내려온 url이 /terms/service-terms-v1.html 이런 형식일 거라고 가정
  final List<Term> _terms = [
    Term(id: 1, title: "이용 약관 동의", url: "/terms/service-terms-v1.html", required: true),
    Term(id: 2, title: "개인정보 수집 동의", url: "/terms/privacy-policy-v1.html", required: true),
  ];

  bool _isAllAgreed = false;

  void _toggleAll(bool value) {
    setState(() {
      _isAllAgreed = value;
      for (var t in _terms) {
        t.agreed = value;
      }
    });
  }

  void _toggleSingle(int index, bool value) {
    setState(() {
      _terms[index].agreed = value;
      _isAllAgreed = _terms.every((t) => t.agreed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경 흰색
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 140),
              Center(
                child: Image.asset("assets/images/logo.jpg", height: 84, width: 177),
              ),
              const SizedBox(height: 50),
              const Text.rich(
                TextSpan(
                  text: "퀘스트플래너",
                  style: TextStyle(
                    fontFamily: "Pretendard", // ✅ Pretendard 폰트 사용
                    fontWeight: FontWeight.w600, // SemiBold
                    fontSize: 20,
                    height: 1.5, // 30px line height / 20px font size = 1.5
                    color: Color(0xFF643EFF), // ✅ 보라색 (#643EFF)
                  ),
                  children: [
                    TextSpan(
                      text: " 서비스의 이용을 위한 최초 1회 약관 동의와 개인정보 수집에 대한 동의가 필요합니다.",
                      style: TextStyle(
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w600, // SemiBold
                        fontSize: 20,
                        height: 1.5,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // 전체 동의
              GestureDetector(
                onTap: () => _toggleAll(!_isAllAgreed),
                child: Row(
                  children: [
                    Icon(
                      _isAllAgreed ? Icons.check_circle : Icons.check_circle_outline,
                      size: 24,
                      color: _isAllAgreed ? const Color(0xFF643EFF) : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "약관 전체 동의하기",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 33),

              // 약관 리스트
              Expanded(
                child: ListView.builder(
                  itemCount: _terms.length,
                  itemBuilder: (context, index) {
                    final term = _terms[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleSingle(index, !term.agreed),
                            child: Icon(
                              term.agreed ? Icons.check_circle : Icons.check_circle_outline,
                              size: 24,
                              color: term.agreed ? const Color(0xFF643EFF) : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: term.required ? "(필수) " : "(선택) ",
                                    style: const TextStyle(
                                      color: Color(0xFF4C1FFF), // 보라색
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: term.title,
                                    style: const TextStyle(
                                      color: Color(0xFF888888), // 회색
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TermsDetailScreen(
                                    title: term.title,
                                    url: term.url, // 서버에서 내려온 상대 경로 전달
                                  ),
                                ),
                              );
                            },
                            child: Image.asset(
                              "assets/icons/more_btn_bgdX.png",
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 다음 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _terms.where((t) => t.required).every((t) => t.agreed)
                      ? () async {
                    final agreedTermIds = _terms
                        .where((t) => t.agreed)
                        .map((t) => t.id)
                        .toList();

                    try {
                      final termsService = TermsService();
                      await termsService.agreeTerms(agreedTermIds);

                      // ✅ 로그인 시 isNewUser 저장되어 있다고 가정
                      final prefs = await SharedPreferences.getInstance();
                      final isNewUser = prefs.getBool('isNewUser') ?? false;

                      if (isNewUser) {
                        // 🚀 신규 유저 → 온보딩 화면으로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                        );
                      } else {
                        // ✅ 기존 유저 → 메인화면으로 이동
                        Navigator.pushReplacementNamed(context, '/main');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('약관 동의 저장 실패: $e')),
                      );
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF643EFF),
                    disabledBackgroundColor: const Color(0xFFDDDDDD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("다음", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}