package com.example.music_playlist_app

import android.app.Activity
import android.content.Intent
import android.content.IntentSender
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.music_playlist_app/media_actions"
    private val DELETE_REQUEST_CODE = 1001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "deleteSong") {
                val uriStr = call.argument<String>("uri")
                val pathStr = call.argument<String>("path")
                if (uriStr == null) {
                    result.error("INVALID_ARGUMENT", "URI cannot be null", null)
                    return@setMethodCallHandler
                }

                pendingResult = result

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    // Android 11+ (API 30+)
                    val uri = Uri.parse(uriStr)
                    val pendingIntent = MediaStore.createDeleteRequest(contentResolver, listOf(uri))
                    try {
                        startIntentSenderForResult(
                            pendingIntent.intentSender,
                            DELETE_REQUEST_CODE,
                            null, 0, 0, 0
                        )
                    } catch (e: IntentSender.SendIntentException) {
                        result.error("DELETE_FAILED", e.message, null)
                        pendingResult = null
                    }
                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    // Android 10 (API 29)
                    val uri = Uri.parse(uriStr)
                    try {
                        contentResolver.delete(uri, null, null)
                        result.success(true)
                        pendingResult = null
                    } catch (securityException: SecurityException) {
                        val recoverableSecurityException = securityException as? android.app.RecoverableSecurityException
                        if (recoverableSecurityException != null) {
                            try {
                                startIntentSenderForResult(
                                    recoverableSecurityException.userAction.actionIntent.intentSender,
                                    DELETE_REQUEST_CODE,
                                    null, 0, 0, 0
                                )
                            } catch (e: IntentSender.SendIntentException) {
                                result.error("DELETE_FAILED", e.message, null)
                                pendingResult = null
                            }
                        } else {
                            result.error("PERMISSION_DENIED", securityException.message, null)
                            pendingResult = null
                        }
                    }
                } else {
                    // Android 9 and below
                    val uri = Uri.parse(uriStr)
                    try {
                        val deletedRows = contentResolver.delete(uri, null, null)
                        var fileDeleted = false
                        if (pathStr != null) {
                            val file = java.io.File(pathStr)
                            if (file.exists()) {
                                fileDeleted = file.delete()
                            }
                        }
                        result.success(deletedRows > 0 || fileDeleted)
                        pendingResult = null
                    } catch (e: Exception) {
                        result.error("DELETE_FAILED", e.message, null)
                        pendingResult = null
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == DELETE_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                pendingResult?.success(true)
            } else {
                pendingResult?.success(false)
            }
            pendingResult = null
        }
    }
}
