// lib/features/quest/service/interstitial_ad_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart'; // ✅ VoidCallback
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdService {
  static InterstitialAd? _interstitialAd;

  static void loadAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // ✅ 테스트 ID (Android)
          : 'ca-app-pub-3940256099942544/4411468910', // ✅ 테스트 ID (iOS)
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showAd({VoidCallback? onClosed}) {
    if (_interstitialAd == null) {
      onClosed?.call();
      loadAd(); // 다음 광고 미리 로드
      return;
    }

    _interstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _interstitialAd = null;
            loadAd(); // 다음 광고 미리 로드
            onClosed?.call();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _interstitialAd = null;
            loadAd();
            onClosed?.call();
          },
        );

    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
