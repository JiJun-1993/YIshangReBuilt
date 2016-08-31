//
//  ViewController.m
//  YIshangReBuilt
//
//  Created by mac on 16/7/31.
//  Copyright © 2016年 Yishang. All rights reserved.
//
#import "ShareCustom.h"

#import "ViewController.h"
#import <WebKit/WebKit.h>
// qq  和 微信分享
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>
//  qq 和微信登录
//------------------原生
// 判断微信已经安装
#define WeixinIsINstalled [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]]
static NSString *AuthScope = @"snsapi_userinfo";
static NSString *AuthOpenID = @"wx2677e1c8a520f187";
static NSString *AuthSecret  =@"53c08017c4ac6b9ff5184230b9408217";
static NSString *AuthState = @"lct_ibestry_vipysw_login";
#import "WXApiManager.h"
static NSString *MembCenter = @"app=member";
//------------------
//#import "UMSocialQQHandler.h"
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>
#define QQLoginUrl(openId,access_token)  [NSString stringWithFormat:@"http://www.vipysw.com/mobile/index.php?app=qqyswconnect&act=callback&openid=%@&access_token=%@",openId,access_token]

#define WxreqWithCode(code) [NSString stringWithFormat:@"http://www.vipysw.com/mobile/index.php?app=wxyswconnect&act=callback&code=%@",code]



#define screenBounds [UIScreen mainScreen].bounds
#define NaviHeight 55
#define Margin 5
#define ItemSize 26
#define sysFontSize  20
#define HomeRequest @"http://www.vipysw.com/mobile/"
#define NewsCurrent @"http://www.vipysw.com/index.php?app=message&act=newpm"

#import "SeleObjView.h"
#import "JudgeLogView.h"
@interface ViewController ()<WKNavigationDelegate,JudgeLogViewDelegate,SeleObjViewDelegate,WXApiManagerDelegate,UIGestureRecognizerDelegate,MBProgressHUDDelegate>
@property(nonatomic,strong)WKWebView* wkWebView;

//@property (weak, nonatomic) IBOutlet UIWebView *wkWebView;

@property(nonatomic,strong)UIView* naviView;

@property(strong,nonatomic)UIButton* leftNaviItem;
@property(strong,nonatomic)UIButton* btnShare;
// 记录当前网址
@property(strong,nonatomic)NSString* clickedUrl;
// 记录上一个网址
@property(strong,nonatomic)NSString* previousUrl;
// 点击分享视图 ，蒙版
@property(strong,nonatomic)UIView* coverView;
@property(nonatomic,strong)SeleObjView* seleObjView;
@property(strong,nonatomic)JudgeLogView* seleObj;
//  记录网页信息
 @property(strong,nonatomic)NSArray* compArray;
//  加载时候的蒙版

// cookie
@property(strong,nonatomic)WKProcessPool* processPool;
// Progress Cycle
@property(strong,nonatomic)MBProgressHUD* progresHUD;

// 分享界面
@property(strong,nonatomic)JudgeLogView* shareView;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//     [self setUserAgent];
    
    [self setNaviBar];
    
    NSSet* set;
//    [self initParameter];
//    [self setMainPage ];
    [self setCookie];

//    [self setCover];
    
    
    // newVersionTest 获取新版本信息
//    [self newVersionTest];
    
}
//懒加载
      // 懒加载SeleObjView
-(SeleObjView*)seleObjView{
    if (_seleObjView == nil) {
        _seleObjView = [SeleObjView seleView];
    }
    return _seleObjView;
}
    // 调用js 函数，懒加载网页info
