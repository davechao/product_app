package com.test.productapp

import android.annotation.TargetApi
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "flutter-product/battery"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { methodCall, result ->
            when (methodCall.method) {
                "getBatteryLevel" -> {
                    val batteryLevel = getBatteryLevel()
                    when (batteryLevel) {
                        -1 -> result.error("UNAVAILABLE", "Could not fetch battery level.", null)
                        else -> result.success(batteryLevel)
                    }
                }
                else -> result.notImplemented()
            }
        }
        GeneratedPluginRegistrant.registerWith(this)
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    private fun getBatteryLevel(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            val intent = ContextWrapper(application).registerReceiver(null, intentFilter)
            val batteryLevel = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100
            val batteryScale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
            batteryLevel / batteryScale
        }
    }
}
