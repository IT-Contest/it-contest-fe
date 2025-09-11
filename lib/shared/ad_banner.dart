import 'package:flutter/material.dart';
import '../features/quest/service/admob_service.dart';

class AdBanner extends StatelessWidget {
  final BannerKind kind; // 원하는 배너 종류를 선택할 수 있음
  final EdgeInsetsGeometry? margin;

  const AdBanner({
    super.key,
    this.kind = BannerKind.mrec300x250,  // 기본값은 300x250
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BottomBannerAd(
        kind: kind,
        margin: margin ?? const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
