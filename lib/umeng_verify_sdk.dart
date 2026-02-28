import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/services.dart';

/*
* 自定义 UI 界面配置类
* */

/// 自定义UI文本对齐方式
enum UMTextAlignment {
  left,
  center,
  right,
}

/// 自定义控件添加位置
enum UMRootViewId { body, title_bar, number }

/// 添加自定义控件类型，目前只支持 textView
enum UMCustomWidgetType { textView, button }

/// 自定义控件文本对齐方式
enum UMCustomWidgetTextAlignmentType { left, right, center }

//自定义控件
class UMCustomWidget {
  String? widgetId;
  UMCustomWidgetType? type;

  UMCustomWidget(this.widgetId, this.type) {
    widgetId = widgetId;
    type = type;
    if (type == UMCustomWidgetType.button) {
      isClickEnable = true;
    } else {
      isClickEnable = false;
    }
  }

  int left = 0;
  int top = 0;
  int width = 0;
  int height = 0;

  String title = '';
  double titleFont = 13.0;
  int titleColor = 0;
  int? backgroundColor;

  UMCustomWidgetTextAlignmentType? textAlignment;

  /// button 独有字段 start
  String? btnNormalImageName_ios;
  String? btnPressedImageName_ios;

  ///android独有，使用时需要设置
  String? btnBackgroundResource_android;
  bool isClickEnable = false; //是否可点击，默认：不可点击
  /// button 独有字段 end

  UMRootViewId? rootViewId;

  ///textview 独有字段 start
  int lines = 1; // textView 行数
  bool isSingleLine = true; // textView 是否单行显示，默认：单行
  bool isShowUnderline = false; //是否显示下划线，默认：不显示
  ///textview 独有字段 end

  Map toJsonMap() {
    return {
      'widgetId': widgetId,
      'type': getStringFromEnum(type),
      'title': title,
      'titleFont': titleFont,
      'textAlignment': getStringFromEnum(textAlignment),
      'titleColor': titleColor,
      'backgroundColor': backgroundColor,
      'isShowUnderline': isShowUnderline,
      'isClickEnable': isClickEnable,
      'btnNormalImageName': btnNormalImageName_ios,
      'btnPressedImageName': btnPressedImageName_ios,
      'btnBackgroundResource_android': btnBackgroundResource_android,
      'lines': lines,
      'isSingleLine': isSingleLine,
      'left': left,
      'top': top,
      'width': width,
      'height': height,
      'rootViewId': rootViewId?.index,
    }..removeWhere((key, value) => value == null);
  }
}

//自定义UI
class UMCustomModel {
  /**
   *  ios : 实现弹窗的方案 x > 0 || y > 0 width < 屏幕宽度 || height < 屏幕高度
   *
   *  android: 弹窗模式务必设置width和height， 若不希望设置偏移量，请将x、y设置为-1
   */
  List<double>? contentViewFrame; //传入4个值，分别是x，y，width，height

  bool isAutorotate = false; //是否支持横竖屏，true:支持横竖屏，false：只支持竖屏

  /**
   *  仅弹窗模式属性
   */

  int? alertBlurViewColor_ios; //底部蒙层背景颜色，默认黑色
  double? alertBlurViewAlpha_ios; //底部蒙层背景透明度，默认0.5
  int? alertContentViewColor_ios; //contentView背景颜色，默认白色

  int? alertTitleBarColor_ios; //标题栏背景颜色
  bool alertBarIsHidden_ios = false; //标题栏是否隐藏，默认NO

  ///标题栏标题，string 内容，int 颜色，double 大小
  List? alertTitle_ios;

  String? alertCloseImage_ios; //标题栏右侧关闭按钮图片设置
  bool alertCloseItemIsHidden_ios = false; //标题栏右侧关闭按钮是否显示，默认NO
  List<double>?
      alertTitleBarFrame_ios; //构建标题栏的frame，view布局或布局发生变化时调用，不实现则按默认处理，实现时仅有height生效，传入4个值，分别是x，y，width，height
  List<double>?
      alertTitleFrame_ios; //构建标题栏标题的frame，view布局或布局发生变化时调用，不实现则按默认处理 ，传入4个值，分别是x，y，width，height
  List<double>?
      alertCloseItemFrame_ios; //构建标题栏右侧关闭按钮的frame，view布局或布局发生变化时调用，不实现则按默认处理，实现时仅有height生效，传入4个值，分别是x，y，width，height

