package com.ssucheahwa.questplanner;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import com.fsn.cauly.CaulyAdInfo;
import com.fsn.cauly.CaulyInterstitialAd;
import com.fsn.cauly.CaulyInterstitialAdListener;

public class FlutterAdLoader {

    @NonNull
    private final Context context;

    public FlutterAdLoader(@NonNull Context context) {
        this.context = context;
    }

    /**
     * Load an interstitial ad.
     */
    public void loadInterstitial(
            @NonNull CaulyAdInfo adInfo,
            @NonNull CaulyInterstitialAdListener loadCallback) {
        CaulyInterstitialAd interstitialAd = new CaulyInterstitialAd();
        interstitialAd.setAdInfo(adInfo);
        interstitialAd.setInterstialAdListener(loadCallback);
        interstitialAd.requestInterstitialAd((Activity) context);
    }
}