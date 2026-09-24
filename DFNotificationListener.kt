package com.example.dfsupport
import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
class DFNotificationListener:NotificationListenerService(){override fun onNotificationPosted(s:StatusBarNotification){val e=s.notification.extras;NotificationStore.add(this,s.packageName,e.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty(),e.getCharSequence(Notification.EXTRA_TEXT)?.toString().orEmpty(),e.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString().orEmpty())}}