  /**
   *  导航栏（ios只对全屏模式有效, android对全屏和弹窗均生效）
   */

  bool navIsHidden = false; //导航栏是否隐藏
  bool navIsHiddenAfterLoginVCDisappear_ios =
      false; //授权页push到其他页面后，导航栏是否隐藏，默认NO
  int? navColor; //导航栏主题色

  ///导航栏标题，string 内容，int 颜色，double 大小
  List? navTitle;

  String? navBackImage; //导航栏返回图片
  bool hideNavBackItem = false; //是否隐藏授权页导航栏返回按钮，默认不隐藏

  /// android系统上不支持设置x,y坐标，需要将navBackButtonFrame中x,y设置为-1
  List<double>?
      navBackButtonFrame; //构建导航栏返回按钮的frame，view布局或布局发生变化时调用，不实现则按默认处理 ，传入4个值，分别是x，y，width，height

  List<double>?
      navTitleFrame_ios; //构建导航栏标题的frame，view布局或布局发生变化时调用，不实现则按默认处理，传入4个值，分别是x，y，width，height
  List<double>?
      navMoreViewFrameFrame_ios; //构建导航栏右侧more view的frame，view布局或布局发生变化时调用，不实现则按默认处理，传入4个值，分别是x，y，width，height

  /**
   *  全屏、弹窗模式共同属性
   *  授权页弹出方向
   */

  double?
      animationDuration_ios; //授权页显示和消失动画时间，默认为0.25s，<= 0 时关闭动画，该属性只对自带动画起效，不影响自定义动画

  /**
   *  状态栏
   */
  bool prefersStatusBarHidden = false; //状态栏是否隐藏，默认NO

  /**
   *  背景
   */
  int? backgroundColor_ios; //授权页背景色
  String? backgroundImage; //授权页背景图片

  /**
   *  logo图片
   */
  String? logoImage; //logo图片设置
  bool logoIsHidden = false; //logo是否隐藏，默认NO

  ///构建logo的frame，view布局或布局发生变化时调用，不实现则按默认处理,传入4个值.
  /// ios : 分别是x，y，width，height
  /// android: y1:logo控件相对导航栏顶部位移  y2:logo控件相对底部位移 （y1,y2仅支持设置一个，需将不需要的设置为-1）  width, height
  List<double>? logoFrame;

  /**
   *  slogan
   */

  ///slogan文案，string 内容，int 颜色，double 大小
  List? sloganText;

  bool sloganIsHidden = false; //slogan是否隐藏，默认NO

  /// 构建slogan的frame，view布局或布局发生变化时调用，不实现则按默认处理，传入4个值
  /// ios: 分别是x，y，width，height
  /// android:  y1:logo控件相对导航栏顶部位移  y2:logo控件相对底部位移 （y1,y2仅支持设置一个，需将不需要的设置为-1）, width:-1, height:-1
  List<double>? sloganFrame;

  /**
   *  号码
   */
  int? numberColor; //号码颜色设置
  double? numberFont; //号码字体大小设置，大小小于16则不生效

  /// 构建号码的frame，view布局或布局发生变化时调用，只有x、y生效，不实现则按默认处理
  /// ios: 传入4个值，分别是x，y，width，height
  /// android: 传入4个值，分别是x, y1, y2, -1  x:横坐标 y1:logo控件相对导航栏顶部位移  y2:logo控件相对底部位移 （y1,y2仅支持设置一个，需将不需要的设置为-1）
  List<double>? numberFrame;

  /**
   *  登录
   */

  ///登陆按钮文案，string 内容，int 颜色，double 大小
  List? loginBtnText;

  List<String>?
      loginBtnBgImgs_ios; //登录按钮背景图片组，默认高度50.0pt，@[激活状态的图片,失效状态的图片,高亮状态的图片]

  String? loginBtnBgImg_android; // 登录按钮背景图片名称

  bool autoHideLoginLoading = true; //是隐藏点击登录按钮之后授权页上转圈的 loading, 默认为YES

