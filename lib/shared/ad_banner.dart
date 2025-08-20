import 'package:flutter/material.dart';

import '../features/quest/service/admob_service.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BottomBannerAd(
        kind: BannerKind.mrec300x250,      // ✅ 300x250
        margin: EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}