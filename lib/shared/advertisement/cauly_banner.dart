import 'package:flutter/material.dart';
import 'package:it_contest_fe/shared/advertisement/cauly_mobile_ads.dart';

/// ✅ 배너 종류 (Cauly 지원 크기)
enum CaulyBannerKind {
  banner320x50,
  banner320x100,
  banner300x250,
}

/// ✅ Cauly 배너 광고 위젯
class CaulyBannerAd extends StatefulWidget {
  final CaulyBannerKind kind;

  const CaulyBannerAd({
    super.key,
    this.kind = CaulyBannerKind.banner320x50, // 기본값
  });

  @override
  State<CaulyBannerAd> createState() => _CaulyBannerAdState();
}

class _CaulyBannerAdState extends State<CaulyBannerAd> {
  BannerAd? _banner;

  @override
  void initState() {
    super.initState();
    _createBanner();
  }

  void _createBanner() {
    // 🔹 크기별 설정
    late int width;
    late int height;
    late BannerHeightEnum heightMode;

    switch (widget.kind) {
      case CaulyBannerKind.banner320x50:
        width = 320;
        height = 50;
        heightMode = BannerHeightEnum.fixed_50;
        break;
      case CaulyBannerKind.banner320x100:
        width = 320;
        height = 100;
        heightMode = BannerHeightEnum.fixed;
        break;
      case CaulyBannerKind.banner300x250:
        width = 300;
        height = 250;
        heightMode = BannerHeightEnum.fixed;
        break;
    }

    _banner = BannerAd(
      listener: BannerAdListener(
        onReceiveAd: (ad) => debugPrint('✅ Cauly banner received (${widget.kind})'),
        onFailedToReceiveAd: (ad, errorCode, errorMessage) =>
            debugPrint('❌ Cauly banner failed: $errorMessage'),
        onCloseLandingScreen: (ad) => debugPrint('🕹️ Cauly banner closed'),
        onShowLandingScreen: (ad) => debugPrint('🎯 Cauly banner clicked'),
      ),
      adInfo: AdInfo(
        'CAULY', // ✅ 실제 발급 ID
        heightMode,
        width,
        height,
      ),
    )..load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_banner == null) return const SizedBox.shrink();

    return Center(
      child: SizedBox(
        width: _banner!.adInfo.bannerSizeWidth.toDouble(),
        height: _banner!.bannerSizeHeight.toDouble(),
        child: AdWidget(ad: _banner!),
      ),
    );
  }
}
