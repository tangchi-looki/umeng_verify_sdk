#import "UmengVerifySdkPlugin.h"
#import <UMVerify/UMCommonHandler.h>
#import <UMVerify/UMCommonUtils.h>
#import <UMVerify/UMCustomModel.h>

#define UIColorFromRGB(rgbValue)  ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

// --- 私有接口声明：确保所有实例方法在类中可见 ---
@interface UmengVerifySdkPlugin ()
@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, weak) NSObject<FlutterPluginRegistrar> *registrar;
@property (nonatomic, strong) NSMutableDictionary *customWidgetIdDic;

- (BOOL)handleVerifyLogic:(FlutterMethodCall*)call result:(FlutterResult)result;
- (UMCustomModel *)getUMCustomModel:(NSDictionary *)dic;
- (UIButton *)customButtonWidget:(NSDictionary *)widgetDic;
- (UILabel *)customTextWidget:(NSDictionary *)widgetDic;
- (id)getValue:(NSDictionary *)dict key:(NSString*)key;
- (NSString *)safeString:(id)obj;
- (id)JSONValue:(NSString *)string;
- (NSTextAlignment)getTextAlignment:(NSString *)aligement;
- (UIControlContentHorizontalAlignment)getButtonTitleAlignment:(NSString *)aligement;
@end

@implementation UmengVerifySdkPlugin

#pragma mark - 插件注册入口
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"umeng_verify_sdk" binaryMessenger:[registrar messenger]];
    
    UmengVerifySdkPlugin* instance = [[UmengVerifySdkPlugin alloc] init];
    instance.channel = channel;
    instance.registrar = registrar;
    instance.customWidgetIdDic = [NSMutableDictionary dictionary];
    
    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar publish:instance];
}

#pragma mark - MethodCall 主入口
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    @try {
        BOOL handled = [self handleVerifyLogic:call result:result];
        if (!handled) {
            result(FlutterMethodNotImplemented);
        }
    } @catch (NSException *exception) {
        NSLog(@"UmengVerifySdkPlugin Crash Prevented: %@", exception.reason);
        result([FlutterError errorWithCode:@"IOS_NATIVE_EXCEPTION" message:exception.reason details:nil]);
    }
}