  ///构建登录按钮的frame，view布局或布局发生变化时调用，不实现则按默认处理，
  /// ios 传入5个值，分别是x，y，-1,width，height
  /// android 传入5个值，分别是x,y1,y2,width,height  x:横坐标 y1:logo控件相对导航栏顶部位移  y2:logo控件相对底部位移 （y1,y2仅支持设置一个，需将不需要的设置为-1）
  List<double>? loginBtnFrame;

  /**
   *  协议
   */
  List<String>? checkBoxImages; //checkBox图片组，[uncheckedImg,checkedImg]

  List<double>?
      checkBoxImageEdgeInsets_ios; //checkBox图片距离控件边框的填充，确保控件大小减去内填充大小为资源图片大小情况下，图片才不会变形 ,top,left,bottom,right
  bool checkBoxIsChecked = false; //checkBox是否勾选，默认NO
  bool checkBoxIsHidden = false; //checkBox是否隐藏，默认NO
  double? checkBoxWH; //checkBox大小，高宽一样，必须大于0
  List<String>? privacyOne; //协议1，[协议名称,协议Url]，注：两个协议名称不能相同
  List<String>? privacyTwo; //协议2，[协议名称,协议Url]，注：两个协议名称不能相同
  List<String>? privacyThree; //协议3，[协议名称,协议Url]，注：三个协议名称不能相同
  List<String>?
      privacyConectTexts; //协议名称之间连接字符串数组，默认 ["和","、","、"] ，即第一个为"和"，其他为"、"，按顺序读取，为空则取默认


  List<int>? privacyColors; //协议内容颜色数组，[非点击文案颜色，点击文案颜色]
  UMTextAlignment? privacyAlignment; // 协议文案支持居中、居左设置，默认居左
  String? privacyPreText; //协议整体文案，前缀部分文案
  String? privacySufText; //协议整体文案，后缀部分文案
  String? privacyOperatorPreText; //运营商协议名称前缀文案，仅支持 <([《（【『
  String? privacyOperatorSufText; //运营商协议名称后缀文案，仅支持 >)]》）】』
  int? privacyOperatorIndex; //运营商协议指定显示顺序，默认0，即第1个协议显示，最大值可为3，即第4个协议显示
  double? privacyFont; //协议整体文案字体大小，小于12.0不生效

  /// 构建changeBtn的frame，view布局或布局发生变化时调用，不实现则按默认处理
  /// ios: 传入4个值，分别是x，y，width，height
  /// android: 传入4个值，分别是x, y1, y2, -1  x:横坐标 y1:logo控件相对导航栏顶部位移  y2:logo控件相对底部位移 （y1,y2仅支持设置一个，需将不需要的设置为-1）
  List<double>? privacyFrame;

  /**
   *  切换到其他方式
   */

  ///changeBtn标题，string 内容，int 颜色，double 大小
  List? changeBtnTitle;

  bool changeBtnIsHidden = false; //changeBtn是否隐藏，默认NO

  /// iOS：传入4个值，分别是x，y，width，height
  /// android: 传入4个值：y1,y2,-1，-1  y1:logo控件相对导航栏顶部位移  y2:logo控件相对底部位移 （y1,y2仅支持设置一个，需将不需要的设置为-1）
  List<double>? changeBtnFrame;

  /**
   *  协议详情页
   */

  bool privacyVCIsCustomized_ios =
      false; //协议详情页容器是否自定义，默认NO，若为YES，则根据 PNSCodeLoginControllerClickProtocol 返回码获取协议点击详情信息

  /// android 独有
  /// 使用
  String? protocolAction_android; //自定义协议页跳转Action

  int? privacyNavColor; //导航栏背景颜色设置
  double? privacyNavTitleFont; //导航栏标题字体、大小
  int? privacyNavTitleColor; //导航栏标题颜色
  String? privacyNavBackImage; //导航栏返回图片

  /**
   *  自定义控件，目前支持button,textView
   */
  List? customWidget;

