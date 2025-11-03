package com.ssucheahwa.questplanner;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;

import io.flutter.plugin.common.StandardMessageCodec;

public class AdMessageCodec extends StandardMessageCodec {
    // The type values below must be consistent for each platform.
    private static final byte VALUE_AD_REQUEST = (byte) 129;

    @NonNull
    Context context;

    AdMessageCodec(@NonNull Context context) {
        this.context = context;
    }

    void setContext(@NonNull Context context) {
        this.context = context;
    }

    @Override
    protected void writeValue(@NonNull ByteArrayOutputStream stream, @NonNull Object value) {
        if(value instanceof FlutterAdInfo){
            stream.write(VALUE_AD_REQUEST);
            final FlutterAdInfo adInfo = (FlutterAdInfo) value;
            writeValue(stream, adInfo.getAppCode());
            writeValue(stream, adInfo.getBannerHeight());
            writeValue(stream, adInfo.getBannerSizeWidth());
            writeValue(stream, adInfo.getBannerSizeHeight());
        }else{
            super.writeValue(stream, value);
        }
    }

    @Nullable
    @Override
    protected Object readValueOfType(byte type, @NonNull ByteBuffer buffer) {
        switch (type){
            case VALUE_AD_REQUEST:
                return new FlutterAdInfo.Builder((String) readValueOfType(buffer.get(), buffer))
                        .bannerHeight((String) readValueOfType(buffer.get(), buffer))
                        .setBannerSize((int) readValueOfType(buffer.get(), buffer), (int) readValueOfType(buffer.get(), buffer))
                        .build();
            default:
                return super.readValueOfType(type, buffer);
        }
    }
}
