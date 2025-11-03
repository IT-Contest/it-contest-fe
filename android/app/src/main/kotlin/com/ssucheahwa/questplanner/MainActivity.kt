package com.ssucheahwa.questplanner

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // ✅ Cauly 플러그인 수동 등록
        flutterEngine.plugins.add(CaulyFlutterSdkPlugin())
    }
}