-(void)setCompArr{
    //    NSString* comp =  [self.webView stringByEvaluatingJavaScriptFromString:@"app_get_share_ios()"];
    NSString* js = @"app_get_share_ios()";
    [_wkWebView evaluateJavaScript:js completionHandler:^(NSString *result, NSError *error)
     {
         _compArray = [result componentsSeparatedByString:@"#"];
     }];
}
-(JudgeLogView*)shareView{
    if (_shareView == nil) {
        JudgeViewType type;
        if ([WXApi isWXAppInstalled]) {
            type = JudgeViewBothINstalled;
        }
        else if([QQApiInterface isQQInstalled])
            {
                type = JudgeViewOnlyQQ;
            }
            else{
//                type = ;
            }
        _shareView  = [JudgeLogView instanceJudgeViewStyle:type];
        _shareView.center = self.view.center;
        _shareView.alpha = 0;
    }
    return _shareView;
}
-(MBProgressHUD*)progresHUD{
    if (_progresHUD == nil) {
        _progresHUD = [[MBProgressHUD alloc]initWithView:self.view];
    }
    return _progresHUD;
}
-(void)setNaviBar{
// 导航条
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = NaviHeight;
    
    self.naviView = [[UIView alloc]init];
    self.naviView.frame = CGRectMake(0, 0, width, height);
    [self.naviView setBackgroundColor: [UIColor blackColor]];
//  title view
    UILabel* label = [[UILabel alloc]init];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:@"屹尚网"];
    [label setFont:[UIFont systemFontOfSize:sysFontSize]];
    //    label.center = naviView.center;
    label.width = ItemSize * 3;
    label.height = ItemSize;
    label.x = self.naviView.center.x - label.width / 2;
    label.y = NaviHeight -  Margin - ItemSize;
    
// home button
    self.leftNaviItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftNaviItem setImage:[UIImage imageNamed:@"return2"] forState:UIControlStateNormal];
    [self.leftNaviItem setTitle:@"返回" forState:UIControlStateNormal];
    
    [self.leftNaviItem setFont:[UIFont systemFontOfSize:sysFontSize * 0.7]];
    [self.leftNaviItem addTarget:self action:@selector(returnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    width = ItemSize * 3;
    height = ItemSize * 0.7;
    x = Margin;
    y = label.y;
    self.leftNaviItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //    [self.leftNaviItem setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 10)];
    self.leftNaviItem.frame = CGRectMake(x, y, width, height);
    [self.leftNaviItem setHidden:YES];;
// share button
    self.btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnShare setBackgroundImage:[UIImage imageNamed:@"More"] forState:UIControlStateNormal];
    [self.btnShare addTarget:self action:@selector(shareRequest:) forControlEvents:UIControlEventTouchUpInside];
    width = ItemSize;
    x = self.naviView.width - Margin * 2 - ItemSize;
    self.btnShare.frame = CGRectMake(x, y, width, height);
// add
    [self.naviView addSubview:label];
    [self.naviView addSubview:self.leftNaviItem];
    [self.naviView addSubview:self.btnShare];
    
    [self.view addSubview:self.naviView];
    [self.view addSubview:_naviView];
}
//  初始化 WKWebview
//-(void)initParameter{
//    // 01
////    _curntRequest = nil;
//    _clickedUrl = nil;
//    //  02  初始化新的webView
//    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
//    _wkWebView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:config];
//    _wkWebView.x = 0;
//    _wkWebView.y = CGRectGetMaxY(self.naviView.frame);
//    _wkWebView.width = screenBounds.size.width;
//    _wkWebView.height = (screenBounds.size.height - self.naviView.height);
//    _wkWebView.navigationDelegate = self;
//    
//    // 03 本来ShareSDK好好的，微信登录出故障了，只能再加这一步
//    [WXApiManager sharedManager].delegate = self;
//}
//  加载主页
// webview 首次加载
//-(void)setMainPage{
//     NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.vipysw.com/mobile/"]];
//    [_wkWebView loadRequest:request];
//    [self.view addSubview:_wkWebView];
//}
// 键盘处理
-(void)addNotiOfKeybod{
    // 01  处理键盘
    NSNotificationCenter* center =[NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyBoardShow) name:UIKeyboardWillShowNotification object:nil];
}
-(void)keyBdDismiss{
    [_wkWebView endEditing:YES];
}
//  移除键盘上面的accessView
-(void)keyBoardShow{
    
    [self setCover];

    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual : [UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    // Locate UIWebFormView.
    for (UIView *possibleFormView in [keyboardWindow subviews]) {
        
        if ([[possibleFormView description] hasPrefix : @"<UIInputSetContainerView"]) {
            for (UIView* peripheralView in possibleFormView.subviews) {
                
                for (UIView* peripheralView_sub in peripheralView.subviews) {
                    
                    
                    // hides the backdrop (iOS 8)
                    if ([[peripheralView_sub description] hasPrefix : @"<UIKBInputBackdropView"] && peripheralView_sub.frame.size.height == 44) {
                        [[peripheralView_sub layer] setOpacity : 0.0];
                        
                    }
                    // hides the accessory bar
                    if ([[peripheralView_sub description] hasPrefix : @"<UIWebFormAccessory"]) {
                        
                        
                        for (UIView* UIInputViewContent_sub in peripheralView_sub.subviews) {
                            
                            CGRect frame1 = UIInputViewContent_sub.frame;
                            frame1.size.height = 0;
                            peripheralView_sub.frame = frame1;
                            UIInputViewContent_sub.frame = frame1;
                            [[peripheralView_sub layer] setOpacity : 0.0];
                            
                        }
                        
                        CGRect viewBounds = peripheralView_sub.frame;
                        viewBounds.size.height = 0;
                        peripheralView_sub.frame = viewBounds;
                        
                    }
                }
                
            }
        }
    }

}
//  设置点击分享后的覆盖视图
-(void)setCover
{
    _coverView = [[UIView alloc]initWithFrame:screenBounds];
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureRecv)];
    [_coverView addGestureRecognizer:gesture];
    _coverView.alpha = 0.1;
    
    [self.view addSubview:_coverView];
}
#pragma mark -- return click
-(void)returnClick:(UIButton*)returnBtn{
//    [_wkWebView loadRequest:[NSURLRequest requestWithString:_previousUrl]];
    [self.wkWebView goBack];
}
#pragma mark 弹出More界面，准备分享

