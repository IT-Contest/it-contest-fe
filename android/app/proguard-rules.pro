# Flutter specific rules.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.webkit.**  { *; }
-keep class io.flutter.embedding.**  { *; }
-keep class com.google.common.** { *; }
-dontwarn com.google.common.**

# Google Play Core
-dontwarn com.google.android.play.core.**

# Kakao SDK
-keep class com.kakao.sdk.**.model.* { <fields>; }
-keep class * extends com.google.gson.TypeAdapter

-dontwarn com.kakao.sdk.**
-keep class com.kakao.sdk.auth.AuthCodeHandlerActivity { *; }