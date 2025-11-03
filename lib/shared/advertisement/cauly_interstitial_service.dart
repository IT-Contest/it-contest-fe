// lib/shared/advertisement/cauly_interstitial_service.dart

import 'package:flutter/material.dart';
import 'package:it_contest_fe/shared/advertisement/cauly_mobile_ads.dart';

class CaulyInterstitialService {
  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;

  static void loadAd() {
    if (_isLoading) return;
    _isLoading = true;

    InterstitialAd.load(
      adInfo: const AdInfo(
        'CAULY', // ⚠️ 테스트 시 'CAULY' / 실제 배포 시 App Code로 교체
        BannerHeightEnum.adaptive,
        320,
        50,
      ),
      adLoadCallback: InterstitialAdLoadCallback(
        onReceiveInterstitialAd: (ad) {
          debugPrint('✅ [Cauly] Interstitial loaded');
          _interstitialAd = ad;
          _isLoading = false;
        },
        onFailedToReceiveInterstitialAd: (errorCode, errorMessage) {
          debugPrint('❌ [Cauly] Interstitial load failed: $errorMessage');
          _isLoading = false;
          _interstitialAd = null;
        },
        onClosedInterstitialAd: (ad) {
          debugPrint('🧩 [Cauly] Interstitial closed');
          _interstitialAd = null;
          loadAd(); // 다음 광고 미리 로드
        },
      ),
    );
  }

  static void showAd({VoidCallback? onClosed}) {
    if (_interstitialAd != null) {
      _interstitialAd!.show().then((_) {
        _interstitialAd = null;
        loadAd(); // 다음 광고 미리 로드
        if (onClosed != null) onClosed();
      });
    } else {
      debugPrint('⚠️ [Cauly] Interstitial not ready');
      loadAd(); // 미리 로드 시도
      if (onClosed != null) onClosed(); // 광고가 없을 때도 안전하게 콜백
    }
  }
}
