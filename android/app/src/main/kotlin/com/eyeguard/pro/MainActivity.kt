package com.eyeguard.pro

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Plugins are registered automatically via Flutter plugin system
        // AutostartPlugin and FilterPlugin are registered via pubspec.yaml
    }
}
