import 'package:flutter/material.dart';
import 'package:it_contest_fe/shared/widgets/custom_app_bar.dart';
import '../../benefit/view/coupon_list_page.dart';

class BenefitPageWidget extends StatelessWidget {
  final bool isEnabled; // true = 운영모드, false = 비활성화 모드
  const BenefitPageWidget({super.key, this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          // ✅ 기존 운영 모드 UI
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF3FAFF), Color(0xFFEEEBFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "현재 보유 골드",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7958FF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side:
                      const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border:
                              Border.all(color: Color(0xFF7958FF), width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              'assets/icons/gold_icon.png',
                              width: 28,
                              height: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "보유 골드",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "10,000G",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7958FF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "기프티콘",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7958FF),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CouponListPage()),
                          );
                        },
                        child: Row(
                          children: const [
                            Text("전체보기",
                                style: TextStyle(color: Colors.grey)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios,
                                size: 14, color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Image.asset(
                            'assets/images/compose_coffee.png',
                            width: 40,
                          ),
                          title: const Text(
                            "[브랜드] 커피커피커피커피",
                            style: TextStyle(color: Colors.black),
                          ),
                          subtitle: const Text(
                            "4,500G",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7958FF),
                            ),
                          ),
                          onTap: () {
                            // ✅ 여기서 다이얼로그 실행
                            CouponDialogs.showDetailDialog(context);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ✅ 비활성화 모드 오버레이
          if (!isEnabled)
            Container(
              color: Colors.black.withOpacity(0.3), // 반투명 배경
              child: Center(
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16), // 좌우 살짝 여백
                  child: SizedBox(
                    width: double.infinity,   // ✅ 가로 전체
                    height: 200,              // ✅ 세로 크게 (원하는 값으로 조정 가능)
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.lock_outline,
                          color: Color(0xFF7958FF),
                          size: 60, // 아이콘도 조금 크게
                        ),
                        SizedBox(height: 24),
                        Text(
                          "현재 준비 중입니다.\n기대해주세요!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18, // 글씨도 조금 키움
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class CouponDialogs {

  // 1단계: 쿠폰 상세
  static void showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/compose_coffee.png', width: 120, height: 120),
              const SizedBox(height: 16),
              const Text(
                "기프티콘 정보 기프티콘 정보 기프티콘",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // ✅ 버튼 Row로 수정
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7958FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showConfirmDialog(context);
                      },
                      child: const Text("구매"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7958FF),
                        side: const BorderSide(color: Color(0xFF7958FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("닫기"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 2단계: 구매 확인
  static void showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "정말 해당 기프티콘을 구매하시겠습니까?\n구매 후 환불은 불가합니다.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "구매 버튼을 누르시면 0,000 골드가 차감됩니다.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // ✅ 버튼 Row (구매 / 닫기 나란히)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7958FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showCompleteDialog(context); // 3단계 열기
                      },
                      child: const Text("구매"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7958FF),
                        side: const BorderSide(color: Color(0xFF7958FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("닫기"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 3단계: 구매 완료
  static void showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ 파란색 체크 아이콘
              const Icon(
                Icons.check_circle,
                color: Colors.blue, // 파란색
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                "구매가 완료되었습니다.",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),

              // ✅ 버튼들
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7958FF), // 보라색 배경
                  foregroundColor: Colors.white,            // 흰색 글씨
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text("카카오톡으로 받기"),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7958FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text("휴대폰 문자로 받기"),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7958FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text("휴대폰에 저장하기"),
              ),
            ],
          ),
        );
      },
    );
  }
}