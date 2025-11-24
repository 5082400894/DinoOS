package com.example.dino_os

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.dino_os/device_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getDeviceInfo") {
                val deviceInfo = getDeviceInfo()
                result.success(deviceInfo)
            } else {
                result.notImplemented()
            }
        }
    }

    @SuppressLint("HardwareIds")
    private fun getDeviceInfo(): Map<String, String> {
        val info = mutableMapOf<String, String>()
        
        // Device info
        info["Brand"] = Build.BRAND
        info["Model"] = Build.MODEL
        info["Manufacturer"] = Build.MANUFACTURER
        info["OS"] = "Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})"
        info["Build Number"] = Build.DISPLAY
        info["Kernel Version"] = System.getProperty("os.version") ?: "Unknown"
        

        //Hardware Info
        info["Hardware"] = Build.HARDWARE

        // Memory Info
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memInfo)
        val totalMemory = memInfo.totalMem

        
        info["Memory"] = formatBytes(totalMemory)

        
        // Storage info 
        val storagePath = applicationContext.filesDir.absolutePath

        // val storagePath = if (android.os.Environment.getExternalStorageState() == android.os.Environment.MEDIA_MOUNTED) {android.os.Environment.getExternalStorageDirectory().absolutePath} else { applicationContext.filesDir.absolutePath }

        val stat = StatFs(storagePath)
        val totalStorage = stat.blockCountLong * stat.blockSizeLong
        val availableStorage = stat.availableBlocksLong * stat.blockSizeLong

        
        info["Storage Total"] = formatBytes(totalStorage)
        info["Storage Available"] = formatBytes(availableStorage)

        
        
        return info
    }

    private fun formatBytes(bytes: Long): String {
        if (bytes < 1024) return "$bytes B"
        if (bytes < 1024 * 1024) return "${bytes / 1024} KB"
        if (bytes < 1024 * 1024 * 1024) {
            return String.format("%.2f MB", bytes / (1024.0 * 1024.0))
        }
        return String.format("%.2f GB", bytes / (1024.0 * 1024.0 * 1024.0))
    }
}
