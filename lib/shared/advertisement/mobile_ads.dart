import 'dart:io';
import 'package:flutter/foundation.dart';
import 'ad_instance_manager.dart';

class MobileAds {
  MobileAds._();

  static final MobileAds _instance = MobileAds._().._init();

  static MobileAds get instance => _instance;

  void initialize() {
    // nothing
  }

  void _init() {
    if (Platform.isAndroid) {
      instanceManager.channel.invokeMethod('_init');
    }
  }
}

/// ✅ Cauly SDK 초기화용 클래스 추가
class Cauly {
  static bool _initialized = false;

  static void initialize({
    required String appCode,
    bool isTestMode = false,
  }) {
    if (_initialized) return;
    _initialized = true;

    // 실제 네이티브 초기화 메서드 호출 (Android 네이티브 브리지 예시)
    if (Platform.isAndroid) {
      instanceManager.channel.invokeMethod('initializeCauly', {
        'appCode': appCode,
        'isTestMode': isTestMode,
      });
    }

    debugPrint('✅ [Cauly] initialized (appCode=$appCode, testMode=$isTestMode)');
  }
}
