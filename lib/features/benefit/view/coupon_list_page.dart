import 'package:flutter/material.dart';

class CouponListPage extends StatelessWidget {
  const CouponListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '쿠폰 선택',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey, height: 1, thickness: 1),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // ✅ 쿠폰 갯수
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
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
                // ✅ 쿠폰 선택 이벤트 처리 (필요하다면 Navigator.pop으로 값 전달 가능)
              },
            ),
          );
        },
      ),
    );
  }
}