  Map toJsonMap() {
    return {
      'contentViewFrame': contentViewFrame ??= null,
      'isAutorotate': isAutorotate,
      'alertBlurViewColor': alertBlurViewColor_ios ??= null,
      'alertBlurViewAlpha': alertBlurViewAlpha_ios ??= null,
      'alertContentViewColor': alertContentViewColor_ios ??= null,
      'alertTitleBarColor': alertTitleBarColor_ios ??= null,
      'alertBarIsHidden': alertBarIsHidden_ios,
      'alertTitle': alertTitle_ios ??= null,
      'alertCloseImage': alertCloseImage_ios ??= null,
      'alertCloseItemIsHidden': alertCloseItemIsHidden_ios,
      'alertTitleBarFrame': alertTitleBarFrame_ios ??= null,
      'alertTitleFrame': alertTitleFrame_ios ??= null,
      'alertCloseItemFrame': alertCloseItemFrame_ios ??= null,
      'navIsHidden': navIsHidden,
      'navIsHiddenAfterLoginVCDisappear': navIsHiddenAfterLoginVCDisappear_ios,
      'navColor': navColor ??= null,
      'navTitle': navTitle ??= null,
      'navBackImage': navBackImage ??= null,
      'hideNavBackItem': hideNavBackItem,
      'navBackButtonFrame': navBackButtonFrame ??= null,
      'navTitleFrame': navTitleFrame_ios ??= null,
      'navMoreViewFrameFrame': navMoreViewFrameFrame_ios ??= null,
      'animationDuration': animationDuration_ios ??= null,
      'prefersStatusBarHidden': prefersStatusBarHidden,
      'backgroundColor': backgroundColor_ios ??= null,
      'backgroundImage': backgroundImage ??= null,
      'logoImage': logoImage ??= null,
      'logoIsHidden': logoIsHidden,
      'logoFrame': logoFrame ??= null,
      'sloganText': sloganText ??= null,
      'sloganIsHidden': sloganIsHidden,
      'sloganFrame': sloganFrame ??= null,
      'numberColor': numberColor ??= null,
      'numberFont': numberFont ??= null,
      'numberFrame': numberFrame ??= null,
      'loginBtnText': loginBtnText ??= null,
      'loginBtnBgImgs': loginBtnBgImgs_ios ??= null,
      'loginBtnBgImg_android': loginBtnBgImg_android ??= null,
      'autoHideLoginLoading': autoHideLoginLoading,
      'loginBtnFrame': loginBtnFrame,
      'checkBoxImages': checkBoxImages ??= null,
      'checkBoxImageEdgeInsets': checkBoxImageEdgeInsets_ios ??= null,
      'checkBoxIsChecked': checkBoxIsChecked,
      'checkBoxIsHidden': checkBoxIsHidden,
      'checkBoxWH': checkBoxWH ??= null,
      'privacyOne': privacyOne ??= null,
      'privacyTwo': privacyTwo ??= null,
      'privacyThree': privacyThree ??= null,
      'privacyConectTexts': privacyConectTexts ??= null,
      'privacyColors': privacyColors ??= null,
      'privacyAlignment': getStringFromEnum(privacyAlignment),
      'privacyPreText': privacyPreText ??= null,
      'privacySufText': privacySufText ??= null,
      'privacyOperatorPreText': privacyOperatorPreText ??= null,
      'privacyOperatorSufText': privacyOperatorSufText ??= null,
      'privacyOperatorIndex': privacyOperatorIndex ??= null,
      'privacyFont': privacyFont ??= null,
      'privacyFrame': privacyFrame ??= null,
      'changeBtnTitle': changeBtnTitle ??= null,
      'changeBtnIsHidden': changeBtnIsHidden,
      'changeBtnFrame': changeBtnFrame ??= null,
      'privacyVCIsCustomized': privacyVCIsCustomized_ios,
      'protocolAction_android': protocolAction_android ??= null,
      'privacyNavColor': privacyNavColor ??= null,
      'privacyNavTitleFont': privacyNavTitleFont ??= null,
      'privacyNavTitleColor': privacyNavTitleColor ??= null,
      'privacyNavBackImage': privacyNavBackImage ??= null,
      'customWidget': customWidget ??= null,
    }..removeWhere((key, value) => value == null);
  }
}

String getStringFromEnum<T>(T) {
  if (T == null) {
    return '';
  }

  return T.toString().split('.').last;
}

enum UMEnvCheckType { type_auth, type_login }

class UmengVerifySdk {
  static const MethodChannel _channel = MethodChannel('umeng_verify_sdk');

  static final _Callbacks _callback = _Callbacks(_channel);

