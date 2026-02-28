package com.umeng.umeng_verify_sdk;

import android.content.Context;
import android.content.pm.ActivityInfo;
import android.graphics.Paint;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.umeng.umverify.UMVerifyHelper;
import com.umeng.umverify.listener.UMAuthUIControlClickListener;
import com.umeng.umverify.listener.UMCustomInterface;
import com.umeng.umverify.listener.UMPreLoginResultListener;
import com.umeng.umverify.listener.UMTokenResultListener;
import com.umeng.umverify.view.UMAuthRegisterViewConfig;
import com.umeng.umverify.view.UMAuthUIConfig;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * UmengVerifySdkPlugin
 */
public class UmengVerifySdkPlugin implements FlutterPlugin, MethodCallHandler {

    private static final String TAG = "UmengVerifySdkPlugin";

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private UMVerifyHelper authHelper;
    private Context mContext = null;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        mContext = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "umeng_verify_sdk");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {
            if (!verifyMethodCall(call, result)) {
                result.notImplemented();
            }
        } catch (Exception e) {
            Log.e(TAG, "Exception:" + e.getMessage());
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private boolean verifyMethodCall(MethodCall call, Result result) {
        if ("getPlatformVersion".equals(call.method)) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
            return true;
        } else if ("register".equals(call.method)) {
            register(result);
            return true;
        } else if ("getVerifyVersion".equals(call.method)) {
            result.success(authHelper.getVersion());
            return true;
        } else if ("setVerifySDKInfo".equals(call.method)) {
            setVerifySDKInfo(call, result);
            return true;
        } else if ("getVerifyId".equals(call.method)) {
            getVerifyId(result);
            return true;
        } else if ("checkEnvAvailable".equals(call.method)) {
            checkEnvAvailable(call, result);
            return true;
        } else if ("accelerateVerifyWithTimeout".equals(call.method)) {
            accelerateVerify(call, result);
            return true;
        } else if ("getVerifyTokenWithTimeout".equals(call.method)) {
            getVerifyToken(call, result);
            return true;
        } else if ("accelerateLoginPageWithTimeout".equals(call.method)) {
            accelerateLoginPage(call, result);
            return true;
        } else if ("getLoginTokenWithTimeout".equals(call.method)) {
            getLoginToken(call, result);
            return true;
        } else if ("quitLoginPage".equals(call.method)) {
            authHelper.quitLoginPage();
            executeOnMain(result, true);
            return true;
        } else if ("hideLoginLoading".equals(call.method)) {
            authHelper.hideLoginLoading();
            executeOnMain(result, true);
            return true;
        } else if ("getCurrentCarrierName".equals(call.method)) {
            executeOnMain(result, authHelper.getCurrentCarrierName());
            return true;
        }
        return false;
    }

    private void register(final Result result) {
        authHelper = UMVerifyHelper.getInstance(mContext, new UMTokenResultListener() {
            @Override
            public void onTokenSuccess(final String ret) {
                Log.d(TAG, "onTokenResultSuccess: " + ret);
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            if (channel != null) {
                                channel.invokeMethod("onTokenResult", UmengVerifySdkUtils.json2Map(ret));
                            }
                        } catch (Throwable ignore) {
                        }
                    }
                });
            }

            @Override
            public void onTokenFailed(final String ret) {
                Log.e(TAG, "onTokenResultFailed: " + ret);
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            if (channel != null) {
                                channel.invokeMethod("onTokenResult", UmengVerifySdkUtils.json2Map(ret));
                            }
                        } catch (Throwable ignore) {
                        }
                    }
                });
            }
        });
        authHelper.setUIClickListener(new UMAuthUIControlClickListener() {
            @Override
            public void onClick(final String code, Context context, final String jsonString) {
                Log.d(TAG, "code: " + code + "\n" + "jsonString: " + jsonString);
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (channel != null) {
                            try {
                                Map map = new HashMap() {
                                    {
                                        put("code", code);
                                        put("jsonString", jsonString);
                                    }
                                };
                                channel.invokeMethod("onUIClickCallback", map);
                            } catch (Throwable ignore) {
                            }
                        }
                    }
                });
            }
        });
        executeOnMain(result, true);
    }

    private void setVerifySDKInfo(MethodCall call, Result result) {
        if (authHelper == null) {
            Log.e(TAG, "请先调用register_android方法");
            executeOnMain(result, false);
            return;
        }
        List<String> arguments = call.arguments();
        authHelper.setAuthSDKInfo(arguments.get(0));
        executeOnMain(result, true);
    }

    private void getVerifyId(Result result) {
        if (authHelper == null) {
            Log.e(TAG, "请先调用register_android方法");
            executeOnMain(result, false);
            return;
        }
        String verifyId = authHelper.getVerifyId(mContext);
        executeOnMain(result, verifyId);
    }

    private void checkEnvAvailable(MethodCall call, Result result) {
        if (authHelper == null) {
            Log.e(TAG, "请先调用register_android方法");
            executeOnMain(result, false);
            return;
        }
        authHelper.checkEnvAvailable((int) call.arguments);
        executeOnMain(result, true);
    }

    private void getVerifyToken(MethodCall call, Result result) {
        if (authHelper == null) {
            Log.e(TAG, "请先调用register_android方法");
            executeOnMain(result, false);
            return;
        }
        List<Integer> arguments = call.arguments();
        authHelper.getVerifyToken(arguments.get(0) * 1000);
        executeOnMain(result, true);
    }

    private void accelerateVerify(MethodCall call, final Result result) {
        if (authHelper == null) {
            Log.e(TAG, "请先调用register_android方法");
            executeOnMain(result, false);
            return;
        }
        List<Integer> arguments = call.arguments();
        authHelper.accelerateVerify(arguments.get(0) * 1000, new UMPreLoginResultListener() {
            @Override
            public void onTokenSuccess(final String vendor) {
                Log.d(TAG, "onPreTokenResultSuccess: " + vendor);
                try {
                    Map map = new HashMap() {{
                        put("vendor", vendor);
                    }};
                    executeOnMain(result, map);
                } catch (Throwable ignore) {
                }

            }

            @Override
            public void onTokenFailed(final String vendor, final String ret) {
                Log.d(TAG, "onPreTokenResultFailed: " + vendor + ", " + ret);
                try {
                    Map map = new HashMap() {{
                        put("vendor", vendor);
                        put("ret", ret);
                    }};
                    executeOnMain(result, map);
                } catch (Throwable ignore) {
                }
            }
        });
    }

    private void accelerateLoginPage(MethodCall call, final Result result) {
        if (authHelper == null) {
            Log.e(TAG, "请先调用register_android方法");
            executeOnMain(result, false);
            return;
        }
        List<Integer> arguments = call.arguments();
        authHelper.accelerateLoginPage(arguments.get(0) * 1000, new UMPreLoginResultListener() {
            @Override
            public void onTokenSuccess(final String vendor) {
                Log.d(TAG, "onPreTokenResultSuccess: " + vendor);
                try {
                    Map map = new HashMap() {{
                        put("vendor", vendor);
                    }};
                    executeOnMain(result, map);
                } catch (Throwable ignore) {
                }
            }

            @Override
            public void onTokenFailed(final String vendor, final String ret) {
                Log.d(TAG, "onPreTokenResultFailed: " + vendor + ", " + ret);
                try {
                    Map map = new HashMap() {{
                        put("vendor", vendor);
                        put("ret", ret);
                    }};
                    executeOnMain(result, map);
                } catch (Throwable ignore) {
                }
            }
        });
    }

    private void getLoginToken(MethodCall call, Result result) {
        if (authHelper == null) {
            Log.e(TAG, "请先调用register_android方法");
            executeOnMain(result, false);
            return;
        }
        List<Object> arguments = call.arguments();
        try {
            JSONObject object = new JSONObject(arguments.get(1).toString());
            setAuthUIConfig(object);
            JSONArray jsonArray = object.optJSONArray("customWidget");
            if (jsonArray != null) {
                for (int i = 0; i < jsonArray.length(); i++) {
                    addAuthRegistViewConfig(jsonArray.optJSONObject(i));
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        authHelper.getLoginToken(mContext, (int) arguments.get(0) * 1000);
        executeOnMain(result, true);
    }

    private void setAuthUIConfig(JSONObject authUIConfigObject) {
        UMAuthUIConfig.Builder builder = new UMAuthUIConfig.Builder();
        if (authUIConfigObject.has("contentViewFrame")) {
            //android: 弹窗模式务必设置width和height， 若不设置偏移量，将x、y设置为-1
            JSONArray jsonArray = authUIConfigObject.optJSONArray("contentViewFrame");
            if (jsonArray != null && jsonArray.length() == 4) {
                if (jsonArray.optDouble(0) != -1) {
                    builder.setDialogOffsetX((int) jsonArray.optDouble(0));
                }
                if (jsonArray.optDouble(1) != -1) {
                    builder.setDialogOffsetY((int) jsonArray.optDouble(1));
                }
                if (jsonArray.optDouble(2) != -1) {
                    builder.setDialogWidth((int) jsonArray.optDouble(2));
                }
                if (jsonArray.optDouble(3) != -1) {
                    builder.setDialogHeight((int) jsonArray.optDouble(3));
                }
            }
        }

        if (authUIConfigObject.has("isAutorotate")) {
            if (authUIConfigObject.optBoolean("isAutorotate")) {
                builder.setScreenOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR);
            } else {
                builder.setScreenOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            }
        }

        if (authUIConfigObject.has("alertBlurViewAlpha")) {
            builder.setDialogAlpha((float) authUIConfigObject.optDouble("alertBlurViewAlpha"));
        }

        if (authUIConfigObject.has("navIsHidden")) {
            builder.setNavHidden(authUIConfigObject.optBoolean("navIsHidden"));
        }

        if (authUIConfigObject.has("navColor")) {
            builder.setNavColor(authUIConfigObject.optInt("navColor"));
        }

        if (authUIConfigObject.has("navTitle")) {
            // 导航栏标题，string 内容，int 颜色，double 大小
            JSONArray jsonArray = authUIConfigObject.optJSONArray("navTitle");
            if (jsonArray != null && jsonArray.length() == 3) {
                if (!TextUtils.isEmpty(jsonArray.optString(0))) {
                    builder.setNavText(jsonArray.optString(0));
                }
                if (jsonArray.optInt(1) != -1) {
                    builder.setNavTextColor(jsonArray.optInt(1));
                }
                if ((int) jsonArray.optDouble(2) != -1) {
                    builder.setNavTextSize((int) jsonArray.optDouble(2));
                }
            }
        }

        if (authUIConfigObject.has("navBackImage")) {
            builder.setNavReturnImgPath(authUIConfigObject.optString("navBackImage"));
        }

        if (authUIConfigObject.has("hideNavBackItem")) {
            builder.setNavReturnHidden(authUIConfigObject.optBoolean("hideNavBackItem"));
        }

        if (authUIConfigObject.has("navBackButtonFrame")) {
            // navBackButtonFrame传入4个值，x,y,width,height
            // android系统上不支持设置x,y坐标，仅支持设置width和height, 需要将navBackButtonFrame中x,y设置为-1
            JSONArray jsonArray = authUIConfigObject.optJSONArray("navBackButtonFrame");
            if (jsonArray != null && jsonArray.length() == 4) {
                builder.setNavReturnImgWidth((int) jsonArray.optDouble(2));
                builder.setNavReturnImgHeight((int) jsonArray.optDouble(3));
            }
        }

        if (authUIConfigObject.has("prefersStatusBarHidden")) {
            builder.setStatusBarHidden(authUIConfigObject.optBoolean("prefersStatusBarHidden"));
        }

        if (authUIConfigObject.has("backgroundImage")) {
            builder.setPageBackgroundPath(authUIConfigObject.optString("backgroundImage"));
        }

        if (authUIConfigObject.has("logoImage")) {
            builder.setLogoImgPath(authUIConfigObject.optString("logoImage"));
        }

        if (authUIConfigObject.has("logoIsHidden")) {
            builder.setLogoHidden(authUIConfigObject.optBoolean("logoIsHidden"));
        }

        if (authUIConfigObject.has("logoFrame")) {
            // ios : 分别是x，y，width，height
            // android: y1:logo控件相对导航栏顶部位移  y2:logo控件相对底部位移 （y1,y2仅支持设置一个，需将不需要的设置为-1）  width, height
            JSONArray jsonArray = authUIConfigObject.optJSONArray("logoFrame");
            if (jsonArray != null && jsonArray.length() == 4) {
                if (jsonArray.optDouble(0) != -1) {
                    builder.setLogoOffsetY((int) jsonArray.optDouble(0));
                }
                if (jsonArray.optDouble(1) != -1) {
                    builder.setLogoOffsetY_B((int) jsonArray.optDouble(1));
                }
                if (jsonArray.optDouble(2) != -1) {
                    builder.setLogoWidth((int) jsonArray.optDouble(2));
                }
                if (jsonArray.optDouble(3) != -1) {
                    builder.setLogoHeight((int) jsonArray.optDouble(3));
                }
            }
        }

        if (authUIConfigObject.has("sloganText")) {
            // slogan文案，string 内容，int 颜色，double 大小
            JSONArray jsonArray = authUIConfigObject.optJSONArray("sloganText");
            if (jsonArray != null && jsonArray.length() == 3) {
                if (!TextUtils.isEmpty(jsonArray.optString(0))) {
                    builder.setSloganText(jsonArray.optString(0));
                }
                if (jsonArray.optInt(1) != -1) {
                    builder.setSloganTextColor(jsonArray.optInt(1));

                }
                if ((int) jsonArray.optDouble(2) != -1) {
                    builder.setSloganTextSize((int) jsonArray.optDouble(2));
                }
            }
        }

        if (authUIConfigObject.has("sloganIsHidden")) {
            builder.setSloganHidden(authUIConfigObject.optBoolean("sloganIsHidden"));
        }

        if (authUIConfigObject.has("sloganFrame")) {
            JSONArray jsonArray = authUIConfigObject.optJSONArray("sloganFrame");
            if (jsonArray != null && jsonArray.length() == 4) {
                // android:  y1:logo控件相对导航栏顶部位移  y2:logo控件相对底部位移 （y1,y2仅支持设置一个，需将不需要的设置为-1）, width:-1, height:-1
                if (jsonArray.optDouble(0) != -1) {
                    builder.setSloganOffsetY((int) jsonArray.optDouble(0));
                }
                if (jsonArray.optDouble(1) != -1) {
                    builder.setSloganOffsetY_B((int) jsonArray.optDouble(1));
                }
            }
        }

        if (authUIConfigObject.has("numberColor")) {
            builder.setNumberColor(authUIConfigObject.optInt("numberColor"));
        }

        if (authUIConfigObject.has("numberFont")) {
            builder.setNumberSize((int) authUIConfigObject.optDouble("numberFont"));
        }

        if (authUIConfigObject.has("numberFrame")) {
            //android: 传入4个值，分别是x, y1, y2, -1  x:横坐标 y1:logo控件相对导航栏顶部位移  y2:logo控件相对底部位移 （y1,y2仅支持设置一个，需将不需要的设置为-1）
            JSONArray jsonArray = authUIConfigObject.optJSONArray("numberFrame");
            if (jsonArray != null && jsonArray.length() == 4) {
                if (jsonArray.optDouble(0) != -1) {
                    builder.setNumberFieldOffsetX((int) jsonArray.optDouble(0));
                }
                if (jsonArray.optDouble(1) != -1) {
                    builder.setNumFieldOffsetY((int) jsonArray.optDouble(1));
                }
                if (jsonArray.optDouble(2) != -1) {
                    builder.setNumFieldOffsetY_B((int) jsonArray.optDouble(2));
                }
            }
        }

        if (authUIConfigObject.has("loginBtnText")) {
            // 登陆按钮文案，string 内容，int 颜色，double 大小
            JSONArray jsonArray = authUIConfigObject.optJSONArray("loginBtnText");
            if (jsonArray != null && jsonArray.length() == 3) {
                if (!TextUtils.isEmpty(jsonArray.optString(0))) {
                    builder.setLogBtnText(jsonArray.optString(0));
                }
                if (jsonArray.optInt(1) != -1) {
                    builder.setLogBtnTextColor(jsonArray.optInt(1));
                }
                if ((int) jsonArray.optDouble(2) != -1) {
                    builder.setLogBtnTextSize((int) jsonArray.optDouble(2));
                }
            }
        }

        if (authUIConfigObject.has("loginBtnBgImg_android")) {
            builder.setLogBtnBackgroundPath(authUIConfigObject.optString("loginBtnBgImg_android"));
        }

        if (authUIConfigObject.has("autoHideLoginLoading")) {
            builder.setHiddenLoading(authUIConfigObject.optBoolean("autoHideLoginLoading"));
        }

        if (authUIConfigObject.has("loginBtnFrame")) {
            // android 传入5个值，分别是x,y1,y2,width,height  x:横坐标 y1:logo控件相对导航栏顶部位移  y2:logo控件相对底部位移 （y1,y2仅支持设置一个，需将不需要的设置为-1）
            JSONArray jsonArray = authUIConfigObject.optJSONArray("loginBtnFrame");
            if (jsonArray != null && jsonArray.length() == 5) {
                if (jsonArray.optDouble(0) != -1) {
                    builder.setLogBtnOffsetX((int) jsonArray.optDouble(0));
                }
                if (jsonArray.optDouble(1) != -1) {
                    builder.setLogBtnOffsetY((int) jsonArray.optDouble(1));
                }
                if (jsonArray.optDouble(2) != -1) {
                    builder.setLogBtnOffsetY_B((int) jsonArray.optDouble(2));
                }
                if (jsonArray.optDouble(3) != -1) {
                    builder.setLogBtnWidth((int) jsonArray.optDouble(3));
                }
                if (jsonArray.optDouble(4) != -1) {
                    builder.setLogBtnHeight((int) jsonArray.optDouble(4));
                }
            }
        }

        if (authUIConfigObject.has("checkBoxImages")) {
            JSONArray jsonArray = authUIConfigObject.optJSONArray("checkBoxImages");
            if (jsonArray != null && jsonArray.length() == 2) {
                if (!TextUtils.isEmpty(jsonArray.optString(0))) {
                    builder.setUncheckedImgPath(jsonArray.optString(0));
                }
                if (!TextUtils.isEmpty(jsonArray.optString(1))) {
                    builder.setCheckedImgPath(jsonArray.optString(1));
                }
            }
        }

        if (authUIConfigObject.has("checkBoxIsChecked")) {
            builder.setPrivacyState(authUIConfigObject.optBoolean("checkBoxIsChecked"));
        }

        if (authUIConfigObject.has("checkBoxIsHidden")) {
            builder.setCheckboxHidden(authUIConfigObject.optBoolean("checkBoxIsHidden"));
        }

        if (authUIConfigObject.has("checkBoxWH")) {
            builder.setCheckBoxWidth((int) authUIConfigObject.optDouble("checkBoxWH"));
            builder.setCheckBoxHeight((int) authUIConfigObject.optDouble("checkBoxWH"));
        }

        if (authUIConfigObject.has("privacyOne")) {
            JSONArray jsonArray = authUIConfigObject.optJSONArray("privacyOne");
            if (jsonArray != null && jsonArray.length() == 2) {
                if (!TextUtils.isEmpty(jsonArray.optString(0))
                        && !TextUtils.isEmpty(jsonArray.optString(1))) {
                    builder.setAppPrivacyOne(jsonArray.optString(0), jsonArray.optString(1));
                }
            }
        }

        if (authUIConfigObject.has("privacyTwo")) {
            JSONArray jsonArray = authUIConfigObject.optJSONArray("privacyTwo");
            if (jsonArray != null && jsonArray.length() == 2) {
                if (!TextUtils.isEmpty(jsonArray.optString(0))
                        && !TextUtils.isEmpty(jsonArray.optString(1))) {
                    builder.setAppPrivacyTwo(jsonArray.optString(0), jsonArray.optString(1));
                }
            }
        }

        if (authUIConfigObject.has("privacyThree")) {
            JSONArray jsonArray = authUIConfigObject.optJSONArray("privacyThree");
            if (jsonArray != null && jsonArray.length() == 2) {
                if (!TextUtils.isEmpty(jsonArray.optString(0))
                        && !TextUtils.isEmpty(jsonArray.optString(1))) {
                    builder.setAppPrivacyThree(jsonArray.optString(0), jsonArray.optString(1));
                }
            }
        }

        if (authUIConfigObject.has("privacyConectTexts")) {
            JSONArray jsonArray = authUIConfigObject.optJSONArray("privacyConectTexts");
            if (jsonArray != null) {
                String[] strings = new String[jsonArray.length()];
                for (int i = 0; i < jsonArray.length(); i++) {
                    strings[i] = jsonArray.optString(i);
                }
                builder.setPrivacyConectTexts(strings);
            }
        }

        if (authUIConfigObject.has("privacyColors")) {
            JSONArray jsonArray = authUIConfigObject.optJSONArray("privacyColors");
            if (jsonArray != null && jsonArray.length() == 2) {
                builder.setAppPrivacyColor(jsonArray.optInt(0), jsonArray.optInt(1));
            }
        }

        if (authUIConfigObject.has("privacyAlignment")) {
            if (authUIConfigObject.optString("privacyAlignment").equals(UMCustomEnums.UMTextAlignment.Left.name())) {
                builder.setProtocolGravity(Gravity.LEFT);
            } else if (authUIConfigObject.optString("privacyAlignment").equals(UMCustomEnums.UMTextAlignment.Right.name())) {
                builder.setProtocolGravity(Gravity.RIGHT);
            } else if (authUIConfigObject.optString("privacyAlignment").equals(UMCustomEnums.UMTextAlignment.Center.name())) {
                builder.setProtocolGravity(Gravity.CENTER);
            }
        }

        if (authUIConfigObject.has("privacyPreText")) {
            builder.setPrivacyBefore(authUIConfigObject.optString("privacyPreText"));
        }

        if (authUIConfigObject.has("privacySufText")) {
            builder.setPrivacyEnd(authUIConfigObject.optString("privacySufText"));
        }

        if (authUIConfigObject.has("privacyOperatorPreText")) {
            builder.setVendorPrivacyPrefix(authUIConfigObject.optString("privacyOperatorPreText"));
        }

        if (authUIConfigObject.has("privacyOperatorSufText")) {
            builder.setVendorPrivacySuffix(authUIConfigObject.optString("privacyOperatorSufText"));
        }

        if (authUIConfigObject.has("privacyOperatorIndex")) {
            builder.setPrivacyOperatorIndex(authUIConfigObject.optInt("privacyOperatorIndex"));
        }

        if (authUIConfigObject.has("privacyFont")) {
            builder.setPrivacyTextSize((int) authUIConfigObject.optDouble("privacyFont"));
        }

        if (authUIConfigObject.has("privacyFrame")) {
            // android: 传入4个值，分别是x, y1, y2, -1  x:横坐标 y1:logo控件相对导航栏顶部位移  y2:logo控件相对底部位移 （y1,y2仅支持设置一个，需将不需要的设置为-1）
            JSONArray jsonArray = authUIConfigObject.optJSONArray("privacyFrame");
            if (jsonArray != null && jsonArray.length() == 4) {
                if (jsonArray.optDouble(0) != -1) {
                    builder.setPrivacyOffsetX((int) jsonArray.optDouble(0));
                }
                if (jsonArray.optDouble(1) != -1) {
                    builder.setPrivacyOffsetY((int) jsonArray.optDouble(1));
                }
                if (jsonArray.optDouble(2) != -1) {
                    builder.setPrivacyOffsetY_B((int) jsonArray.optDouble(2));
                }
            }
        }

        if (authUIConfigObject.has("changeBtnTitle")) {
            // changeBtn标题，string 内容，int 颜色，double 大小
            JSONArray jsonArray = authUIConfigObject.optJSONArray("changeBtnTitle");
            if (jsonArray != null && jsonArray.length() == 3) {
                if (!TextUtils.isEmpty(jsonArray.optString(0))) {
                    builder.setSwitchAccText(jsonArray.optString(0));
                }
                if (jsonArray.optInt(1) != -1) {
                    builder.setSwitchAccTextColor(jsonArray.optInt(1));
                }
                if ((int) jsonArray.optDouble(2) != -1) {
                    builder.setSwitchAccTextSize((int) jsonArray.optDouble(2));
                }
            }
        }

        if (authUIConfigObject.has("changeBtnIsHidden")) {
            builder.setSwitchAccHidden(authUIConfigObject.optBoolean("changeBtnIsHidden"));
        }

        if (authUIConfigObject.has("changeBtnFrame")) {
            //android: 传入2个值：y1,y2,  y1:logo控件相对导航栏顶部位移  y2:logo控件相对底部位移 （y1,y2仅支持设置一个，需将不需要的设置为-1）
            JSONArray jsonArray = authUIConfigObject.optJSONArray("changeBtnFrame");
            if (jsonArray != null && jsonArray.length() == 4) {
                if (jsonArray.optDouble(0) != -1) {
                    builder.setSwitchOffsetY((int) jsonArray.optDouble(0));
                }
                if (jsonArray.optDouble(1) != -1) {
                    builder.setSwitchOffsetY_B((int) jsonArray.optDouble(1));
                }
            }
        }

        if (authUIConfigObject.has("protocolAction_android")) {
            builder.setProtocolAction(authUIConfigObject.optString("protocolAction_android"));
            builder.setPackageName(mContext.getPackageName());
        }

        if (authUIConfigObject.has("privacyNavColor")) {
            builder.setWebNavColor(authUIConfigObject.optInt("privacyNavColor"));
        }

        if (authUIConfigObject.has("privacyNavTitleFont")) {
            builder.setWebNavTextSize((int) authUIConfigObject.optDouble("privacyNavTitleFont"));
        }

        if (authUIConfigObject.has("privacyNavTitleColor")) {
            builder.setWebNavTextColor(authUIConfigObject.optInt("privacyNavTitleColor"));
        }

        if (authUIConfigObject.has("privacyNavBackImage")) {
            builder.setWebNavReturnImgPath(authUIConfigObject.optString("privacyNavBackImage"));
        }

        authHelper.setAuthUIConfig(builder.create());
    }

    private void addAuthRegistViewConfig(final JSONObject customWidgetObject) {
        if (customWidgetObject == null
                || TextUtils.isEmpty(customWidgetObject.optString("widgetId"))
                || TextUtils.isEmpty(customWidgetObject.optString("type"))) {
            return;
        }
        if (customWidgetObject.optString("type").equals(UMCustomEnums.UMCustomWidgetType.button.name())) {
            Button button = generateCustomButton(customWidgetObject);
            authHelper.addAuthRegistViewConfig(customWidgetObject.optString("widgetId"),
                    new UMAuthRegisterViewConfig.Builder()
                            .setRootViewId(customWidgetObject.optInt("rootViewId"))
                            .setView(button)
                            .setCustomInterface(new UMCustomInterface() {
                                @Override
                                public void onClick(Context context) {
                                    Log.d(TAG, customWidgetObject.optString("widgetId") + "button clicked.");
                                    mHandler.post(new Runnable() {
                                        @Override
                                        public void run() {
                                            if (channel != null) {
                                                try {
                                                    Map<String, String> map = new HashMap<>();
                                                    map.put("widgetId", customWidgetObject.optString("widgetId"));
                                                    channel.invokeMethod("onClickWidgetEvent", map);
                                                } catch (Throwable ignore) {
                                                }

                                            }
                                        }
                                    });
                                }
                            }).build());
        } else if (customWidgetObject.optString("type").equals(UMCustomEnums.UMCustomWidgetType.textView.name())) {
            TextView textView = generateCustomTextView(customWidgetObject);
            authHelper.addAuthRegistViewConfig(customWidgetObject.optString("widgetId"),
                    new UMAuthRegisterViewConfig.Builder()
                            .setRootViewId(customWidgetObject.optInt("rootViewId"))
                            .setView(textView)
                            .setCustomInterface(new UMCustomInterface() {
                                @Override
                                public void onClick(Context context) {
                                    Log.d(TAG, customWidgetObject.optString("widgetId") + "click clicked.");
                                    mHandler.post(new Runnable() {
                                        @Override
                                        public void run() {
                                            if (channel != null) {
                                                try {
                                                    Map<String, String> map = new HashMap<>();
                                                    map.put("widgetId", customWidgetObject.optString("widgetId"));
                                                    channel.invokeMethod("onClickWidgetEvent", map);
                                                } catch (Throwable ignore) {
                                                }
                                            }
                                        }
                                    });
                                }
                            }).build());
        }
    }

    private Button generateCustomButton(JSONObject jsonObject) {
        Button customBtn = new Button(mContext);

        if (jsonObject.has("left")) {
            customBtn.setX(UmengVerifySdkUtils.dp2px(mContext, jsonObject.optInt("left")));
        }

        if (jsonObject.has("top")) {
            customBtn.setY(UmengVerifySdkUtils.dp2px(mContext, jsonObject.optInt("top")));
        }

        if (jsonObject.has("width")) {
            customBtn.setWidth(UmengVerifySdkUtils.dp2px(mContext, jsonObject.optInt("width")));
        }

        if (jsonObject.has("height")) {
            customBtn.setHeight(UmengVerifySdkUtils.dp2px(mContext, jsonObject.optInt("height")));
        }

        if (jsonObject.has("title")) {
            customBtn.setText(jsonObject.optString("title"));
        }

        if (jsonObject.has("titleFont")) {
            customBtn.setTextSize((float) jsonObject.optDouble("titleFont"));
        }

        if (jsonObject.has("textAlignment")) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                if (jsonObject.optString("textAlignment").equals(UMCustomEnums.UMCustomWidgetTextAlignmentType.left.name())) {
                    customBtn.setGravity(Gravity.LEFT);
                } else if (jsonObject.optString("textAlignment").equals(UMCustomEnums.UMCustomWidgetTextAlignmentType.right.name())) {
                    customBtn.setGravity(Gravity.RIGHT);
                } else if (jsonObject.optString("textAlignment").equals(UMCustomEnums.UMCustomWidgetTextAlignmentType.center.name())) {
                    customBtn.setGravity(Gravity.CENTER);
                }
            }
        }

        if (jsonObject.has("titleColor")) {
            customBtn.setTextColor(jsonObject.optInt("titleColor"));
        }

        if (jsonObject.has("backgroundColor")) {
            customBtn.setBackgroundColor(jsonObject.optInt("backgroundColor"));
        }

        if (jsonObject.has("isClickEnable")) {
            customBtn.setClickable(jsonObject.optBoolean("isClickEnable"));
        }

        if (jsonObject.has("btnBackgroundResource_android")) {
            customBtn.setBackgroundResource(mContext.getResources().getIdentifier(jsonObject.optString("btnBackgroundResource_android"), "drawable", mContext.getPackageName()));
        }


        return customBtn;
    }

    private TextView generateCustomTextView(JSONObject jsonObject) {
        TextView customTextView = new TextView(mContext);

        if (jsonObject.has("left")) {
            customTextView.setX(UmengVerifySdkUtils.dp2px(mContext, jsonObject.optInt("left")));
        }
        if (jsonObject.has("top")) {
            customTextView.setY(UmengVerifySdkUtils.dp2px(mContext, jsonObject.optInt("top")));
        }
        if (jsonObject.has("width")) {
            customTextView.setWidth(UmengVerifySdkUtils.dp2px(mContext, jsonObject.optInt("width")));
        }
        if (jsonObject.has("height")) {
            customTextView.setHeight(UmengVerifySdkUtils.dp2px(mContext, jsonObject.optInt("height")));
        }

        if (jsonObject.has("title")) {
            customTextView.setText(jsonObject.optString("title"));
        }
        if (jsonObject.has("titleFont")) {
            customTextView.setTextSize((float) jsonObject.optDouble("titleFont"));
        }
        if (jsonObject.has("textAlignment")) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                if (jsonObject.optString("textAlignment").equals(UMCustomEnums.UMCustomWidgetTextAlignmentType.left.name())) {
                    customTextView.setGravity(Gravity.LEFT);
                } else if (jsonObject.optString("textAlignment").equals(UMCustomEnums.UMCustomWidgetTextAlignmentType.right.name())) {
                    customTextView.setGravity(Gravity.RIGHT);
                } else if (jsonObject.optString("textAlignment").equals(UMCustomEnums.UMCustomWidgetTextAlignmentType.center.name())) {
                    customTextView.setGravity(Gravity.CENTER);
                }
            }
        }
        if (jsonObject.has("titleColor")) {
            customTextView.setTextColor(jsonObject.optInt("titleColor"));
        }
        if (jsonObject.has("backgroundColor")) {
            customTextView.setBackgroundColor(jsonObject.optInt("backgroundColor"));
        }
        if (jsonObject.has("isClickEnable")) {
            customTextView.setClickable(jsonObject.optBoolean("isClickEnable"));
        }
        if (jsonObject.has("isShowUnderline")) {
            if (jsonObject.optBoolean("isShowUnderline")) {
                customTextView.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG); //下划线
            }
        }
        if (jsonObject.has("lines")) {
            customTextView.setMaxLines(jsonObject.optInt("lines"));
        }

        return customTextView;
    }

    private final Handler mHandler = new Handler(Looper.getMainLooper());

    private void executeOnMain(final Result result, final Object param) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            try {
                result.success(param);
            } catch (Throwable throwable) {
                throwable.printStackTrace();
            }
            return;
        }
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                try {
                    result.success(param);
                } catch (Throwable throwable) {
                    throwable.printStackTrace();
                }
            }
        });
    }

}
