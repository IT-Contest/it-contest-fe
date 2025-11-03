package com.ssucheahwa.questplanner;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.StandardMethodCodec;

/** CaulyFlutterSdkPlugin */
public class CaulyFlutterSdkPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private static final String TAG = "CaulyFlutterSdkPlugin";

    @Nullable
    private FlutterPluginBinding flutterPluginBinding;
    @Nullable
    private AdInstanceManager instanceManager;
    @Nullable
    private AdMessageCodec adMessageCodec;

    private MethodChannel channel;

    private static final String CHANNEL_NAME = "cauly_flutter_sdk";
    private static final String VIEW_TYPE_ID = CHANNEL_NAME + "/ad_widget";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding;
        adMessageCodec = new AdMessageCodec(flutterPluginBinding.getApplicationContext());

        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(),
                CHANNEL_NAME, new StandardMethodCodec(adMessageCodec));
        channel.setMethodCallHandler(this);
        instanceManager = new AdInstanceManager(channel);

        flutterPluginBinding
                .getPlatformViewRegistry()
                .registerViewFactory(VIEW_TYPE_ID, new CaulyAdsViewFactory(instanceManager));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
        if (instanceManager != null) {
            instanceManager.setActivity(activityPluginBinding.getActivity());
        }
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        if (instanceManager != null) {
            instanceManager.setActivity(null);
        }
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
        if (instanceManager != null) {
            instanceManager.setActivity(activityPluginBinding.getActivity());
        }
    }

    @Override
    public void onDetachedFromActivity() {
        if (instanceManager != null) {
            instanceManager.setActivity(null);
        }
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (instanceManager == null || flutterPluginBinding == null) {
            Log.e(TAG, "method call received before instanceManager initialized: " + call.method);
            return;
        }
        // Use activity as context if available.
        Context context = (instanceManager.getActivity() != null)
                ? instanceManager.getActivity()
                : flutterPluginBinding.getApplicationContext();

        switch (call.method) {
            case "_init":
                // Internal init. This is necessary to cleanup state on hot restart.
                instanceManager.disposeAllAds();
                result.success(null);
                break;
            case "loadInterstitialAd":
                final FlutterInterstitialAd interstitial = new FlutterInterstitialAd(
                        call.<Integer>argument("adId"),
                        instanceManager,
                        call.argument("adInfo"),
                        new FlutterAdLoader(context));
                instanceManager.trackAd(interstitial, call.<Integer>argument("adId"));
                interstitial.load();
                result.success(null);
                break;
            case "loadBannerAd":
                final FlutterBannerAd bannerAd = new FlutterBannerAd(
                        call.<Integer>argument("adId"),
                        context,
                        instanceManager,
                        call.argument("adInfo"),
                        getBannerAdCreator(context));
                instanceManager.trackAd(bannerAd, call.<Integer>argument("adId"));
                bannerAd.load();
                result.success(null);
                break;
            case "disposeAd":
                instanceManager.disposeAd(call.<Integer>argument("adId"));
                result.success(null);
                break;
            case "showAdWithoutView":
                final boolean adShown = instanceManager.showAdWithId(call.<Integer>argument("adId"));
                if (!adShown) {
                    result.error("AdShowError", "Ad failed to show.", null);
                    break;
                }
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @VisibleForTesting
    BannerAdCreator getBannerAdCreator(@NonNull Context context) {
        return new BannerAdCreator(context);
    }

}
