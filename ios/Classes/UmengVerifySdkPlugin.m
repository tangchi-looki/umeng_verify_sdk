#import "UmengVerifySdkPlugin.h"
#import <UMVerify/UMCommonHandler.h>
#import <UMVerify/UMCommonUtils.h>
#import <UMVerify/UMCustomModel.h>
#define UIColorFromRGB(rgbValue)  ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

@interface UMengflutterpluginForVerify : NSObject

@property (nonatomic, strong) FlutterEngine *flutterEngine;
@property (nonatomic, strong) FlutterViewController *flutterVC;
@property (nonatomic, strong) FlutterMethodChannel *msgChannel;
@property(nonatomic, strong) NSMutableDictionary *customWidgetIdDic;


@end
@implementation UMengflutterpluginForVerify : NSObject


- (BOOL)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result registrar: (NSObject<FlutterPluginRegistrar>*)registrar{

   // self.msgChannel = [FlutterMethodChannel methodChannelWithName:@"umeng_common_sdk" binaryMessenger:self.flutterVC.binaryMessenger];
    self.msgChannel  = [FlutterMethodChannel methodChannelWithName:@"umeng_verify_sdk" binaryMessenger:[registrar messenger]];
    _msgChannel=self.msgChannel;
    __weak typeof(self) weakself = self;
    __strong typeof(weakself) strongself = weakself;

    BOOL resultCode = YES;
    NSArray* arguments = (NSArray *)call.arguments;
    if ([@"getVerifyVersion" isEqualToString:call.method]){
       
        result([UMCommonHandler getVersion]);
    }
    else if ([@"setVerifySDKInfo" isEqualToString:call.method]){
        NSString* info = arguments[1];
        [UMCommonHandler setVerifySDKInfo:info complete:^(NSDictionary * _Nonnull resultDic) {
            result(resultDic);

        }];
    }
    else if ([@"getLoginTokenWithTimeout" isEqualToString:call.method]){
        int timeout = [arguments[0] intValue];
        NSString *modelStr=arguments[1];
        UMCustomModel *model=[[UMCustomModel alloc]init];
        NSDictionary *dic=[self JSONValue:modelStr];
        if ([dic count]>0) {
            model=[self getUMCustomModel:dic];
        }
        
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;

        [UMCommonHandler getLoginTokenWithTimeout:timeout controller:vc model:model complete:^(NSDictionary * _Nonnull resultDic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongself.msgChannel invokeMethod:@"getLoginToken" arguments:resultDic];
            });
         

        }];
    }
    else if ([@"checkEnvAvailableWithAuthType" isEqualToString:call.method]){
        NSString *authType = arguments[0];
        int type;
        if ([authType isEqualToString:@"UMPNSAuthTypeVerifyToken"]) {
            type=UMPNSAuthTypeVerifyToken;
        }else{
            type=UMPNSAuthTypeLoginToken;
        }
        [UMCommonHandler checkEnvAvailableWithAuthType:type complete:^(NSDictionary * _Nullable resultDic) {
            result(resultDic);
        }];
    
         

    }
    else if ([@"accelerateVerifyWithTimeout" isEqualToString:call.method]){
        int timeout = [arguments[0] intValue];
    
        [UMCommonHandler accelerateVerifyWithTimeout:timeout complete:^(NSDictionary * _Nonnull resultDic) {
            result(resultDic);
        }];
    
         

    }
    else if ([@"getVerifyTokenWithTimeout" isEqualToString:call.method]){
        int timeout = [arguments[0] intValue];
    
        [UMCommonHandler getVerifyTokenWithTimeout:timeout complete:^(NSDictionary * _Nonnull resultDic) {
            result(resultDic);

        }];
    
         

    }
    else if ([@"accelerateLoginPageWithTimeout" isEqualToString:call.method]){
        int timeout = [arguments[0] intValue];
    
        [UMCommonHandler accelerateLoginPageWithTimeout:timeout complete:^(NSDictionary * _Nonnull resultDic) {
            result(resultDic);
        }];
    
         

    }
    else if ([@"debugLoginUIWithController" isEqualToString:call.method]){
        
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;

        [UMCommonHandler debugLoginUIWithController:vc model:nil complete:^(NSDictionary * _Nonnull resultDic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongself.msgChannel invokeMethod:@"getLoginToken" arguments:resultDic];
            });
            
        }];
           
         

    }
    else if ([@"hideLoginLoading" isEqualToString:call.method]){
        [UMCommonHandler hideLoginLoading];
    }
    else if ([@"getVerifyId" isEqualToString:call.method]){
       
        result([UMCommonHandler getVerifyId]);
    }
    else if ([@"cancelLoginVCAnimated" isEqualToString:call.method]){
        bool flag = [arguments[0] boolValue];
        [UMCommonHandler cancelLoginVCAnimated:flag complete:^{
            
        }];
    
         

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
       
        result([UMCommonUtils getCurrentCarrierName]);
    }
    else if ([@"getNetworkType" isEqualToString:call.method]){
       
        result([UMCommonUtils getNetworktype]);
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
       
        bool preferIPv4 = [arguments[0] boolValue];

        result([UMCommonUtils getMobilePrivateIPAddress:preferIPv4]);
    }
    else{
        resultCode = NO;
    }
    return resultCode;
}

