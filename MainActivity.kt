package com.example.dfsupport
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
class MainActivity:FlutterActivity(){override fun configureFlutterEngine(e:FlutterEngine){super.configureFlutterEngine(e);MethodChannel(e.dartExecutor.binaryMessenger,"dfsupport/notifications").setMethodCallHandler{c,r->when(c.method){"getNotifications"->r.success(NotificationStore.getAll(this));"openNotificationAccess"->{startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS));r.success(null)};else->r.notImplemented()}}}}
