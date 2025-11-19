import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ad_containers.dart';

/// Loads and disposes [BannerAds] and [InterstitialAds].
AdInstanceManager instanceManager = AdInstanceManager(
  'cauly_flutter_sdk',
);

/// Maintains access to loaded [Ad] instances and handles sending/receiving
/// messages to platform code.
class AdInstanceManager {
  AdInstanceManager(String channelName)
      : channel = MethodChannel(
    channelName,
    StandardMethodCodec(AdMessageCodec()),
  ) {
    channel.setMethodCallHandler((MethodCall call) async {
      assert(call.method == 'onAdEvent');

      final int adId = call.arguments['adId'];
      final String eventName = call.arguments['eventName'];

      final Ad? ad = adFor(adId);
      if (ad != null) {
        _onAdEvent(ad, eventName, call.arguments);
      } else {
        debugPrint('$Ad with id `$adId` is not available for $eventName.');
      }
    });
  }

  int _nextAdId = 0;
  final _BiMap<int, Ad> _loadedAds = _BiMap<int, Ad>();

  /// Invokes load and dispose calls.
  final MethodChannel channel;

  void _onAdEvent(Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _onAdEventAndroid(ad, eventName, arguments);
    } else {
      throw Exception('is not supported on $defaultTargetPlatform');
    }
  }

  void _onAdEventAndroid(
      Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
    switch (eventName) {
      case 'onReceiveAd':
        _invokeOnReceiveAd(ad, eventName, arguments);
        break;
      case 'onFailedToReceiveAd':
        _invokeOnFailedToReceiveAd(ad, eventName, arguments);
        break;
      case 'onShowLandingScreen':
        _invokeOnShowLandingScreen(ad, eventName);
        break;
      case 'onCloseLandingScreen':
        _invokeOnCloseLandingScreen(ad, eventName);
        break;
      case 'onReceiveInterstitialAd':
        _invokeOnReceiveInterstitialAd(ad, eventName, arguments);
        break;
      case 'onFailedToReceiveInterstitialAd':
        _invokeOnFailedToReceiveInterstitialAd(ad, eventName, arguments);
        break;
      case 'onClosedInterstitialAd':
        _invokeOnClosedInterstitialAd(ad, eventName);
        break;
      case 'onLeaveInterstitialAd':
        _invokeOnLeaveInterstitialAd(ad, eventName);
        break;
      default:
        debugPrint('invalid ad event name: $eventName');
    }
  }

  void _invokeOnReceiveInterstitialAd(
      Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
    if (ad is InterstitialAd) {
      ad.adLoadCallback.onReceiveInterstitialAd.call(ad);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnFailedToReceiveInterstitialAd(
      Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
    if (ad is InterstitialAd) {
      ad.dispose();
      ad.adLoadCallback.onFailedToReceiveInterstitialAd.call(arguments['errorCode'], arguments['errorMessage']);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnClosedInterstitialAd(Ad ad, String eventName) {
    if (ad is InterstitialAd) {
      ad.adLoadCallback.onClosedInterstitialAd?.call(ad);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnLeaveInterstitialAd(Ad ad, String eventName) {
    if (ad is InterstitialAd) {
      ad.adLoadCallback.onLeaveInterstitialAd?.call(ad);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnReceiveAd(
      Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
    if (ad is AdWithView) {
      ad.listener.onReceiveAd?.call(ad);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnFailedToReceiveAd(
      Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
    if (ad is AdWithView) {
      ad.listener.onFailedToReceiveAd?.call(ad, arguments['errorCode'], arguments['errorMessage']);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnShowLandingScreen(Ad ad, String eventName) {
    if (ad is AdWithView) {
      ad.listener.onShowLandingScreen?.call(ad);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnCloseLandingScreen(Ad ad, String eventName) {
    if (ad is AdWithView) {
      ad.listener.onCloseLandingScreen?.call(ad);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  /// Returns null if an invalid [adId] was passed in.
  Ad? adFor(int adId) => _loadedAds[adId];

  /// Returns null if an invalid [Ad] was passed in.
  int? adIdFor(Ad ad) => _loadedAds.inverse[ad];

  final Set<int> _mountedWidgetAdIds = <int>{};

  /// Returns true if the [adId] is already mounted in a [WidgetAd].
  bool isWidgetAdIdMounted(int adId) => _mountedWidgetAdIds.contains(adId);

  /// Indicates that [adId] is mounted in widget tree.
  void mountWidgetAdId(int adId) => _mountedWidgetAdIds.add(adId);

  /// Indicates that [adId] is unmounted from the widget tree.
  void unmountWidgetAdId(int adId) => _mountedWidgetAdIds.remove(adId);

  /// Starts loading the ad if not previously loaded.
  ///
  /// Does nothing if we have already tried to load the ad.
  Future<void> loadBannerAd(BannerAd ad) {
    if (adIdFor(ad) != null) {
      return Future<void>.value();
    }

    final int adId = _nextAdId++;
    _loadedAds[adId] = ad;
    return channel.invokeMethod<void>(
      'loadBannerAd',
      <dynamic, dynamic>{
        'adId': adId,
        'adInfo': ad.adInfo,
      },
    );
  }

  Future<void> loadInterstitialAd(InterstitialAd ad) {
    if (adIdFor(ad) != null) {
      return Future<void>.value();
    }

    final int adId = _nextAdId++;
    _loadedAds[adId] = ad;
    return channel.invokeMethod<void>(
      'loadInterstitialAd',
      <dynamic, dynamic>{
        'adId': adId,
        'adInfo': ad.adInfo,
      },
    );
  }

  /// Free the plugin resources associated with this ad.
  ///
  /// Disposing a banner ad that's been shown removes it from the screen.
  /// Interstitial ads can't be programmatically removed from view.
  Future<void> disposeAd(Ad ad) {
    final int? adId = adIdFor(ad);
    final Ad? disposedAd = _loadedAds.remove(adId);
    if (disposedAd == null) {
      return Future<void>.value();
    }
    return channel.invokeMethod<void>(
      'disposeAd',
      <dynamic, dynamic>{
        'adId': adId,
      },
    );
  }

  /// Display an [AdWithoutView] that is overlaid on top of the application.
  Future<void> showAdWithoutView(AdWithoutView ad) {
    assert(
    adIdFor(ad) != null,
    '$Ad has not been loaded or has already been disposed.',
    );

    return channel.invokeMethod<void>(
      'showAdWithoutView',
      <dynamic, dynamic>{
        'adId': adIdFor(ad),
      },
    );
  }
}

@visibleForTesting
class AdMessageCodec extends StandardMessageCodec {
  // The type values below must be consistent for each platform.
  static const int _valueAdRequest = 129;

  @override
  void writeValue(WriteBuffer buffer, dynamic value) {
    if (value is AdInfo) {
      buffer.putUint8(_valueAdRequest);
      writeValue(buffer, value.appCode);
      writeValue(buffer, value.bannerHeight.name4Java);
      writeValue(buffer, value.bannerSizeWidth);
      writeValue(buffer, value.bannerSizeHeight);
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  dynamic readValueOfType(dynamic type, ReadBuffer buffer) {
    switch (type) {
      case _valueAdRequest:
        return AdInfo(
            readValueOfType(buffer.getUint8(), buffer).cast<String>(),
            readValueOfType(buffer.getUint8(), buffer).cast<String>(),
            readValueOfType(buffer.getUint8(), buffer),
            readValueOfType(buffer.getUint8(), buffer));
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class _BiMap<K extends Object, V extends Object> extends MapBase<K, V> {
  _BiMap() {
    _inverse = _BiMap<V, K>._inverse(this);
  }

  _BiMap._inverse(this._inverse);

  final Map<K, V> _map = <K, V>{};
  late _BiMap<V, K> _inverse;

  _BiMap<V, K> get inverse => _inverse;

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(K key, V value) {
    assert(!_map.containsKey(key));
    assert(!inverse.containsKey(value));
    _map[key] = value;
    inverse._map[value] = key;
  }

  @override
  void clear() {
    _map.clear();
    inverse._map.clear();
  }

  @override
  Iterable<K> get keys => _map.keys;

  @override
  V? remove(Object? key) {
    if (key == null) return null;
    final V? value = _map[key];
    inverse._map.remove(value);
    return _map.remove(key);
  }
}