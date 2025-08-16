import 'package:flutter/material.dart';

class OnboardingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color iconColor;
  final double height;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onBack;

  const OnboardingAppBar({
    Key? key,
    this.iconColor = const Color(0xFF7958FF),
    this.height = 80,
    this.padding = const EdgeInsets.symmetric(horizontal: 28),
    this.onBack,
  }) : super(key: key);

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
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: iconColor),
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Image.asset('assets/images/logo.jpg', height: 40),
                    ),
                  ),
                  SizedBox(width: 48), // 오른쪽 공간 맞춤(알림 등 없음)
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