#pragma mark - 核心业务分发 (100% 还原老代码功能)
- (BOOL)handleVerifyLogic:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSArray* arguments = (NSArray *)call.arguments;
    // 安全校验：确保参数是数组，防止 [arguments[1]] 时 nil 崩溃
    if (arguments != nil && ![arguments isKindOfClass:[NSArray class]]) {
        result([FlutterError errorWithCode:@"BAD_ARGS" message:@"Arguments must be an NSArray" details:nil]);
        return YES;
    }

    __weak typeof(self) weakSelf = self;
    BOOL resultCode = YES;

    if ([@"getVerifyVersion" isEqualToString:call.method]){
        result([UMCommonHandler getVersion] ?: @"");
    }
    else if ([@"setVerifySDKInfo" isEqualToString:call.method]){
        NSString* info = (arguments.count > 1) ? [self safeString:arguments[1]] : nil;
        [UMCommonHandler setVerifySDKInfo:info complete:^(NSDictionary * _Nonnull resultDic) {
            result(resultDic ?: @{});
        }];
    }
    else if ([@"getLoginTokenWithTimeout" isEqualToString:call.method]){
        if (arguments.count < 2) { result(nil); return YES; }
        int timeout = [arguments[0] intValue];
        NSString *modelStr = [self safeString:arguments[1]];
        UMCustomModel *model = [[UMCustomModel alloc] init];
        NSDictionary *dic = [self JSONValue:modelStr];
        if (dic && [dic count] > 0) {
            model = [self getUMCustomModel:dic];
        }
        
        UIViewController *vc = self.registrar.viewController ?: [UIApplication sharedApplication].keyWindow.rootViewController;
        [UMCommonHandler getLoginTokenWithTimeout:timeout controller:vc model:model complete:^(NSDictionary * _Nonnull resultDic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.channel invokeMethod:@"getLoginToken" arguments:resultDic];
            });
        }];
    }
    else if ([@"checkEnvAvailableWithAuthType" isEqualToString:call.method]){
        NSString *authType = (arguments.count > 0) ? [self safeString:arguments[0]] : @"";
        int type = [authType isEqualToString:@"UMPNSAuthTypeVerifyToken"] ? UMPNSAuthTypeVerifyToken : UMPNSAuthTypeLoginToken;
        [UMCommonHandler checkEnvAvailableWithAuthType:type complete:^(NSDictionary * _Nullable resultDic) {
            result(resultDic ?: @{});
        }];
    }
    else if ([@"accelerateVerifyWithTimeout" isEqualToString:call.method]){
        int timeout = (arguments.count > 0) ? [arguments[0] intValue] : 5000;
        [UMCommonHandler accelerateVerifyWithTimeout:timeout complete:^(NSDictionary * _Nonnull resultDic) {
            result(resultDic ?: @{});
        }];
    }
    else if ([@"getVerifyTokenWithTimeout" isEqualToString:call.method]){
        int timeout = (arguments.count > 0) ? [arguments[0] intValue] : 5000;
        [UMCommonHandler getVerifyTokenWithTimeout:timeout complete:^(NSDictionary * _Nonnull resultDic) {
            result(resultDic ?: @{});
        }];
    }
    else if ([@"accelerateLoginPageWithTimeout" isEqualToString:call.method]){
        int timeout = (arguments.count > 0) ? [arguments[0] intValue] : 5000;
        [UMCommonHandler accelerateLoginPageWithTimeout:timeout complete:^(NSDictionary * _Nonnull resultDic) {
            result(resultDic ?: @{});
        }];
    }
    else if ([@"debugLoginUIWithController" isEqualToString:call.method]){
        UIViewController *vc = self.registrar.viewController ?: [UIApplication sharedApplication].keyWindow.rootViewController;
        [UMCommonHandler debugLoginUIWithController:vc model:nil complete:^(NSDictionary * _Nonnull resultDic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.channel invokeMethod:@"getLoginToken" arguments:resultDic];
            });
        }];
    }
    else if ([@"hideLoginLoading" isEqualToString:call.method]){
        [UMCommonHandler hideLoginLoading];
        result(nil);
    }
    else if ([@"getVerifyId" isEqualToString:call.method]){
        result([UMCommonHandler getVerifyId] ?: @"");
    }
    else if ([@"cancelLoginVCAnimated" isEqualToString:call.method]){
        BOOL flag = (arguments.count > 0) ? [arguments[0] boolValue] : YES;
        [UMCommonHandler cancelLoginVCAnimated:flag complete:^{}];
        result(@(YES));
    }
    else if ([@"checkDeviceCellularDataEnable" isEqualToString:call.method]){
        result(@([UMCommonUtils checkDeviceCellularDataEnable]));
    }
    else if ([@"isChinaUnicom" isEqualToString:call.method]){
        result(@([UMCommonUtils isChinaUnicom]));
    }
    else if ([@"isChinaMobile" isEqualToString:call.method]){
        result(@([UMCommonUtils isChinaMobile]));
    }
    else if ([@"isChinaTelecom" isEqualToString:call.method]){
        result(@([UMCommonUtils isChinaTelecom]));
    }
    else if ([@"getCurrentCarrierName" isEqualToString:call.method]){
        result([UMCommonUtils getCurrentCarrierName] ?: @"UNKNOWN");
    }
    else if ([@"getNetworkType" isEqualToString:call.method]){
        result([UMCommonUtils getNetworktype] ?: @"UNKNOWN");
    }
    else if ([@"simSupportedIsOK" isEqualToString:call.method]){
        result(@([UMCommonUtils simSupportedIsOK]));
    }
    else if ([@"isWWANOpen" isEqualToString:call.method]){
        result(@([UMCommonUtils isWWANOpen]));
    }
    else if ([@"reachableViaWWAN" isEqualToString:call.method]){
        result(@([UMCommonUtils reachableViaWWAN]));
    }
    else if ([@"getMobilePrivateIPAddress" isEqualToString:call.method]){
        BOOL preferIPv4 = (arguments.count > 0) ? [arguments[0] boolValue] : YES;
        result([UMCommonUtils getMobilePrivateIPAddress:preferIPv4] ?: @"");
    }
    else{
        resultCode = NO;
    }
    return resultCode;
}

