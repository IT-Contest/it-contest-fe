import 'package:meta/meta.dart';

import 'ad_containers.dart';

/// The callback type to handle an event occurring for an [Ad].
typedef AdEventCallback = void Function(Ad ad);

/// Generic callback type for an event occurring on an Ad.
typedef GenericAdEventCallback<Ad> = void Function(Ad ad);

/// A callback type for when an error occurs loading a full screen ad.
typedef FullScreenAdLoadErrorCallback = void Function(String errorCode, String errorMessage);

/// The callback type to handle an error loading an [Ad].
typedef AdLoadErrorCallback = void Function(Ad ad, String errorCode, String errorMessage);

/// Listener for app events.
class AppEventListener {
  /// Called when an app event is received.
  void Function(Ad ad, String name, String data)? onAppEvent;
}

/// Shared event callbacks used in Native and Banner ads.
abstract class AdWithViewListener {
  /// Default constructor for [AdWithViewListener], meant to be used by subclasses.
  @protected
  const AdWithViewListener({
    this.onReceiveAd,
    this.onFailedToReceiveAd,
    this.onShowLandingScreen,
    this.onCloseLandingScreen,
  });

  /// Called when an ad is successfully received.
  final AdEventCallback? onReceiveAd;

  /// Called when an ad request failed.
  final AdLoadErrorCallback? onFailedToReceiveAd;

  /// A full screen view/overlay is presented in response to the user clicking
  /// on an ad. You may want to pause animations and time sensitive
  /// interactions.
  final AdEventCallback? onShowLandingScreen;

  /// Called when the full screen view has been closed. You should restart
  /// anything paused while handling onCloseLandingScreen.
  final AdEventCallback? onCloseLandingScreen;

}

/// A listener for receiving notifications for the lifecycle of a [BannerAd].
class BannerAdListener extends AdWithViewListener {
  /// Constructs a [BannerAdListener] that notifies for the provided event callbacks.
  ///
  /// Typically you will override [onAdLoaded] and [onAdFailedToLoad]:
  /// ```dart
  /// BannerAdListener(
  ///   onAdLoaded: (ad) {
  ///     // Ad successfully loaded - display an AdWidget with the banner ad.
  ///   },
  ///   onAdFailedToLoad: (ad, error) {
  ///     // Ad failed to load - log the error and dispose the ad.
  ///   },
  ///   ...
  /// )
  /// ```
  const BannerAdListener({
    AdEventCallback? onReceiveAd,
    AdLoadErrorCallback? onFailedToReceiveAd,
    AdEventCallback? onShowLandingScreen,
    AdEventCallback? onCloseLandingScreen,
  }) : super(
    onReceiveAd: onReceiveAd,
    onFailedToReceiveAd: onFailedToReceiveAd,
    onShowLandingScreen: onShowLandingScreen,
    onCloseLandingScreen: onCloseLandingScreen,
  );
}

/// Generic parent class for ad load callbacks.
abstract class FullScreenAdLoadCallback<T> {
  /// Default constructor for [FullScreenAdLoadCallback[, used by subclasses.
  const FullScreenAdLoadCallback({
    required this.onReceiveInterstitialAd,
    required this.onFailedToReceiveInterstitialAd,
    this.onClosedInterstitialAd,
    this.onLeaveInterstitialAd,
  });

  /// Called when the ad successfully loads.
  final GenericAdEventCallback<T> onReceiveInterstitialAd;

  /// Called when an error occurs loading the ad.
  final FullScreenAdLoadErrorCallback onFailedToReceiveInterstitialAd;

  /// A full screen view/overlay is presented in response to the user clicking
  /// on an ad. You may want to pause animations and time sensitive
  /// interactions.
  final AdEventCallback? onClosedInterstitialAd;

  /// Called when the full screen view has been closed. You should restart
  /// anything paused while handling onAdOpened.
  final AdEventCallback? onLeaveInterstitialAd;

}

/// This class holds callbacks for loading an [InterstitialAd].
class InterstitialAdLoadCallback
    extends FullScreenAdLoadCallback<InterstitialAd> {
  /// Construct a [InterstitialAdLoadCallback].
  const InterstitialAdLoadCallback({
    required GenericAdEventCallback<InterstitialAd> onReceiveInterstitialAd,
    required FullScreenAdLoadErrorCallback onFailedToReceiveInterstitialAd,
    AdEventCallback? onClosedInterstitialAd,
    AdEventCallback? onLeaveInterstitialAd,
  }) : super(
    onReceiveInterstitialAd: onReceiveInterstitialAd,
    onFailedToReceiveInterstitialAd: onFailedToReceiveInterstitialAd,
    onClosedInterstitialAd: onClosedInterstitialAd,
    onLeaveInterstitialAd: onLeaveInterstitialAd,
  );
}