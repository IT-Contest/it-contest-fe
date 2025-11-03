package com.ssucheahwa.questplanner;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.fsn.cauly.CaulyInterstitialAd;
import com.fsn.cauly.CaulyInterstitialAdListener;

import java.lang.ref.WeakReference;

public class FlutterInterstitialAd extends FlutterAd.FlutterOverlayAd {
    private static final String TAG = "FlutterInterstitialAd";

    @NonNull
    private final AdInstanceManager manager;
    @NonNull
    private final FlutterAdInfo adInfo;
    @Nullable
    private CaulyInterstitialAd ad;
    @NonNull
    private final FlutterAdLoader flutterAdLoader;

    public FlutterInterstitialAd(
            int adId,
            @NonNull AdInstanceManager manager,
            @NonNull FlutterAdInfo adInfo,
            @NonNull FlutterAdLoader flutterAdLoader) {
        super(adId);
        this.manager = manager;
        this.adInfo = adInfo;
        this.flutterAdLoader = flutterAdLoader;
    }

    @Override
    void load() {
        flutterAdLoader.loadInterstitial(adInfo.asAdInfo(),
                new DelegatingInterstitialAdLoadCallback(this));
    }

    public void onReceiveInterstitialAd(CaulyInterstitialAd ad, boolean isChargeableAd) {
        this.ad = ad;
        manager.onReceiveInterstitialAd(adId, isChargeableAd);
    }

    public void onFailedToReceiveInterstitialAd(CaulyInterstitialAd ad, int errorCode, String errorMessage) {
        this.ad = ad;
        manager.onFailedToReceiveInterstitialAd(adId, errorCode, errorMessage);
    }

    public void onClosedInterstitialAd(CaulyInterstitialAd ad) {
        this.ad = ad;
        manager.onClosedInterstitialAd(adId);
    }

    public void onLeaveInterstitialAd(CaulyInterstitialAd ad) {
        this.ad = ad;
        manager.onLeaveInterstitialAd(adId);
    }

    @Override
    void dispose() {
        ad = null;
    }

    @Override
    void show() {
        if (ad == null) {
            Log.e(TAG, "Error showing interstitial - the interstitial ad wasn't loaded yet.");
            return;
        }
        if (manager.getActivity() == null) {
            Log.e(TAG, "Tried to show interstitial before activity was bound to the plugin.");
            return;
        }
        ad.show();
    }


    /**
     * An InterstitialAdLoadCallback that just forwards events to a delegate.
     */
    private static final class DelegatingInterstitialAdLoadCallback implements CaulyInterstitialAdListener {

        private final WeakReference<FlutterInterstitialAd> delegate;

        DelegatingInterstitialAdLoadCallback(FlutterInterstitialAd delegate) {
            this.delegate = new WeakReference<>(delegate);
        }

        @Override
        public void onReceiveInterstitialAd(CaulyInterstitialAd caulyInterstitialAd, boolean isChargeableAd) {
            if(delegate.get() != null){
                delegate.get().onReceiveInterstitialAd(caulyInterstitialAd, isChargeableAd);
            }
        }

        @Override
        public void onFailedToReceiveInterstitialAd(CaulyInterstitialAd caulyInterstitialAd, int errorCode, String errorMessage) {
            if(delegate.get() != null){
                delegate.get().onFailedToReceiveInterstitialAd(caulyInterstitialAd, errorCode, errorMessage);
            }
        }

        @Override
        public void onClosedInterstitialAd(CaulyInterstitialAd caulyInterstitialAd) {
            if(delegate.get() != null){
                delegate.get().onClosedInterstitialAd(caulyInterstitialAd);
            }
        }

        @Override
        public void onLeaveInterstitialAd(CaulyInterstitialAd caulyInterstitialAd) {
            if(delegate.get() != null){
                delegate.get().onLeaveInterstitialAd(caulyInterstitialAd);
            }
        }

        @Override
        public void onClickInterstitialAd(CaulyInterstitialAd caulyInterstitialAd) {
            if (delegate.get() != null) {
                delegate.get().onLeaveInterstitialAd(caulyInterstitialAd);
            }
        }
    }
}
