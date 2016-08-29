//
//  ViewController.m
//  YIshangReBuilt
//
//  Created by mac on 16/7/31.
//  Copyright © 2016年 Yishang. All rights reserved.
//

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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setNaviBar];
    
//    [self initParameter];
//    [self setMainPage ];
    [self setCookie];

//    [self setCover];
    
     [self setUserAgent];
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
-(UIView*)coverView{
    if (_coverView == nil) {
        _coverView = [[UIView alloc]initWithFrame:self.view.frame];
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureRecv)];
        [_coverView addGestureRecognizer:gesture];
        _coverView.alpha = 0.1;
    }
    return _coverView;
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
    
    
//    naviView.backgroundColor = [UIColor redColor];
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
    [self.view addSubview:self.coverView];
//    // 添加分享对象
//    JudgeViewType logType;
//    logType = 0;
//    self.seleObj = [JudgeLogView  instanceJudgeViewStyle:logType];
//    //    self.seleObj.width = 20;
//    self.seleObj.delegate = self;
////    self.seleObj.alpha = 0;
//    self.seleObj.center = self.view.center;
//    self.seleObj.y = [UIScreen mainScreen].bounds.size.height;
//    [self.view addSubview:self.seleObj];
    
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
    NSString* shareTitle = @" ";
    NSString* shareUrlStr = _compArray[1];
    NSURL* sharUrl = [NSURL URLWithString:shareUrlStr];
    NSString* shareImageUrlStr = _compArray[2];
    NSURL* shareImageUrl = [NSURL URLWithString:shareImageUrlStr];
    NSString* shareDcrp = _compArray[3];
    // 判断点击的是哪个按钮
    switch (tag) {
        case 0:
            break;
        case 1:  [_wkWebView loadRequest:[NSURLRequest requestWithString:HomeRequest]];
            break;
        case 2: {
            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
            
            [shareParams SSDKSetupShareParamsByText:shareTitle
                                             images:shareImageUrl
                                                url:sharUrl
                                              title:shareDcrp
                                               type:SSDKContentTypeWebPage];
            
            UIAlertController* alertVc = [[UIAlertController alloc]init];
            //2、分享（可以弹出我们的分享菜单和编辑界面）
            
            [SSUIEditorViewStyle setCancelButtonLabel:@"取消"];
            
            
            UIView* view = [[UIView alloc]initWithFrame:self.view.frame];
            view.backgroundColor  = [ UIColor blueColor];
            
            [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                
            }];
//            [ShareSDK showShareActionSheet:view //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
//                                     items:nil
//                               shareParams:shareParams
//                       onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
//                           
//                           UIAlertAction* alertAction = [[UIAlertAction alloc]init];
//                           switch (state) {
//                               case SSDKResponseStateSuccess:
//                               {
//                                   
//                                   alertAction = [UIAlertAction actionWithTitle:@"分享成功" style:UIAlertActionStyleCancel handler:nil];
//                                                                      break;
//                                   
//                               }
//                               case SSDKResponseStateFail:
//                               {
//                                        alertAction = [UIAlertAction actionWithTitle:@"分享成功" style:UIAlertActionStyleCancel handler:nil];
//                                   
//                                   break;
//                               }
//                               default:
//                                   break;
//                           }
////                           [alertVc addAction:alertAction];
////                           [self presentViewController:alertVc animated:YES completion:nil];
//                           
//                       }
//             ];

        
        }
        default:
            break;
    }
    
    
    
}
// 点击 qq 或 微信 分享
-(void)changeScene:(int)scene{
    
    
}

-(void)qqShareSele:(int)tag{

}

#pragma mark delegate of  webview
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [self showProgress];
//   _progresHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if (_clickedUrl) {
        [self.leftNaviItem setHidden:NO];
    }
    NSString* strHtml = navigationAction.request.URL.absoluteString;
    _previousUrl = _clickedUrl;
    _clickedUrl = strHtml;
    
//    [_wkWebView evaluateJavaScript:@"document.documentElement.outerHTML" completionHandler:^(NSString* html, NSError * _Nullable error) {
//        NSLog(@"html %@",html);
//    }];
    if ([strHtml rangeOfString:QQloginClick].location != NSNotFound || [strHtml rangeOfString:WxLoginClick].location != NSNotFound) {
        [self logInWithHtml:strHtml];
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self disProgress];
    }else if([strHtml rangeOfString:ActLogout].location != NSNotFound){
        [self logOut];
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
       [self disProgress];

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
    
//    [self disProgress];
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self disProgress];

    
    //获得沙盒路径
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    NSString *filePath = [documentPath stringByAppendingPathComponent:@"cookie.archiver"];
    
    NSArray* cookieArr =  [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (cookieArr != nil) {
//        //js函数
        NSString *JSFuncString = @"function setCookie(name,value,expires)\
        {\
        var oDate=new Date();\
        oDate.setDate(oDate.getDate()+expires);\
        document.cookie=name+'='+value+';expires='+oDate;\
        }";
        //拼凑js字符串
        NSMutableString *JSCookieString = JSFuncString.mutableCopy;
        for (NSString* aCookie in cookieArr) {
            NSArray* arr = [aCookie componentsSeparatedByString:@"="];
            NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", arr[0], arr[1]];
            [JSCookieString appendString:excuteJSString];
        }
        //执行js
        [webView evaluateJavaScript:JSCookieString completionHandler:nil];
    }
}
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
                 [self saveCookieArr];
             }];
        }
         else
         {
             NSLog(@"%@",error);
         }
         
     }];
//
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
        [self saveCookieArr];
        
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
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.processPool = self.processPool;
    _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    //  02  初始化新的webView
    _wkWebView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:config];
    _wkWebView.x = 0;
    _wkWebView.y = CGRectGetMaxY(self.naviView.frame);
    _wkWebView.width = screenBounds.size.width;
    _wkWebView.height = (screenBounds.size.height - self.naviView.height);
    _wkWebView.navigationDelegate = self;
    
    NSURLRequest *request = [NSURLRequest requestWithString:HomeRequest];
    
    [_wkWebView loadRequest:request];
    self.wkWebView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    [self.view addSubview:_wkWebView];
}
// save cookie to local
-(void)saveCookieArr{
    
    // 把cookie存储到本地
    [_wkWebView evaluateJavaScript:@"document.cookie.split(';')" completionHandler:^(NSArray* cookieStr, NSError * _Nullable error) {
        
        //                 获得沙盒路径
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        //获取文件路径，由于归档后文件会加密，所以文件后缀可以任意取
        NSString *filePath = [documentPath stringByAppendingPathComponent:@"cookie.archiver"];
        
//        NSError* errors = [[NSError alloc]init];
       
        BOOL exist =[NSKeyedArchiver archiveRootObject:cookieStr toFile:filePath];
        if (!exist) {
            
        }
        
    }];
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
        NSLog(@"没删除干净");
    }
}
#pragma  mark  setUserAgent
-(void)setUserAgent{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero
                          ];
    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    
    //add my info to the new agent
    NSString *newAgent = [NSString stringWithFormat:@"%@ vipysw_cmnetec_ios",oldAgent];
    
    [oldAgent stringByAppendingString:@" Jiecao/2.4.7 ch_appstore"];
    
    
    //regist the new agent
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
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