  /// android独有，务必保证在所有接口前调用
  static void register_android() {
    _channel.invokeMethod('register');
  }

  static Future<String?> get VerifyVersion async {
    final String? version = await _channel.invokeMethod('getVerifyVersion');
    return version;
  }

  /**
   *  初始化SDK调用参数，app生命周期内调用一次
   *  @param  info app对应的秘钥
   *  @param  complete 结果异步回调到主线程，成功时resultDic=@{resultCode:600000, msg:...}，其他情况时"resultCode"值请参考PNSReturnCode
   */

  static Future<dynamic> setVerifySDKInfo(
      String androidInfo, String iosInfo) async {
    List<dynamic> params = [androidInfo, iosInfo];
    final dynamic result =
        await _channel.invokeMethod('setVerifySDKInfo', params);
    return result;
  }

  /**
   *  ios only
   *  检查当前环境是否支持一键登录或号码认证，resultDic 返回 PNSCodeSuccess 说明当前环境支持
   *  @param  authType 服务类型 UMPNSAuthTypeVerifyToken 本机号码校验流程，UMPNSAuthTypeLoginToken 一键登录流程,默认UMPNSAuthTypeLoginToken
   *  @param  complete 结果异步回调到主线程，成功时resultDic=@{resultCode:600000, msg:...}，其他情况时"resultCode"值请参考PNSReturnCode，只有成功回调才能保障后续接口调用
   */

  static Future<dynamic> checkEnvAvailableWithAuthType_ios(
      String authType) async {
    List<dynamic> params = [authType];

    final dynamic result =
        await _channel.invokeMethod('checkEnvAvailableWithAuthType', params);

    return result;
  }

  /// android only
  /// 检查当前环境是否支持一键登录或号码认证，通过[setTokenResultCallback_android]设置的监听回调结果
  /// 返回值格式示例如下：{msg: 终端支持认证, code: 600024, requestId: xxxx, requestCode: 0, vendorName: ct_sjl, carrierFailedResultData: }
  /// code值含义请参考文档
  static void checkEnvAvailable_android(UMEnvCheckType type) {
    if (type == UMEnvCheckType.type_auth) {
      _channel.invokeMethod('checkEnvAvailable', 1);
    } else {
      _channel.invokeMethod('checkEnvAvailable', 2);
    }
  }

  /**
   *  加速获取本机号码校验token，防止调用 getVerifyTokenWithTimeout:complete: 获取token时间过长
   *  @param  timeout 接口超时时间，单位s，默认为3.0s
   *  @param  complete 结果异步回调到主线程，
   *
   *  ios 成功时resultDic=@{resultCode:600000, token:..., msg:...}，其他情况时"resultCode"值请参考UMPNSReturnCode
   *
   *  android 成功是返回{vendor:xxx} 失败时返回{vendor:xxx, ret:xxxxx}
   */

  static Future<dynamic> accelerateVerifyWithTimeout(int timeout) async {
    List<dynamic> params = [timeout];

    final dynamic result =
        await _channel.invokeMethod('accelerateVerifyWithTimeout', params);

    return result;
  }

  /**
   *  获取本机号码校验Token
   *  @param  timeout 接口超时时间，单位s，默认为3.0s
   *  @param  complete 结果异步回调，
   *  iOS 成功时resultDic=@{resultCode:600000, token:..., msg:...}，其他情况时"resultCode"值请参考UMPNSReturnCode
   */
  static Future<dynamic> getVerifyTokenWithTimeout_ios(int timeout) async {
    List<dynamic> params = [timeout];

    final dynamic result =
        await _channel.invokeMethod('getVerifyTokenWithTimeout', params);

    return result;
  }

  /// android only
  /// 获取本机号码校验Token，通过[setTokenResultCallback_android]设置的监听回调结果
  /// 返回值格式示例如下：{msg: 获取token成功, code: 600000, requestId: xxx, requestCode: 0, vendorName: ct_sjl, carrierFailedResultData: , token: xxx}
  /// code值含义请参考文档
  static void getVerifyTokenWithTimeout_android(int timeout) {
    List<dynamic> params = [timeout];
    _channel.invokeMethod('getVerifyTokenWithTimeout', params);
  }

