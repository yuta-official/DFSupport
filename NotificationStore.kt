package com.example.dfsupport
import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
object NotificationStore{private const val P="df_log";private const val K="items";@Synchronized fun add(c:Context,p:String,t:String,x:String,b:String){val s=c.getSharedPreferences(P,0);val a=try{JSONArray(s.getString(K,"[]"))}catch(e:Exception){JSONArray()};a.put(JSONObject().put("package",p).put("title",t).put("text",x).put("bigText",b).put("time",System.currentTimeMillis().toString()));while(a.length()>100)a.remove(0);s.edit().putString(K,a.toString()).apply()}@Synchronized fun getAll(c:Context):List<Map<String,String>>{val a=try{JSONArray(c.getSharedPreferences(P,0).getString(K,"[]"))}catch(e:Exception){JSONArray()};return(0 until a.length()).map{val o=a.getJSONObject(it);mapOf("package" to o.optString("package"),"title" to o.optString("title"),"text" to o.optString("text"),"bigText" to o.optString("bigText"),"time" to o.optString("time"))}}}
