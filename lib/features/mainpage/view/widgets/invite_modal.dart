import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/invite_viewmodel.dart';


class InviteModal {
  static void show(BuildContext context) {
    final inviteViewModel = Provider.of<InviteViewModel>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      '친구 초대하기',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InviteOption(
                    iconPath: 'assets/icons/kakao_logo.png',
                    label: '카카오톡',
                    onTap: () => inviteViewModel.shareToKakao(context),
                  ),
                  InviteOption(
                    iconPath: 'assets/icons/link_icon.png',
                    label: '링크복사',
                    onTap: () => inviteViewModel.copyLink(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class InviteOption extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const InviteOption({
    required this.iconPath,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: Center(
              child: Image.asset(iconPath, width: 64, height: 64),
            ),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