  ///  加速一键登录授权页弹起，防止调用 getLoginTokenWithTimeout:controller:model:complete: 等待弹起授权页时间过长
  ///  @param  timeout 接口超时时间，单位s，默认为3.0s
  ///  @param  complete 结果异步回调，
  ///  iOS 成功时resultDic=@{resultCode:600000, msg:...}，其他情况时"resultCode"值请参考UMPNSReturnCode
  ///
  ///  android 成功是返回{vendor:xxx} 失败时返回{vendor:xxx, ret:xxxxx}

  static Future<dynamic> accelerateLoginPageWithTimeout(int timeout) async {
    List<dynamic> params = [timeout];

    final dynamic result =
        await _channel.invokeMethod('accelerateLoginPageWithTimeout', params);

    return result;
  }

  ///
  ///  获取一键登录Token，调用该接口首先会弹起授权页，点击授权页的登录按钮获取Token
  ///  @warning 注意的是，如果前面没有调用 accelerateLoginPageWithTimeout:complete: 接口，该接口内部会自动先帮我们调用，成功后才会弹起授权页，所以有一个明显的等待过程
  ///  @param  timeout 接口超时时间，单位s，默认为3.0s
  ///  @param  controller 唤起自定义授权页的容器，内部会对其进行验证，检查是否符合条件
  ///  @param  model 自定义授权页面选项，可为nil，采用默认的授权页面，具体请参考UMCustomModel.h文件
  ///  @param  complete 结果异步回调，
  ///  iOS： "resultDic"里面的"resultCode"值请参考PNSReturnCode，如下：
  ///
  ///          授权页控件点击事件：700000（点击授权页返回按钮）、700001（点击切换其他登录方式）、
  ///          700002（点击登录按钮事件，根据返回字典里面的 "isChecked"字段来区分check box是否被选中，只有被选中的时候内部才会去获取Token）、700003（点击check box事件）、700004（点击协议富文本文字）
  /// 接口回调其他事件：600001（授权页唤起成功）、600002（授权页唤起失败）、600000（成功获取Token）、600011（获取Token失败）、
  ///          600015（获取Token超时）、600013（运营商维护升级，该功能不可用）、600014（运营商维护升级，该功能已达最大调用次数）.....
  ///
  /// android： 通过[setTokenResultCallback_android]设置的监听回调结果
  /// 返回值格式示例如下：{"carrierFailedResultData":"","code":"600001","msg":"唤起授权页成功","requestCode":0,"requestId":"xxx","vendorName":"ct_sjl"}
  /// code值含义请参考文档
  /// 注意：android 授权页控件点击事件单独通过[setUIClickCallback_android]回调

  static void getLoginTokenWithTimeout(int timeout, UMCustomModel uiConfig) {
    var dic = uiConfig.toJsonMap();
    String json = convert.jsonEncode(dic);
    List<dynamic> params = [timeout, json];

    _channel.invokeMethod('getLoginTokenWithTimeout', params);
  }

  /// SDK 完成回调后，不会立即关闭授权页面，需要开发者主动调用离开授权页面方法去完成页面的关闭
  static void quitLoginPage_android() {
    _channel.invokeMethod('quitLoginPage');
  }

  /**
   *  此接口仅用于开发期间用于一键登录页面不同机型尺寸适配调试（可支持模拟器），非正式页面，手机掩码为0，不能正常登录，请开发者注意下
   *  @param  controller 唤起自定义授权页的容器，内部会对其进行验证，检查是否符合条件
   *  @param  model 自定义授权页面选项，可为nil，采用默认的授权页面，具体请参考UMCustomModel.h文件
   *  @param  complete 结果异步回调到主线程，"resultDic"里面的"resultCode"值请参考PNSReturnCode
   */
  static Future<dynamic> debugLoginUIWithController() async {
    await _channel.invokeMethod('debugLoginUIWithController');
  }

  /**
   *  手动隐藏一键登录获取登录Token之后的等待动画，默认为自动隐藏，当设置 UMCustomModel 实例 autoHideLoginLoading = NO 时, 可调用该方法手动隐藏
   */
  static void hideLoginLoading() {
    _channel.invokeMethod('hideLoginLoading');
  }

  /**
   *  获取智能认证ID
   */
  static Future<String?> getVerifyId() async {
    return await _channel.invokeMethod('getVerifyId');
  }