- (id)JSONValue:(NSString *)string
{
    id result = nil;
    if (string!=nil && ![string isEqualToString:@""])
    {
        NSError* error = nil;
        result = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error]; //NSJSONReadingAllowFragments  kNilOptions
    }
    return result;
}

-(UMCustomModel *)getUMCustomModel:(NSDictionary *)dic
{
    UMCustomModel *model=[[UMCustomModel alloc]init];
    if ([dic[@"isAutorotate"] boolValue] == YES) {
        model.supportedInterfaceOrientations=UIInterfaceOrientationMaskAll;
    }
    if ([[dic allKeys] containsObject:@"contentViewFrame"]) {
        NSArray * arr=dic[@"contentViewFrame"];

        model.contentViewFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
            
            
            return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
        };
        
    }
    if ([[dic allKeys] containsObject:@"alertBlurViewColor"]) {
        int color=[dic[@"alertBlurViewColor"] intValue];
        model.alertBlurViewColor=UIColorFromRGB(color);
    }
    if ([[dic allKeys] containsObject:@"alertBlurViewAlpha"]) {
        model.alertBlurViewAlpha=[dic[@"alertBlurViewAlpha"] doubleValue];
    }
    if ([[dic allKeys] containsObject:@"alertContentViewColor"]) {
        int color=[dic[@"alertContentViewColor"] intValue];
        model.alertContentViewColor=UIColorFromRGB(color);
    }
  
    if ([[dic allKeys] containsObject:@"alertTitleBarColor"]) {
        int color=[dic[@"alertTitleBarColor"] intValue];
        model.alertTitleBarColor=UIColorFromRGB(color);
    }
    model.alertBarIsHidden=[dic[@"alertBarIsHidden"] boolValue];
    if ([[dic allKeys] containsObject:@"alertTitle"]) {
        NSArray * arr=dic[@"alertTitle"];
        model.alertTitle = [[NSAttributedString alloc] initWithString:arr[0] attributes:@{NSForegroundColorAttributeName : UIColorFromRGB([arr[1] intValue]),NSFontAttributeName : [UIFont systemFontOfSize:[arr[2] doubleValue]]}];

    }
    if ([[dic allKeys] containsObject:@"alertCloseImage"]) {
        model.alertCloseImage = [UIImage imageNamed:dic[@"alertCloseImage"]];

    }
    model.alertCloseItemIsHidden=[dic[@"alertCloseItemIsHidden"] boolValue];
    
    if ([[dic allKeys] containsObject:@"alertTitleBarFrame"]) {
        NSArray * arr=dic[@"alertTitleBarFrame"];
        model.alertTitleBarFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        
            return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
        };
        
    }
    if ([[dic allKeys] containsObject:@"alertTitleFrame"]) {
        NSArray * arr=dic[@"alertTitleFrame"];
        model.alertTitleFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        
            return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
        };
        
    }
    if ([[dic allKeys] containsObject:@"alertCloseItemFrame"]) {
        NSArray * arr=dic[@"alertCloseItemFrame"];
        model.alertCloseItemFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        
            return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
        };
        
    }
    model.navIsHidden=[dic[@"navIsHidden"] boolValue];
    model.navIsHiddenAfterLoginVCDisappear=[dic[@"navIsHiddenAfterLoginVCDisappear"] boolValue];
    if ([[dic allKeys] containsObject:@"navColor"]) {
        int color=[dic[@"navColor"] intValue];
        model.navColor=UIColorFromRGB(color);
    }
    if ([[dic allKeys] containsObject:@"navTitle"]) {
        NSArray * arr=dic[@"navTitle"];
        model.navTitle = [[NSAttributedString alloc] initWithString:arr[0] attributes:@{NSForegroundColorAttributeName : UIColorFromRGB([arr[1] intValue]),NSFontAttributeName : [UIFont systemFontOfSize:[arr[2] doubleValue]]}];

    }
    if ([[dic allKeys] containsObject:@"navBackImage"]) {
        model.navBackImage = [UIImage imageNamed:dic[@"navBackImage"]];

    }
    model.hideNavBackItem=[dic[@"hideNavBackItem"] boolValue];
    if ([[dic allKeys] containsObject:@"navBackButtonFrame"]) {
        NSArray * arr=dic[@"navBackButtonFrame"];
        model.navBackButtonFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        
            return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
        };
        
    }
    if ([[dic allKeys] containsObject:@"navTitleFrame"]) {
        NSArray * arr=dic[@"navTitleFrame"];
        model.navTitleFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        
            return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
        };
        
    }
    if ([[dic allKeys] containsObject:@"navMoreViewFrameFrame"]) {
        NSArray * arr=dic[@"navMoreViewFrameFrame"];
        model.navMoreViewFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        
            return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
        };
        
    }

    if ([[dic allKeys] containsObject:@"animationDuration"]) {
        model.animationDuration=[dic[@"animationDuration"] doubleValue];
    }
    if ([[dic allKeys] containsObject:@"backgroundColor"]) {
        int color=[dic[@"backgroundColor"] intValue];
        model.backgroundColor=UIColorFromRGB(color);
    }
    if ([[dic allKeys] containsObject:@"backgroundImage"]) {
        model.backgroundImage = [UIImage imageNamed:dic[@"backgroundImage"]];

    }
    if ([[dic allKeys] containsObject:@"logoImage"]) {
        model.logoImage = [UIImage imageNamed:dic[@"logoImage"]];

    }
    model.logoIsHidden=[dic[@"logoIsHidden"] boolValue];
    if ([[dic allKeys] containsObject:@"logoFrame"]) {
        NSArray * arr=dic[@"logoFrame"];
        model.logoFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        
            return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
        };
        
    }
    
    if ([[dic allKeys] containsObject:@"sloganText"]) {
        NSArray * arr=dic[@"sloganText"];
        model.sloganText = [[NSAttributedString alloc] initWithString:arr[0] attributes:@{NSForegroundColorAttributeName : UIColorFromRGB([arr[1] intValue]),NSFontAttributeName : [UIFont systemFontOfSize:[arr[2] doubleValue]]}];

    }
    model.prefersStatusBarHidden=[dic[@"prefersStatusBarHidden"] boolValue];

    model.sloganIsHidden=[dic[@"sloganIsHidden"] boolValue];
    if ([[dic allKeys] containsObject:@"sloganFrame"]) {
        NSArray * arr=dic[@"sloganFrame"];
        model.sloganFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        
            return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
        };
        
    }
    if ([[dic allKeys] containsObject:@"numberColor"]) {
        int color=[dic[@"numberColor"] intValue];
        model.numberColor=UIColorFromRGB(color);
    }
    if ([[dic allKeys] containsObject:@"numberFont"]) {
        model.numberFont=[UIFont systemFontOfSize:[dic[@"numberFont"] doubleValue]];
    }
    if ([[dic allKeys] containsObject:@"numberFrame"]) {
        NSArray * arr=dic[@"numberFrame"];
        model.numberFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        
            return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
        };
        
    }
    if ([[dic allKeys] containsObject:@"loginBtnText"]) {
        NSArray * arr=dic[@"loginBtnText"];
        model.loginBtnText = [[NSAttributedString alloc] initWithString:arr[0] attributes:@{NSForegroundColorAttributeName : UIColorFromRGB([arr[1] intValue]),NSFontAttributeName : [UIFont systemFontOfSize:[arr[2] doubleValue]]}];

    }
    if ([[dic allKeys] containsObject:@"loginBtnBgImgs"]) {
        NSArray * arr=dic[@"loginBtnBgImgs"];
        if ([arr count]==3) {
            model.loginBtnBgImgs = @[[UIImage imageNamed:arr[0]],[UIImage imageNamed:arr[1]],[UIImage imageNamed:arr[2]]];
        }

    }
    model.autoHideLoginLoading=[dic[@"autoHideLoginLoading"] boolValue];
    if ([[dic allKeys] containsObject:@"loginBtnFrame"]) {
        NSArray * arr=dic[@"loginBtnFrame"];
        model.loginBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        
            return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[3] doubleValue], [arr[4] doubleValue]);
        };
        
    }
    
    if ([[dic allKeys] containsObject:@"checkBoxImages"]) {
        NSArray * arr=dic[@"checkBoxImages"];
        if ([arr count]==2) {
            model.checkBoxImages = @[[UIImage imageNamed:arr[0]],[UIImage imageNamed:arr[1]]];
        }

    }
    if ([[dic allKeys] containsObject:@"checkBoxImageEdgeInsets"]) {
        NSArray * arr=dic[@"checkBoxImageEdgeInsets"];
        model.checkBoxImageEdgeInsets = UIEdgeInsetsMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
        
    }
    model.checkBoxIsChecked=[dic[@"checkBoxIsChecked"] boolValue];
    model.checkBoxIsHidden=[dic[@"checkBoxIsHidden"] boolValue];
    if ([[dic allKeys] containsObject:@"checkBoxWH"]) {
        model.checkBoxWH = [dic[@"checkBoxWH"] doubleValue];
        
    }
    if ([[dic allKeys] containsObject:@"privacyOne"]) {
        NSArray * arr=dic[@"privacyOne"];
        model.privacyOne = arr;
    }
    if ([[dic allKeys] containsObject:@"privacyTwo"]) {
        NSArray * arr=dic[@"privacyTwo"];
        model.privacyTwo = arr;
    }
    if ([[dic allKeys] containsObject:@"privacyThree"]) {
        NSArray * arr=dic[@"privacyThree"];
        model.privacyThree = arr;
    }
    if ([[dic allKeys] containsObject:@"privacyConectTexts"]) {
        NSArray * arr=dic[@"privacyConectTexts"];
        model.privacyConectTexts = arr;
    }
    if ([[dic allKeys] containsObject:@"privacyColors"]) {
        NSArray * arr=dic[@"privacyColors"];
        if ([arr count]==2) {
            int colors0=[arr[0] intValue];
            int colors1=[arr[1] intValue];
            model.privacyColors = @[UIColorFromRGB(colors0),UIColorFromRGB(colors1)];
        }

    }
    if ([[dic allKeys] containsObject:@"privacyAlignment"]) {
        NSString *str=dic[@"privacyAlignment"];
        NSTextAlignment type=NSTextAlignmentLeft;

        if ([str isEqualToString:@"Center"]) {
            type=NSTextAlignmentCenter;
        }
        if ([str isEqualToString:@"Right"]) {
            type=NSTextAlignmentRight;
        }
        model.privacyAlignment=type;
    }
    if ([[dic allKeys] containsObject:@"privacyPreText"]) {
        model.privacyPreText = dic[@"privacyPreText"];
    }
    if ([[dic allKeys] containsObject:@"privacySufText"]) {
        model.privacySufText = dic[@"privacySufText"];
    }
    if ([[dic allKeys] containsObject:@"privacyOperatorPreText"]) {
        model.privacyOperatorPreText = dic[@"privacyOperatorPreText"];
    }
    if ([[dic allKeys] containsObject:@"privacyOperatorSufText"]) {
        model.privacyOperatorSufText = dic[@"privacyOperatorSufText"];
    }
    if ([[dic allKeys] containsObject:@"privacyOperatorIndex"]) {
        model.privacyOperatorIndex = [dic[@"privacyOperatorIndex"] intValue];
    }
    if ([[dic allKeys] containsObject:@"privacyFont"]) {
        model.privacyFont=[UIFont systemFontOfSize:[dic[@"privacyFont"] doubleValue]];
    }
    if ([[dic allKeys] containsObject:@"privacyFrame"]) {
        NSArray * arr=dic[@"privacyFrame"];
        model.privacyFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        
            return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
        };
        
    }
    if ([[dic allKeys] containsObject:@"changeBtnTitle"]) {
        NSArray * arr=dic[@"changeBtnTitle"];
        model.changeBtnTitle = [[NSAttributedString alloc] initWithString:arr[0] attributes:@{NSForegroundColorAttributeName : UIColorFromRGB([arr[1] intValue]),NSFontAttributeName : [UIFont systemFontOfSize:[arr[2] doubleValue]]}];

    }
    model.changeBtnIsHidden=[dic[@"changeBtnIsHidden"] boolValue];
    if ([[dic allKeys] containsObject:@"changeBtnFrame"]) {
        NSArray * arr=dic[@"changeBtnFrame"];
        model.changeBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize, CGRect frame) {
        
            return CGRectMake([arr[0] doubleValue], [arr[1] doubleValue], [arr[2] doubleValue], [arr[3] doubleValue]);
        };
        
    }
    model.privacyVCIsCustomized=[dic[@"privacyVCIsCustomized"] boolValue];
    if ([[dic allKeys] containsObject:@"privacyNavColor"]) {
        int color=[dic[@"privacyNavColor"] intValue];
        model.privacyNavColor=UIColorFromRGB(color);
    }
    if ([[dic allKeys] containsObject:@"privacyNavTitleFont"]) {
        model.privacyNavTitleFont=[UIFont systemFontOfSize:[dic[@"privacyNavTitleFont"] doubleValue]];
    }
    if ([[dic allKeys] containsObject:@"privacyNavTitleColor"]) {
        int color=[dic[@"privacyNavTitleColor"] intValue];
        model.privacyNavTitleColor=UIColorFromRGB(color);
    }
    if ([[dic allKeys] containsObject:@"privacyNavBackImage"]) {
        model.privacyNavBackImage = [UIImage imageNamed:dic[@"privacyNavBackImage"]];

    }
    
    if ([[dic allKeys] containsObject:@"customWidget"]) {
        NSArray *arr=dic[@"customWidget"];
        if ([arr count]>0) {
            NSMutableArray *widgetArr=[[NSMutableArray alloc]init];
            for (NSInteger i=0; i<[arr count]; i++) {
                NSDictionary *widgetDic=arr[i];
                if ([widgetDic[@"type"] isEqualToString:@"button"]) {
                    UIButton *button=[self customButtonWidget:widgetDic];
                    [widgetArr addObject:button];
                   

                }
                
                if ([widgetDic[@"type"] isEqualToString:@"textView"]) {
                    UILabel *textView=[self customTextWidget:widgetDic];
                    [widgetArr addObject:textView];

                   
                }
                
                
            }
            
            model.customViewBlock = ^(UIView * _Nonnull superCustomView) {
                for (NSInteger j=0; j<[widgetArr count]; j++) {
                    [superCustomView addSubview:widgetArr[j]];

                }
            };
        }
       // model.privacyNavBackImage = [UIImage imageNamed:dic[@"privacyNavBackImage"]];

    }
    return model;
}
    
