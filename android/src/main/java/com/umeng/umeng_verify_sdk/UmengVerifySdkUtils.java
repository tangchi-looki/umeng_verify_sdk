package com.umeng.umeng_verify_sdk;

import android.content.Context;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;

public class UmengVerifySdkUtils {

    public static int dp2px(Context context, float dipValue) {
        try {
            final float scale = context.getResources().getDisplayMetrics().density;
            return (int) (dipValue * scale + 0.5f);
        } catch (Exception e) {
            return (int) dipValue;
        }
    }

    public static int px2dp(Context context, float px) {
        try {
            final float scale = context.getResources().getDisplayMetrics().density;
            return (int) (px / scale + 0.5f);
        } catch (Exception e) {
            return (int) px;
        }
    }

    public static int px2sp(Context context, float px) {
        try {
            final float scale = context.getResources().getDisplayMetrics().scaledDensity;
            return (int) (px / scale + 0.5f);
        } catch (Exception e) {
            return (int) px;
        }
    }

    public static HashMap json2Map(String jsonStr) {
        HashMap map = new HashMap();
        try {
            JSONObject jsonObject = new JSONObject(jsonStr);
            Iterator iterator = jsonObject.keys();
            while (iterator.hasNext()) {
                String key = iterator.next().toString();
                map.put(key, jsonObject.opt(key));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }


}
