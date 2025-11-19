package com.ssucheahwa.questplanner;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class AdInstanceManager {
    @Nullable
    private Activity activity;

    @NonNull
    private final Map<Integer, FlutterAd> ads;
    @NonNull
    private final MethodChannel channel;

    /**
     * Initializes the ad instance manager. We only need a method channel to start
     * loading ads, but an
     * activity must be present in order to attach any ads to the view hierarchy.
     */
    AdInstanceManager(@NonNull MethodChannel channel) {
        this.channel = channel;
        this.ads = new HashMap<>();
    }

    void setActivity(@Nullable Activity activity) {
        this.activity = activity;
    }

    @Nullable
    Activity getActivity() {
        return activity;
    }

    @Nullable
    FlutterAd adForId(int id) {
        return ads.get(id);
    }

    @Nullable
    Integer adIdFor(@NonNull FlutterAd ad) {
        for (Integer adId : ads.keySet()) {
            if (ads.get(adId) == ad) {
                return adId;
            }
        }
        return null;
    }

    void trackAd(@NonNull FlutterAd ad, int adId) {
        if (ads.get(adId) != null) {
            throw new IllegalArgumentException(
                    String.format("Ad for following adId already exists: %d", adId));
        }
        ads.put(adId, ad);
    }

    void disposeAd(int adId) {
        if (!ads.containsKey(adId)) {
            return;
        }
        FlutterAd ad = ads.get(adId);
        if (ad != null) {
            ad.dispose();
        }
        ads.remove(adId);
    }

    void disposeAllAds() {
        for (Map.Entry<Integer, FlutterAd> entry : ads.entrySet()) {
            if (entry.getValue() != null) {
                entry.getValue().dispose();
            }
        }
        ads.clear();
    }

    void onReceiveAd(int adId, boolean isChargeableAd) {
        Map<Object, Object> arguments = new HashMap<>();
        arguments.put("adId", adId);
        arguments.put("isChargeableAd", isChargeableAd);
        arguments.put("eventName", "onReceiveAd");
        invokeOnAdEvent(arguments);
    }

    void onFailedToReceiveAd(int adId, int errorCode, String errorMessage) {
        Map<Object, Object> arguments = new HashMap<>();
        arguments.put("adId", adId);
        arguments.put("errorCode", errorCode);
        arguments.put("errorMessage", errorMessage);
        arguments.put("eventName", "onFailedToReceiveAd");
        invokeOnAdEvent(arguments);
    }

    void onShowLandingScreen(int id) {
        Map<Object, Object> arguments = new HashMap<>();
        arguments.put("adId", id);
        arguments.put("eventName", "onShowLandingScreen");
        invokeOnAdEvent(arguments);
    }

    void onCloseLandingScreen(int adId) {
        Map<Object, Object> arguments = new HashMap<>();
        arguments.put("adId", adId);
        arguments.put("eventName", "onCloseLandingScreen");
        invokeOnAdEvent(arguments);
    }

    void onReceiveInterstitialAd(int adId, boolean isChargeableAd) {
        Map<Object, Object> arguments = new HashMap<>();
        arguments.put("adId", adId);
        arguments.put("isChargeableAd", isChargeableAd);
        arguments.put("eventName", "onReceiveInterstitialAd");
        invokeOnAdEvent(arguments);
    }

    void onFailedToReceiveInterstitialAd(int adId, int errorCode, String errorMessage) {
        Map<Object, Object> arguments = new HashMap<>();
        arguments.put("adId", adId);
        arguments.put("errorCode", errorCode);
        arguments.put("errorMessage", errorMessage);
        arguments.put("eventName", "onFailedToReceiveInterstitialAd");
        invokeOnAdEvent(arguments);
    }

    void onClosedInterstitialAd(int id) {
        Map<Object, Object> arguments = new HashMap<>();
        arguments.put("adId", id);
        arguments.put("eventName", "onClosedInterstitialAd");
        invokeOnAdEvent(arguments);
    }

    void onLeaveInterstitialAd(int adId) {
        Map<Object, Object> arguments = new HashMap<>();
        arguments.put("adId", adId);
        arguments.put("eventName", "onLeaveInterstitialAd");
        invokeOnAdEvent(arguments);
    }

    boolean showAdWithId(int id) {
        final FlutterAd.FlutterOverlayAd ad = (FlutterAd.FlutterOverlayAd) adForId(id);

        if (ad == null) {
            return false;
        }

        ad.show();
        return true;
    }

    /**
     * Invoke the method channel using the UI thread. Otherwise the message gets
     * silently dropped.
     */
    private void invokeOnAdEvent(final Map<Object, Object> arguments) {
        new Handler(Looper.getMainLooper())
                .post(
                        new Runnable() {
                            @Override
                            public void run() {
                                channel.invokeMethod("onAdEvent", arguments);
                            }
                        });
    }
}
