// lib/features/quest/service/admob_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 배너 크기 유형
enum BannerKind {
  adaptive,          // 기기 폭에 맞춰 높이 자동(권장)
  banner320x50,      // 고정 320x50
  large320x100,      // 고정 320x100
  mrec300x250,       // 고정 300x250 (보통 본문 중간 삽입용)
}

/// 테스트/운영용 배너 단위 ID
class AdIds {
  /// 배포 시 실제 Ad Unit ID로 교체하세요.
  static String get banner {
    if (Platform.isAndroid) return 'ca-app-pub-9177834780185912/8770459691'; // Android 테스트 배너
    if (Platform.isIOS)     return 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 배너
    throw UnsupportedError('Unsupported platform');
  }
}

/// 하단 고정 배너 등 어디든 붙여서 쓸 수 있는 배너 위젯
class BottomBannerAd extends StatefulWidget {
  const BottomBannerAd({
    super.key,
    this.kind = BannerKind.adaptive,
    this.overrideUnitId, // 필요 시 특정 광고 단위 ID로 덮어쓰기
    this.margin,
  });

  final BannerKind kind;
  final String? overrideUnitId;
  final EdgeInsetsGeometry? margin;

  @override
  State<BottomBannerAd> createState() => _BottomBannerAdState();
}

class _BottomBannerAdState extends State<BottomBannerAd> {
  BannerAd? _bannerAd;
  AdSize? _adSize;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (_isLoaded || _bannerAd != null) return;

    // 1) 배너 사이즈 결정
    switch (widget.kind) {
      case BannerKind.adaptive:
        final width = MediaQuery.of(context).size.width.truncate();
        final adaptive = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
        _adSize = adaptive ?? AdSize.banner; // 실패 시 320x50로 폴백
        break;
      case BannerKind.banner320x50:
        _adSize = AdSize.banner;
        break;
      case BannerKind.large320x100:
        _adSize = AdSize.largeBanner;
        break;
      case BannerKind.mrec300x250:
        _adSize = AdSize.mediumRectangle;
        break;
    }

    // 2) 배너 생성 & 로드
    final ad = BannerAd(
      size: _adSize!,
      adUnitId: widget.overrideUnitId ?? AdIds.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => mounted ? setState(() => _isLoaded = true) : null,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _bannerAd = null;
            });
          }
          // 개발 중 원인 파악용 로그
          // debugPrint('Ad failed to load: $error');
        },
      ),
    );

    await ad.load();
    if (!mounted) {
      ad.dispose();
      return;
    }
    setState(() => _bannerAd = ad);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null || _adSize == null) {
      // 로딩 실패/중엔 레이아웃을 어지럽히지 않도록 공간을 안 차지함
      return const SizedBox.shrink();
    }

    final w = _adSize!.width.toDouble();
    final h = _adSize!.height.toDouble();

    return Container(
      margin: widget.margin,
      width: w,
      height: h,
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
