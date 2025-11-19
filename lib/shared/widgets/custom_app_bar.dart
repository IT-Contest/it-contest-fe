import 'package:flutter/material.dart';
import '../alarm/notification_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color iconColor;
  final double height;
  final EdgeInsetsGeometry padding;

  const CustomAppBar({
    super.key,
    this.iconColor = const Color(0xFF7958FF),
    this.height = 80,
    this.padding = const EdgeInsets.symmetric(horizontal: 28),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height + 1,
      color: Colors.white,
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🔹 로고를 가운데 배치
            Center(
              child: Image.asset('assets/images/logo.png', height: 40),
            ),

            // 🔹 오른쪽 끝 알림 버튼
            Positioned(
              right: 12,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const NotificationPage(hasNotifications: false),
                    ),
                  );
                },
                child: Image.asset(
                  "assets/icons/alarm_btn1.png",
                  width: 28,
                  height: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + 1);
}
