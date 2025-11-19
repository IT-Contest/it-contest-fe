package com.ssucheahwa.questplanner;


import android.content.Context;

import androidx.annotation.NonNull;

import com.fsn.cauly.CaulyAdView;

public class BannerAdCreator {

    @NonNull
    private final Context context;

    public BannerAdCreator(@NonNull Context context) {
        this.context = context;
    }

    public CaulyAdView createAdView() {
        return new CaulyAdView(context);
    }
}