#pragma mark - UI 配置映射 (还原老代码的样式设置)
- (UMCustomModel *)getUMCustomModel:(NSDictionary *)dic {
    UMCustomModel *model = [[UMCustomModel alloc] init];
    
    // 1. 基础配置
    if ([dic[@"isAutorotate"] boolValue]) model.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    
    // 2. 弹窗样式解析 (带长度保护)
    if (dic[@"contentViewFrame"]) {
        NSArray *arr = dic[@"contentViewFrame"];
        if (arr.count >= 4) {
            model.contentViewFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
                return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
            };
        }
    }
    if (dic[@"alertBlurViewColor"]) model.alertBlurViewColor = UIColorFromRGB([dic[@"alertBlurViewColor"] intValue]);
    if (dic[@"alertBlurViewAlpha"]) model.alertBlurViewAlpha = [dic[@"alertBlurViewAlpha"] doubleValue];
    if (dic[@"alertContentViewColor"]) model.alertContentViewColor = UIColorFromRGB([dic[@"alertContentViewColor"] intValue]);
    
    // 3. 导航栏配置
    model.navIsHidden = [dic[@"navIsHidden"] boolValue];
    if (dic[@"navColor"]) model.navColor = UIColorFromRGB([dic[@"navColor"] intValue]);
    if (dic[@"navTitle"]) {
        NSArray *arr = dic[@"navTitle"];
        if (arr.count >= 3) {
            model.navTitle = [[NSAttributedString alloc] initWithString:arr[0] attributes:@{NSForegroundColorAttributeName : UIColorFromRGB([arr[1] intValue]), NSFontAttributeName : [UIFont systemFontOfSize:[arr[2] doubleValue]]}];
        }
    }
    if (dic[@"navBackImage"]) model.navBackImage = [UIImage imageNamed:dic[@"navBackImage"]];

    // 4. Logo & Number
    if (dic[@"logoImage"]) model.logoImage = [UIImage imageNamed:dic[@"logoImage"]];
    model.logoIsHidden = [dic[@"logoIsHidden"] boolValue];
    if (dic[@"numberColor"]) model.numberColor = UIColorFromRGB([dic[@"numberColor"] intValue]);
    if (dic[@"numberFont"]) model.numberFont = [UIFont systemFontOfSize:[dic[@"numberFont"] doubleValue]];
    
    // 5. 自定义 Widget
    if (dic[@"customWidget"]) {
        NSArray *arr = dic[@"customWidget"];
        if ([arr isKindOfClass:[NSArray class]] && arr.count > 0) {
            NSMutableArray *widgetArr = [[NSMutableArray alloc] init];
            for (NSDictionary *widgetDic in arr) {
                if (![widgetDic isKindOfClass:[NSDictionary class]]) continue;
                if ([widgetDic[@"type"] isEqualToString:@"button"]) {
                    [widgetArr addObject:[self customButtonWidget:widgetDic]];
                } else if ([widgetDic[@"type"] isEqualToString:@"textView"]) {
                    [widgetArr addObject:[self customTextWidget:widgetDic]];
                }
            }
            model.customViewBlock = ^(UIView *superCustomView) {
                for (UIView *view in widgetArr) { [superCustomView addSubview:view]; }
            };
        }
    }
    return model;
}