- (UIButton *)customButtonWidget:(NSDictionary *)widgetDic {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSInteger left = [[self getValue:widgetDic key:@"left"] integerValue];
    NSInteger top = [[self getValue:widgetDic key:@"top"] integerValue];
    NSInteger width = [[self getValue:widgetDic key:@"width"] integerValue];
    NSInteger height = [[self getValue:widgetDic key:@"height"] integerValue];
    
    NSString *title = [self getValue:widgetDic key:@"title"];
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateHighlighted];
    }
    NSNumber *titleColor = [self getValue:widgetDic key:@"titleColor"];
    if (titleColor) {
        [button setTitleColor:UIColorFromRGB([titleColor integerValue]) forState:UIControlStateNormal];
    }
    NSNumber *backgroundColor = [self getValue:widgetDic key:@"backgroundColor"];
    if (backgroundColor) {
        [button setBackgroundColor:UIColorFromRGB([backgroundColor integerValue])];
    }
    NSString *textAlignment = [self getValue:widgetDic key:@"textAlignment"];
    if (textAlignment) {
        button.contentHorizontalAlignment = [self getButtonTitleAlignment:textAlignment];
    }
    
    NSNumber *font = [self getValue:widgetDic key:@"titleFont"];
    if (font) {
        button.titleLabel.font = [UIFont systemFontOfSize:[font floatValue]];
    }

    
    NSNumber *isShowUnderline = [self getValue:widgetDic key:@"isShowUnderline"];
    if ([isShowUnderline boolValue]) {
        NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:title attributes:attribtDic];
        button.titleLabel.attributedText = attribtStr;
    }
    
    button.frame = CGRectMake(left, top, width, height);
    
    NSNumber *isClickEnable = [self getValue:widgetDic key:@"isClickEnable"];
    button.userInteractionEnabled = [isClickEnable boolValue];
    [button addTarget:self action:@selector(clickCustomWidgetAction:) forControlEvents:UIControlEventTouchUpInside];

     NSString *widgetId = [self getValue:widgetDic key:@"widgetId"];

    NSString *tag = @(left+top+width+height).stringValue;
    button.tag = [tag integerValue];
    

    [self.customWidgetIdDic setObject:widgetId forKey:tag];
    
    
    NSString *btnNormalImageName = [self getValue:widgetDic key:@"btnNormalImageName"];
    NSString *btnPressedImageName = [self getValue:widgetDic key:@"btnPressedImageName"];
    if (!btnPressedImageName) {
        btnPressedImageName = btnNormalImageName;
    }
    if (btnNormalImageName) {
        [button setBackgroundImage:[UIImage imageNamed:btnNormalImageName] forState:UIControlStateNormal];
    }
    if (btnPressedImageName) {
        [button setBackgroundImage:[UIImage imageNamed:btnPressedImageName] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:btnPressedImageName] forState:UIControlStateSelected];
    }
    
    return button;
}

