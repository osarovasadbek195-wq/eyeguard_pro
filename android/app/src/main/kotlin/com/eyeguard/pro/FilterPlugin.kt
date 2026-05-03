package com.eyeguard.pro

import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FilterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var overlayView: FrameLayout? = null
    private var windowManager: WindowManager? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "eyeguard_pro/filter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startFilter" -> {
                val intensity = call.argument<Double>("intensity") ?: 0.5
                val colorValue = call.argument<Long>("color") ?: 0xFFFFA500
                startFilterOverlay(intensity, colorValue)
                result.success(true)
            }
            "stopFilter" -> {
                stopFilterOverlay()
                result.success(true)
            }
            "updateFilter" -> {
                val intensity = call.argument<Double>("intensity")
                val colorValue = call.argument<Long>("color")
                updateFilterOverlay(intensity, colorValue)
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun startFilterOverlay(intensity: Double, colorValue: Long) {
        if (overlayView != null) return

        overlayView = FrameLayout(context).apply {
            setBackgroundColor(getAdjustedColor(colorValue, intensity))
        }

        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_SYSTEM_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            PixelFormat.TRANSLUCENT
        )

        try {
            windowManager?.addView(overlayView, layoutParams)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun stopFilterOverlay() {
        try {
            overlayView?.let {
                windowManager?.removeView(it)
                overlayView = null
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun updateFilterOverlay(intensity: Double?, colorValue: Long?) {
        overlayView?.let {
            val currentColor = colorValue ?: 0xFFFFA500
            val currentIntensity = intensity ?: 0.5
            it.setBackgroundColor(getAdjustedColor(currentColor, currentIntensity))
        }
    }

    private fun getAdjustedColor(colorValue: Long, intensity: Double): Int {
        val alpha = (intensity * 255).toInt().coerceIn(0, 255)
        val r = (colorValue shr 16 and 0xFF).toInt()
        val g = (colorValue shr 8 and 0xFF).toInt()
        val b = (colorValue and 0xFF).toInt()
        return Color.argb(alpha, r, g, b)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        stopFilterOverlay()
    }
}
