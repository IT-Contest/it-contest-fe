import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color iconColor;
  final double height;
  final EdgeInsetsGeometry padding;

  const CustomAppBar({
    Key? key,
    this.iconColor = const Color(0xFF7958FF),
    this.height = 70,
    this.padding = const EdgeInsets.symmetric(horizontal: 28),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Container(
          height: height,
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.menu, color: iconColor),
              Image.asset('assets/images/logo.png', height: 40),
              Icon(Icons.notifications_none, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}