- (UILabel *)customTextWidget:(NSDictionary *)widgetDic {
    UILabel *label = [[UILabel alloc] init];
    
    NSInteger left = [[self getValue:widgetDic key:@"left"] integerValue];
    NSInteger top = [[self getValue:widgetDic key:@"top"] integerValue];
    NSInteger width = [[self getValue:widgetDic key:@"width"] integerValue];
    NSInteger height = [[self getValue:widgetDic key:@"height"] integerValue];
    
    NSString *title = [self getValue:widgetDic key:@"title"];
    if (title) {
        label.text = title;
    }
    NSNumber *titleColor = [self getValue:widgetDic key:@"titleColor"];
    if (titleColor) {
        label.textColor = UIColorFromRGB([titleColor integerValue]);
    }
    NSNumber *backgroundColor = [self getValue:widgetDic key:@"backgroundColor"];
    if (backgroundColor) {
        label.backgroundColor = UIColorFromRGB([backgroundColor integerValue]);
    }
    NSString *textAlignment = [self getValue:widgetDic key:@"textAlignment"];
    if (textAlignment) {
        label.textAlignment = [self getTextAlignment:textAlignment];
    }
    
    NSNumber *font = [self getValue:widgetDic key:@"titleFont"];
    if (font) {
        label.font = [UIFont systemFontOfSize:[font floatValue]];
    }
    
    NSNumber *lines = [self getValue:widgetDic key:@"lines"];
    if (lines) {
        label.numberOfLines = [lines integerValue];
    }
    NSNumber *isSingleLine = [self getValue:widgetDic key:@"isSingleLine"];
    if (![isSingleLine boolValue]) {
        label.numberOfLines = 0;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20],};
        CGSize textSize = [label.text boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
        height = textSize.height;
    }
    
    NSNumber *isShowUnderline = [self getValue:widgetDic key:@"isShowUnderline"];
    if ([isShowUnderline boolValue]) {
        NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:title attributes:attribtDic];
        label.attributedText = attribtStr;
    }
    
    NSString *widgetId = [self getValue:widgetDic key:@"widgetId"];
    
    label.frame = CGRectMake(left, top, width, height);
    
    NSNumber *isClickEnable = [self getValue:widgetDic key:@"isClickEnable"];
    if ([isClickEnable boolValue]) {
        NSString *tag = @(left+top+width+height).stringValue;
        label.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTextWidgetAction:)];
        [singleTapGestureRecognizer setNumberOfTapsRequired:1];
        [label addGestureRecognizer:singleTapGestureRecognizer];
        singleTapGestureRecognizer.view.tag = [tag integerValue];
        
        [self.customWidgetIdDic setObject:widgetId forKey:tag];
    }
    
    return label;
}