#pragma mark - 自定义控件 Button/Label (安全版)
- (UIButton *)customButtonWidget:(NSDictionary *)widgetDic {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSInteger left = [[self getValue:widgetDic key:@"left"] integerValue];
    NSInteger top = [[self getValue:widgetDic key:@"top"] integerValue];
    NSInteger width = [[self getValue:widgetDic key:@"width"] integerValue];
    NSInteger height = [[self getValue:widgetDic key:@"height"] integerValue];
    button.frame = CGRectMake(left, top, width, height);

    NSString *title = [self safeString:[self getValue:widgetDic key:@"title"]];
    if (title) [button setTitle:title forState:UIControlStateNormal];
    
    NSNumber *titleColor = [self getValue:widgetDic key:@"titleColor"];
    if (titleColor) [button setTitleColor:UIColorFromRGB([titleColor integerValue]) forState:UIControlStateNormal];

    NSString *widgetId = [self safeString:[self getValue:widgetDic key:@"widgetId"]] ?: @"";
    NSString *tag = [NSString stringWithFormat:@"%ld", (long)(left + top + width)];
    button.tag = [tag integerValue];
    
    [self.customWidgetIdDic setObject:widgetId forKey:tag];
    [button addTarget:self action:@selector(clickCustomWidgetAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UILabel *)customTextWidget:(NSDictionary *)widgetDic {
    UILabel *label = [[UILabel alloc] init];
    NSInteger left = [[self getValue:widgetDic key:@"left"] integerValue];
    NSInteger top = [[self getValue:widgetDic key:@"top"] integerValue];
    NSInteger width = [[self getValue:widgetDic key:@"width"] integerValue];
    NSInteger height = [[self getValue:widgetDic key:@"height"] integerValue];
    label.frame = CGRectMake(left, top, width, height);
    label.text = [self safeString:[self getValue:widgetDic key:@"title"]];
    
    if ([[self getValue:widgetDic key:@"isClickEnable"] boolValue]) {
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTextWidgetAction:)];
        [label addGestureRecognizer:tap];
        NSString *tag = [NSString stringWithFormat:@"%ld", (long)(left + top + width)];
        tap.view.tag = [tag integerValue];
        [self.customWidgetIdDic setObject:([self getValue:widgetDic key:@"widgetId"] ?: @"") forKey:tag];
    }
    return label;
}

#pragma mark - 回调与工具方法
- (void)clickCustomWidgetAction:(UIButton *)button {
    NSString *tag = [NSString stringWithFormat:@"%ld", (long)button.tag];
    NSString *widgetId = [self.customWidgetIdDic objectForKey:tag];
    if (widgetId) {
        [self.channel invokeMethod:@"onClickWidgetEvent" arguments:@{@"widgetId": widgetId}];
    }
}

- (void)clickTextWidgetAction:(UITapGestureRecognizer *)gesture {
    NSString *tag = [NSString stringWithFormat:@"%ld", (long)gesture.view.tag];
    NSString *widgetId = [self.customWidgetIdDic objectForKey:tag];
    if (widgetId) {
        [self.channel invokeMethod:@"onClickWidgetEvent" arguments:@{@"widgetId": widgetId}];
    }
}

- (id)getValue:(NSDictionary *)dict key:(NSString*)key {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    id val = dict[key];
    return (val == [NSNull null]) ? nil : val;
}

- (NSString *)safeString:(id)obj {
    if (obj == nil || obj == [NSNull null]) return nil;
    if ([obj isKindOfClass:[NSString class]]) return obj;
    if ([obj isKindOfClass:[NSNumber class]]) return [obj stringValue];
    return nil;
}

- (id)JSONValue:(NSString *)string {
    if (!string || ![string isKindOfClass:[NSString class]] || string.length == 0) return nil;
    NSError *error = nil;
    id res = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    return error ? nil : res;
}

// 辅助转换对齐方式
- (NSTextAlignment)getTextAlignment:(NSString *)aligement {
    if ([aligement isEqualToString:@"center"]) return NSTextAlignmentCenter;
    if ([aligement isEqualToString:@"right"]) return NSTextAlignmentRight;
    return NSTextAlignmentLeft;
}

- (UIControlContentHorizontalAlignment)getButtonTitleAlignment:(NSString *)aligement {
    if ([aligement isEqualToString:@"left"]) return UIControlContentHorizontalAlignmentLeft;
    if ([aligement isEqualToString:@"right"]) return UIControlContentHorizontalAlignmentRight;
    return UIControlContentHorizontalAlignmentCenter;
}

@end
