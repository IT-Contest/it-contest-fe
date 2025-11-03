package com.ssucheahwa.questplanner;

import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.plugin.platform.PlatformView;

public class FlutterPlatformView implements PlatformView {

    @Nullable private View view;

    FlutterPlatformView(@NonNull View view) {
        this.view = view;
    }

    @Nullable
    @Override
    public View getView() {
        return view;
    }

    @Override
    public void onFlutterViewAttached(@NonNull View flutterView) {
        PlatformView.super.onFlutterViewAttached(flutterView);
    }

    @Override
    public void onFlutterViewDetached() {
        PlatformView.super.onFlutterViewDetached();
    }

    @Override
    public void dispose() {
        this.view = null;
    }
}
