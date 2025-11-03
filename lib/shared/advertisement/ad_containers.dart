import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'ad_instance_manager.dart';
import 'ad_listeners.dart';

class AdInfo {
  /// Default constructor for [AdInfo].
  const AdInfo(
      this.appCode,
      this.bannerHeight,
      this.bannerSizeWidth,
      this.bannerSizeHeight);

  final String appCode;
  final BannerHeightEnum bannerHeight;
  final int bannerSizeWidth;
  final int bannerSizeHeight;

  @override
  bool operator ==(Object other) {
    return other is AdInfo &&
        appCode == other.appCode &&
        bannerHeight == other.bannerHeight &&
        bannerSizeWidth == other.bannerSizeWidth &&
        bannerSizeHeight == other.bannerSizeHeight;
  }
}

enum BannerHeightEnum {
  adaptive(originalName: "ADAPTIVE", name4Java: "Adaptive"),
  proportional(originalName: "PROPORTIONAL", name4Java: "Proportional"),
  square(originalName: "SQUARE", name4Java: "Square"),
  fixed(originalName: "FIXED", name4Java: "Fixed"),
  fixed_50(originalName: "FIXED_50", name4Java: "Fixed_50");

  const BannerHeightEnum({required this.originalName, required this.name4Java});

  final String originalName;
  final String name4Java;
}

abstract class Ad {
  /// Frees the plugin resources associated with this ad.
  Future<void> dispose() {
    return instanceManager.disposeAd(this);
  }
}

/// Base class for mobile [Ad] that has an in-line view.
///
/// A valid [adUnitId] and [size] are required.
abstract class AdWithView extends Ad {
  /// Default constructor, used by subclasses.
  AdWithView({required this.listener});

  /// The [AdWithViewListener] for the ad.
  final AdWithViewListener listener;

  /// Starts loading this ad.
  ///
  /// Loading callbacks are sent to this [Ad]'s [listener].
  Future<void> load();
}

/// An [Ad] that is overlaid on top of the UI.
abstract class AdWithoutView extends Ad {}

/// Displays an [Ad] as a Flutter widget.
///
/// This widget takes ads inheriting from [AdWithView]
/// (e.g. [BannerAd] and [NativeAd]) and allows them to be added to the Flutter
/// widget tree.
///
/// Must call `load()` first before showing the widget. Otherwise, a
/// [PlatformException] will be thrown.
class AdWidget extends StatefulWidget {
  /// Default constructor for [AdWidget].
  ///
  /// [ad] must be loaded before this is added to the widget tree.
  const AdWidget({Key? key, required this.ad}) : super(key: key);

  /// Ad to be displayed as a widget.
  final AdWithView ad;

  @override
  State<AdWidget> createState() => _AdWidgetState();
}

class _AdWidgetState extends State<AdWidget> {
  bool _adIdAlreadyMounted = false;
  bool _adLoadNotCalled = false;
  bool _firstVisibleOccurred = false;

  @override
  void initState() {
    super.initState();
    final int? adId = instanceManager.adIdFor(widget.ad);
    if (adId != null) {
      if (instanceManager.isWidgetAdIdMounted(adId)) {
        _adIdAlreadyMounted = true;
      }
      instanceManager.mountWidgetAdId(adId);
    } else {
      _adLoadNotCalled = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    final int? adId = instanceManager.adIdFor(widget.ad);
    if (adId != null) {
      instanceManager.unmountWidgetAdId(adId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return const SizedBox();
    }

    if (_adIdAlreadyMounted) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('This AdWidget is already in the Widget tree'),
        ErrorHint(
            'If you placed this AdWidget in a list, make sure you create a new instance '
                'in the builder function with a unique ad object.'),
        ErrorHint(
            'Make sure you are not using the same ad object in more than one AdWidget.'),
      ]);
    }
    if (_adLoadNotCalled) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
            'AdWidget requires Ad.load to be called before AdWidget is inserted into the tree'),
        ErrorHint(
            'Parameter ad is not loaded. Call Ad.load before AdWidget is inserted into the tree.'),
      ]);
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Do not attach the platform view widget until it will actually become
      // visible. This is a workaround for
      // https://github.com/googleads/googleads-mobile-flutter/issues/580,
      // where impressions are erroneously fired due to how platform views are
      // rendered.
      // TODO (jjliu15): Remove this after the flutter issue is resolved.
      if (_firstVisibleOccurred) {
        return PlatformViewLink(
          viewType: '${instanceManager.channel.name}/ad_widget',
          surfaceFactory:
              (BuildContext context, PlatformViewController controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <
                  Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: '${instanceManager.channel.name}/ad_widget',
              layoutDirection: TextDirection.ltr,
              creationParams: instanceManager.adIdFor(widget.ad),
              creationParamsCodec: const StandardMessageCodec(),
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..create();
          },
        );
      } else {
        final adId = instanceManager.adIdFor(widget.ad);
        return VisibilityDetector(
          key: Key('android-platform-view-$adId'),
          onVisibilityChanged: (visibilityInfo) {
            if (!_firstVisibleOccurred &&
                visibilityInfo.visibleFraction > 0.01) {
              setState(() {
                _firstVisibleOccurred = true;
              });
            }
          },
          child: Container(),
        );
      }
    }

    throw Exception('is not supported on $defaultTargetPlatform');
  }
}

/// A banner ad.
///
/// This ad can either be overlaid on top of all flutter widgets as a static
/// view or displayed as a typical Flutter widget. To display as a widget,
/// instantiate an [AdWidget] with this as a parameter.
class BannerAd extends AdWithView {
  /// Creates a [BannerAd].
  ///
  /// A valid [adUnitId], nonnull [listener], and nonnull request is required.
  BannerAd({
    required AdWithViewListener listener,
    required this.adInfo,
  }) : super(listener: listener);

  /// Targeting information used to fetch an [Ad].
  final AdInfo adInfo;

  @override
  Future<void> load() async {
    if (Platform.isAndroid) {
      await instanceManager.loadBannerAd(this);
    }
  }

  int get bannerSizeHeight => Platform.isAndroid ? adInfo.bannerSizeHeight : 0;

}

/// A full-screen interstitial ad for the Google Mobile Ads Plugin.
class InterstitialAd extends AdWithoutView {
  InterstitialAd._({
    required this.adInfo,
    required this.adLoadCallback,
  });

  /// Targeting information used to fetch an [Ad].
  final AdInfo adInfo;

  /// Callback to be invoked when the ad finishes loading.
  final InterstitialAdLoadCallback adLoadCallback;

  /// Loads an [InterstitialAd] with the given [adUnitId] and [request].
  static Future<void> load({
    required AdInfo adInfo,
    required InterstitialAdLoadCallback adLoadCallback,
  }) async {
    InterstitialAd ad =
    InterstitialAd._(adInfo: adInfo, adLoadCallback: adLoadCallback);

    if (Platform.isAndroid) {
      await instanceManager.loadInterstitialAd(ad);
    }
  }

  /// Displays this on top of the application.
  ///
  /// Set [fullScreenContentCallback] before calling this method to be
  /// notified of events that occur when showing the ad.
  Future<void> show() {
    return instanceManager.showAdWithoutView(this);
  }
}