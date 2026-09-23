package com.dfsupport.app

object NotificationStore {
    @Volatile
    var latest: HashMap<String, Any?>? = null
}