-(void)shareRequest:(UIButton*)shareBtn
{
    //-1  获取网页信息，准备分享
    [self setCompArr];
    // 键盘消失
    [self keyBdDismiss];
    //0 蒙版走起
    [self setCover];
    //1 弹出SeleObjView
    SeleObjView* sele = self.seleObjView;
    sele.x = CGRectGetMaxX(shareBtn.frame) - sele.width;
    sele.y = CGRectGetMaxY(shareBtn.frame);
    sele.delegate = self;
    [self.view addSubview:sele];
}
//  点击 More 弹出的view
-(void)seleObjViewWithTag:(int)tag{
        // 点击蒙版和SeleObjView消失
    [self coverDismiss];
    // 判断点击的是哪个按钮
    switch (tag) {
        case 0:
             [_wkWebView loadRequest:[NSURLRequest requestWithString:NewsCurrent]];
            break;
        case 1:  [_wkWebView loadRequest:[NSURLRequest requestWithString:HomeRequest]];
            break;
        case 2: {
            [self setCover];
            [self.view addSubview:self.shareView];
            [UIView animateWithDuration:0.5 animations:^{
                self.shareView.alpha = 1;
            }];
        }
}
//            UIAlertController* alertVc = [[UIAlertController alloc]init];
//            //2、分享（可以弹出我们的分享菜单和编辑界面）
//            
//            [SSUIEditorViewStyle setCancelButtonLabel:@"取消"];
//            
//            
//            UIView* view = [[UIView alloc]initWithFrame:self.view.frame];
//            view.backgroundColor  = [ UIColor blueColor];
//            
////
//            [ShareSDK showShareActionSheet:view //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
//                                     items:nil
//                               shareParams:shareParams
//                       onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
//                           
//                           UIAlertAction* alertAction = [[UIAlertAction alloc]init];
//                           ////                           [alertVc addAction:alertAction];
////                           [self presentViewController:alertVc animated:YES completion:nil];
//                           
//                       }
//             ];
//
//        
//        }
//        default:
//            break;
//    }
    
    
    
}
// 点击 qq 或 微信 分享
-(void)changeScene:(NSInteger)scene{
    [self coverDismiss];
    NSString* shareTitle = @" ";
    NSString* shareUrlStr = _compArray[1];
    NSURL* sharUrl = [NSURL URLWithString:shareUrlStr];
    NSString* shareImageUrlStr = _compArray[2];
    NSURL* shareImageUrl = [NSURL URLWithString:shareImageUrlStr];
    NSString* shareDcrp = _compArray[3];
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
                [shareParams SSDKSetupShareParamsByText:shareTitle
                                                 images:shareImageUrl
                                                    url:sharUrl
                                                  title:shareDcrp
                                                   type:SSDKContentTypeWebPage];
    UIAlertController* alertVc = [[UIAlertController alloc]init];
    __block UIAlertAction* failAction;
    [ShareSDK share:scene parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                    if (state == SSDKResponseStateFail) {
                        failAction = [UIAlertAction actionWithTitle:@"分享失败" style:UIAlertActionStyleCancel handler:nil];
                        [alertVc addAction:failAction];
                        [self presentViewController:alertVc animated:YES completion:nil];
    }
        
                            }];
    
    
    
}

