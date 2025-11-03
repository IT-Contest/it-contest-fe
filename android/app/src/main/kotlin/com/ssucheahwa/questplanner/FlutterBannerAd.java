package com.ssucheahwa.questplanner;

import android.content.Context;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.fsn.cauly.CaulyAdView;

import io.flutter.plugin.platform.PlatformView;

public class FlutterBannerAd extends FlutterAd {

    @NonNull
    private final Context context;
    @NonNull private final RelativeLayout rootView;
    @NonNull
    private final AdInstanceManager manager;
    @NonNull
    private final FlutterAdInfo adInfo;
    @NonNull
    private final BannerAdCreator bannerAdCreator;
    @Nullable
    private CaulyAdView caulyAdView;

    public FlutterBannerAd(
            int adId,
            @NonNull Context context,
            @NonNull AdInstanceManager manager,
            @NonNull FlutterAdInfo adInfo,
            @NonNull BannerAdCreator bannerAdCreator) {
        super(adId);
        this.context = context;
        this.manager = manager;
        this.adInfo = adInfo;
        this.bannerAdCreator = bannerAdCreator;
        this.rootView = new RelativeLayout(context);
    }

    @Override
    void load() {
        clearView();
        caulyAdView = bannerAdCreator.createAdView();
        caulyAdView.setAdInfo(adInfo.asAdInfo());
        caulyAdView.setShowPreExpandableAd(true);
        caulyAdView.setAdViewListener(new FlutterBannerAdListener(adId, manager));
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        rootView.addView(caulyAdView, params);
    }

    @Nullable
    @Override
    PlatformView getPlatformView() {
        if(caulyAdView == null){
            return null;
        }
        return new FlutterPlatformView(rootView);
    }

    @Override
    void dispose() {
        clearView();
    }

    void clearView() {
        if(caulyAdView != null){
            caulyAdView.destroy();
            rootView.removeView(caulyAdView);
        }
    }
}