- (void)clickCustomWidgetAction:(UIButton *)button {
    
    NSString *tag = [NSString stringWithFormat:@"%@",@(button.tag)];
    if (tag) {
        NSString *widgetId = [self.customWidgetIdDic objectForKey:tag];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_msgChannel invokeMethod:@"onClickWidgetEvent" arguments:@{@"widgetId":widgetId}];
        });

    }
}

- (void)clickTextWidgetAction:(UITapGestureRecognizer *)gestureRecognizer {

    NSString *tag = [NSString stringWithFormat:@"%@",@(gestureRecognizer.view.tag)];
    if (tag) {
        
        NSString *widgetId = [self.customWidgetIdDic objectForKey:tag];

        dispatch_async(dispatch_get_main_queue(), ^{

            [self->_msgChannel invokeMethod:@"onClickWidgetEvent" arguments:@{@"widgetId":widgetId}];
        });
    }
}

- (id)getValue:(NSDictionary *)arguments key:(NSString*) key{
    if (arguments && ![arguments[key] isKindOfClass:[NSNull class]]) {
        return arguments[key]?:nil;
    }else{
        return nil;
    }
}


- (UIControlContentHorizontalAlignment)getButtonTitleAlignment:(NSString *)aligement {
    UIControlContentHorizontalAlignment model = UIControlContentHorizontalAlignmentCenter;
    if (aligement) {
        if ([aligement isEqualToString:@"left"]) {
            model = UIControlContentHorizontalAlignmentLeft;
        }else if ([aligement isEqualToString:@"right"]) {
            model = UIControlContentHorizontalAlignmentRight;
        }else if ([aligement isEqualToString:@"center"]) {
            model = UIControlContentHorizontalAlignmentCenter;
        }else {
            model = UIControlContentHorizontalAlignmentCenter;
        }
    }
    return model;
}