  /**
   *  注销授权页，建议用此方法，对于移动卡授权页的消失会清空一些数据
   *  @param flag 是否添加动画
   *  @param complete 成功返回
   */
  static Future<dynamic> cancelLoginVCAnimated(bool flag) async {
    List<dynamic> params = [flag];
    await _channel.invokeMethod('cancelLoginVCAnimated', params);
  }

  /**
      ios独有
      判断当前设备蜂窝数据网络是否开启，即3G/4G
      @return 结果
   */
  static Future<bool?> checkDeviceCellularDataEnable() async {
    return await _channel.invokeMethod('checkDeviceCellularDataEnable');
  }

  /**
      ios独有
      判断当前上网卡运营商是否是中国联通
      @return 结果
   */
  static Future<bool?> isChinaUnicom() async {
    return await _channel.invokeMethod('isChinaUnicom');
  }

  /**
      ios独有
      判断当前上网卡运营商是否是中国移动
      @return 结果
   */
  static Future<bool?> isChinaMobile() async {
    return await _channel.invokeMethod('isChinaMobile');
  }

  /**
      ios独有
      判断当前上网卡运营商是否是中国电信
      @return 结果
   */
  static Future<bool?> isChinaTelecom() async {
    return await _channel.invokeMethod('isChinaTelecom');
  }

  /**
      获取当前上网卡运营商名称，比如中国移动
      @return 结果
   */
  static Future<String?> getCurrentCarrierName() async {
    return await _channel.invokeMethod('getCurrentCarrierName');
  }

  /**
      ios独有
      获取当前上网卡网络类型，比如WiFi，4G
      @return 结果
   */
  static Future<String?> getNetworkType() async {
    return await _channel.invokeMethod('getNetworkType');
  }

  /**
      ios独有
      判断当前上网卡运营商是否是中国电信
      @return 结果
   */
  static Future<bool?> simSupportedIsOK() async {
    return await _channel.invokeMethod('simSupportedIsOK');
  }

  /**
      ios独有
      判断wwan是否开着（通过p0网卡判断，无wifi或有wifi情况下都能检测到）
      @return 结果
   */
  static Future<bool?> isWWANOpen() async {
    return await _channel.invokeMethod('isWWANOpen');
  }

  /**
      ios独有
      判断wwan是否开着（仅无wifi情况下）
      @return 结果
   */
  static Future<bool?> reachableViaWWAN() async {
    return await _channel.invokeMethod('reachableViaWWAN');
  }

  /**
      ios独有
      获取设备当前网络私网IP地址
      @return 结果
   */
  static Future<String?> getMobilePrivateIPAddress(bool preferIPv4) async {
    List<dynamic> params = [preferIPv4];

    return await _channel.invokeMethod('getMobilePrivateIPAddress', params);
  }

  ///设置getLoginToken回调
  static void getLoginTokenCallback(Callback? callback) {
    _callback.tokenCallback = callback;
  }

  static void getWidgetEventCallback(Callback? callback) {
    _callback.widgetCallback = callback;
  }

  static void setTokenResultCallback_android(Callback? callback) {
    _callback.onTokenResult_android = callback;
  }

  static void setUIClickCallback_android(Callback? callback) {
    _callback.onUIClickCallback_android = callback;
  }
}

///定义回调
typedef Callback = void Function(Map result);

class _Callbacks {
  Callback? tokenCallback;
  Callback? widgetCallback;

  Callback? onTokenResult_android;
  Callback? onUIClickCallback_android;

  _Callbacks(MethodChannel channel) {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'getLoginToken') {
        var token = call.arguments;
        if (tokenCallback != null) {
          tokenCallback!(token);
        }
        return;
      }

      if (call.method == 'onClickWidgetEvent') {
        var arguments = call.arguments;
        if (widgetCallback != null) {
          widgetCallback!(arguments);
        }
        return;
      }

      if (call.method == 'onTokenResult') {
        var arguments = call.arguments;
        if (onTokenResult_android != null) {
          onTokenResult_android!(arguments);
        }
        return;
      }

      if (call.method == 'onUIClickCallback') {
        var arguments = call.arguments;
        if (onUIClickCallback_android != null) {
          onUIClickCallback_android!(arguments);
        }
      }
    });
  }
}