//-(void)qqShareSele:(int)tag{
//
//}

#pragma mark delegate of  webview
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [self showProgress];
    // 加载之前设置cookies
//    [self addCookies];
//   _progresHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if (_clickedUrl) {
        [self.leftNaviItem setHidden:NO];
    }
    NSString* strHtml = navigationAction.request.URL.absoluteString;
    _previousUrl = _clickedUrl;
    _clickedUrl = strHtml;
    if ([strHtml rangeOfString:QQloginClick].location != NSNotFound || [strHtml rangeOfString:WxLoginClick].location != NSNotFound) {
        [self logInWithHtml:strHtml];
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self disProgress];
    }else if([strHtml rangeOfString:ActLogout].location != NSNotFound){
        [self logOut];
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
       [_progresHUD hideAnimated:YES];

    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
//2 收到服务器响应头，根据navigationResponse 内容决定是否继续跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    if(([_clickedUrl rangeOfString:WxLoginClick].location != NSNotFound )|([_clickedUrl rangeOfString:QQloginClick].location != NSNotFound )){
        decisionHandler(WKNavigationResponsePolicyCancel);
        return;
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
    [self disProgress];
    
    // 这里每次加载而完毕就处理cookie
    [self dealCookie];
//    [self saveCookieArr];
}
// 如果加载失败，就停止加载，返回
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [_wkWebView stopLoading];
      if ([error code] == NSURLErrorCancelled) {
        return;
    }
}
#pragma  mark  登录
-(void)logInWithHtml:(NSString*)strHtml{
    if([strHtml rangeOfString:WxLoginClick].location != NSNotFound){
        [self loginWx];
    }
    else if([strHtml rangeOfString:QQloginClick].location != NSNotFound)
    {
        [self loginQQ];
    }
}
-(void)loginQQ{
    [ShareSDK getUserInfo:SSDKPlatformTypeQQ
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {
             NSURL* url = [NSURL URLWithString:QQLoginUrl(user.uid, user.credential.token)];
             NSURLRequest* request = [NSURLRequest requestWithURL:url];
             [_wkWebView loadRequest:request];
     
             [_wkWebView evaluateJavaScript:@"document.cookie.split(';')" completionHandler:^(NSArray* cookieStr, NSError * _Nullable error) {
                 // 存储cookie
//                 [self saveCookieArr];
             }];
        }
         else
         {
             NSLog(@"%@",error);
         }
         
     }];
}
-(void)loginWx{
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = AuthScope; // @"post_timeline,sns"
    req.state = AuthState;
    req.openID = AuthOpenID;
    if (WeixinIsINstalled){
        [WXApi sendReq:req];
    }
    else {
        [WXApi sendAuthReq:req
            viewController:self
                  delegate:[WXApiManager sharedManager]];
    }
}
//  Delegate  of   WXManager
// delegate of  WeixinLogin
- (void)WxManagerDidRecvAuthResponse:(SendAuthResp *)response{
    NSString* res = WxreqWithCode(response.code);
   
    if (res) {
        [ _wkWebView loadRequest:[NSURLRequest requestWithString:res]];
    }
    else [_wkWebView loadRequest:[NSURLRequest requestWithString:MembCenter]];
    
}
- (WKProcessPool *)processPool {
    if (!_processPool) {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            _processPool = [[WKProcessPool alloc] init];
        });
    }
    return _processPool;
}
- (void)setCookie {
    //判断系统是否支持wkWebView
    Class wkWebView = NSClassFromString(@"WKWebView");
    if (!wkWebView) {
        return;
    }
    WKWebView* webView = [[WKWebView alloc]initWithFrame:CGRectZero];
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:@"vipysw_cmnetec_ios", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString *oldAgent, NSError * _Nullable error) {
//        JJLog(@"oldAgent%@",oldAgent);
    }];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.processPool = self.processPool;
    webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    //  02  初始化新的webView
    webView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:config];
    webView.x = 0;
    webView.y = CGRectGetMaxY(self.naviView.frame);
    webView.width = screenBounds.size.width;
    webView.height = (screenBounds.size.height - self.naviView.height);
    webView.navigationDelegate = self;
    
    _wkWebView = webView;
    
    NSURLRequest *request = [NSURLRequest requestWithString:HomeRequest];
    
    [_wkWebView loadRequest:request];
    self.wkWebView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    [self.view addSubview:_wkWebView];
    
    [_wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString* ua, NSError * _Nullable error) {
        //            userAg = ua;
//        JJLog(@"UA %@",ua);
    }];
}
#pragma mark  处理cookie
-(void)dealCookie{
     // 1 获得沙盒路径
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"cookie.archiver"];
    
    // 2 获取旧cookie
    __block NSArray* localCookies =  [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    [_wkWebView evaluateJavaScript:@"document.cookie.split(';')" completionHandler:^(NSArray* cookieStr, NSError * _Nullable error) {
  
        // 3 将新旧cookie的并集存储，并加入到Webview中
        if (cookieStr != nil) {
            localCookies = [NSSet unionSetOfA:localCookies arrayB:cookieStr];
        }
    }];
    if(localCookies){
    //   js函数
    NSString *JSFuncString = @"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
    document.cookie=name+'='+value+';expires='+oDate;\
    }";
    //  拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSString* aCookie in localCookies) {
        NSArray* arr = [aCookie componentsSeparatedByString:@"="];
        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", arr[0], arr[1]];
        [JSCookieString appendString:excuteJSString];
        
        //执行js
        [_wkWebView evaluateJavaScript:JSCookieString completionHandler:nil];
    }
    }
    // 将新的cookie存储起来
    [NSKeyedArchiver archiveRootObject:localCookies toFile:filePath];
}
// 退出时消除存储的cookie
-(void)logOut{
    //                 获得沙盒路径
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"cookie.archiver"];

    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSError* error = [[NSError alloc]init];
    [fileManager removeItemAtPath:filePath error:&error];
    if ([fileManager fileExistsAtPath:filePath]) {
        JJLog(@"没删除干净");
    }
}
#pragma  mark  setUserAgent
-(void)setUserAgent{
    WKWebView* webView = [[WKWebView alloc]initWithFrame:CGRectZero];
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero
    __block  NSString *oldAgents;
    
    [_wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString *oldAgent, NSError * _Nullable error) {
        oldAgents = oldAgent;
        JJLog(@"oldAgent%@",oldAgent);
    }];
    //add my info to the new agent
    NSString *newAgent = @"vipysw_cmnetec_ios";
}