- (NSTextAlignment)getTextAlignment:(NSString *)aligement {
    NSTextAlignment model = NSTextAlignmentLeft;
    if (aligement) {
        if ([aligement isEqualToString:@"left"]) {
            model = NSTextAlignmentLeft;
        }else if ([aligement isEqualToString:@"right"]) {
            model = NSTextAlignmentRight;
        }else if ([aligement isEqualToString:@"center"]) {
            model = NSTextAlignmentCenter;
        }else {
            model = NSTextAlignmentLeft;
        }
    }
    return model;
}
- (NSMutableDictionary *)customWidgetIdDic {
    if (!_customWidgetIdDic) {
        _customWidgetIdDic  = [NSMutableDictionary dictionary];
    }
    return _customWidgetIdDic;
}
@end


@implementation UmengVerifySdkPlugin
NSObject<FlutterPluginRegistrar>* _um_registrar;
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
      FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"umeng_verify_sdk"
            binaryMessenger:[registrar messenger]];
    _um_registrar=registrar;
    UmengVerifySdkPlugin* instance = [[UmengVerifySdkPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}



- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    //result(FlutterMethodNotImplemented);
  }

    BOOL  resultCode = [[UMengflutterpluginForVerify alloc] handleMethodCall:call result:result registrar:_um_registrar];
    if (resultCode) return;

  
    
    result(FlutterMethodNotImplemented);
}

@end


