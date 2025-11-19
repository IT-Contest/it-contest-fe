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

# Gson 관련 (generic signature 유지)
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class com.google.gson.stream.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# flutter_local_notifications 관련
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# WorkManager (백그라운드 스케줄 관련)
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**