#pragma mark  预备和善后
// 预备
-(void)viewWillAppear:(BOOL)animated{
//  添加通知
//     01 键盘事件
    NSNotificationCenter* center =[NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyBoardShow) name:UIKeyboardWillShowNotification object:nil];
    // 设置代理
    _wkWebView.navigationDelegate = self;
    [WXApiManager sharedManager].delegate = self;
    self.shareView.delegate = self;
   // 初始化一个参数
    _clickedUrl = nil;
}
-(void)disProgress{
    [_wkWebView stopLoading];
    [_progresHUD hideAnimated:YES];

}
-(void)showProgress{
    _progresHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _coverView.backgroundColor =[UIColor lightGrayColor];
    [_progresHUD addSubview:self.coverView];
    
}
// 善后
-(void)viewWillDisappear:(BOOL)animated{
    _wkWebView.navigationDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [WXApiManager sharedManager].delegate = nil;
    self.shareView.delegate = self;
    
}

// 点击蒙版,消失
-(void)gestureRecv{
    [self coverDismiss];
}
-(void)coverDismiss{
    [self.seleObjView removeFromSuperview];
    [self.coverView removeFromSuperview];
    // 键盘消失
    [self keyBdDismiss];
    // 停止加载
    [_wkWebView stopLoading];
    [self disProgress ];
    //分享取消
    [self.shareView removeFromSuperview];
//    [UIView animateWithDuration:0.5 animations:^{
//        self.seleView.y = [UIScreen mainScreen].bounds.size.height;
//        self.seleObj.y = self.view.height;
//    }];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.seleView.alpha =0;
//        self.seleObj.alpha =0;
//    }];
}
@end
