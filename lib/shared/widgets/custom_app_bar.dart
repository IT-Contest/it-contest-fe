import 'package:flutter/material.dart';

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
      height: height + 1, // Divider 포함
      color: Colors.white,
      child: Stack(
        children: [
          SafeArea(
            child: Container(
              height: height,
              padding: padding,
              child: Row(
                children: [
                  const SizedBox(width: 40), // 왼쪽 공간(혹은 아이콘)
                  Expanded(
                    child: Center(
                      child: Image.asset('assets/images/logo.png', height: 40),
                    ),
                  ),
                  Icon(Icons.notifications_none, color: iconColor), // 오른쪽 아이콘
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + 1);
}