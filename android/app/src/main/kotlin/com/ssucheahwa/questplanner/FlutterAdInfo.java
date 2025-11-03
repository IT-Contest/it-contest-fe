package com.ssucheahwa.questplanner;

import androidx.annotation.Nullable;

import com.fsn.cauly.CaulyAdInfo;
import com.fsn.cauly.CaulyAdInfoBuilder;

import java.util.Objects;

class FlutterAdInfo {

    private final String appCode;

    @Nullable
    private String bannerHeight;

    @Nullable
    private int bannerSizeWidth;

    @Nullable
    private int bannerSizeHeight;

    protected static class Builder {
        private final String appCode;

        @Nullable
        private String bannerHeight;

        @Nullable
        private int bannerSizeWidth;

        @Nullable
        private int bannerSizeHeight;

        public Builder(String appCode){
            this.appCode = appCode;
        }

        public FlutterAdInfo.Builder bannerHeight(@Nullable String bannerHeight) {
            this.bannerHeight = bannerHeight;
            return this;
        }

        public FlutterAdInfo.Builder setBannerSize(int bannerSizeWidth, int bannerSizeHeight) {
            this.bannerSizeWidth = bannerSizeWidth;
            this.bannerSizeHeight = bannerSizeHeight;
            return this;
        }

        public String getAppCode() {
            return appCode;
        }

        public String getBannerHeight() {
            return bannerHeight;
        }

        public int[] getBannerSize(){
            return new int[] {bannerSizeWidth, bannerSizeHeight};
        }

        FlutterAdInfo build() {
            return new FlutterAdInfo(appCode, bannerHeight, bannerSizeWidth, bannerSizeHeight);
        }

    }

    protected FlutterAdInfo(String appCode, String bannerHeight, int bannerSizeWidth, int bannerSizeHeight){
        this.appCode = appCode;
        this.bannerHeight = bannerHeight;
        this.bannerSizeWidth = bannerSizeWidth;
        this.bannerSizeHeight = bannerSizeHeight;
    }

    protected CaulyAdInfoBuilder updateAdInfoBuilder() {
        CaulyAdInfoBuilder builder =
                new CaulyAdInfoBuilder(appCode);
        if(bannerHeight != null){
            builder.bannerHeight(bannerHeight);
        }
        if(bannerSizeWidth > 0 && bannerSizeHeight > 0){
            builder.setBannerSize(bannerSizeWidth, bannerSizeHeight);
        }
        return builder;
    }

    CaulyAdInfo asAdInfo(){
        return updateAdInfoBuilder().build();
    }

    public String getAppCode() {
        return appCode;
    }

    @Nullable
    public String getBannerHeight() {
        return bannerHeight;
    }

    @Nullable
    public int getBannerSizeWidth() {
        return bannerSizeWidth;
    }

    @Nullable
    public int getBannerSizeHeight() {
        return bannerSizeHeight;
    }



    @Override
    public boolean equals(Object o) {
        if(this == o) return true;
        if(!(o instanceof FlutterAdInfo)) return false;
        FlutterAdInfo that = (FlutterAdInfo) o;
        return appCode.equals(that.appCode)
                && bannerHeight.equals(that.bannerHeight)
                && bannerSizeWidth == that.bannerSizeWidth
                && bannerSizeHeight == that.bannerSizeHeight;
    }

    @Override
    public int hashCode() {
        return Objects.hash(appCode, bannerHeight, bannerSizeWidth, bannerSizeHeight);
    }
}
