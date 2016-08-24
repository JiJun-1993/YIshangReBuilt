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
//  qq 和微信登录
//------------------原生
// 判断微信已经安装
#define WeixinIsINstalled [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]]
static NSString *AuthScope = @"snsapi_userinfo";
static NSString *AuthOpenID = @"wx2677e1c8a520f187";
static NSString *AuthSecret  =@"53c08017c4ac6b9ff5184230b9408217";
static NSString *AuthState = @"lct_ibestry_vipysw_login";
#import "WXApiManager.h"
#define MembCenter @"app=member"
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
@interface ViewController ()<WKNavigationDelegate,JudgeLogViewDelegate,SeleObjViewDelegate,WXApiManagerDelegate,UIScrollViewDelegate>
@property(nonatomic,strong)WKWebView* wkWebView;

//@property (weak, nonatomic) IBOutlet UIWebView *wkWebView;

@property(nonatomic,strong)UIView* naviView;

@property(strong,nonatomic)UIButton* leftNaviItem;
@property(strong,nonatomic)UIButton* btnShare;
// 记录当前网址
@property(strong,nonatomic)NSString* clickedUrl;
// 点击分享视图 ，蒙版
@property(strong,nonatomic)UIView* seleView;
@property(nonatomic,strong)SeleObjView* seleObjView;
@property(strong,nonatomic)JudgeLogView* seleObj;
//  记录网页信息
 @property(strong,nonatomic)NSArray* compArray;
//  加载时候的蒙版

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setNaviBar];
    
    [self initParameter];
    
    [self setMainPage ];
    
   
    
    [self setCover];
    
     [self setUserAgent];
    // newVersionTest 获取新版本信息
    [self newVersionTest];
    
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
-(void)initParameter{
    // 01
//    _curntRequest = nil;
    _clickedUrl = nil;
    //  02  初始化新的webView
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    _wkWebView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:config];
    _wkWebView.x = 0;
    _wkWebView.y = CGRectGetMaxY(self.naviView.frame);
    _wkWebView.width = screenBounds.size.width;
    _wkWebView.height = (screenBounds.size.height - self.naviView.height);
    _wkWebView.navigationDelegate = self;
    
    // 03 本来ShareSDK好好的，微信登录出故障了，只能再加这一步
    [WXApiManager sharedManager].delegate = self;
}
//  加载主页
// webview 首次加载
-(void)setMainPage{
    NSURL* url =[NSURL URLWithString:@"http://www.vipysw.com/mobile/"];
    //    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    NSURLRequest *request= [NSURLRequest requestWithURL:url];
    //    NSString* HOST = strHtml;
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    [_wkWebView loadRequest:request];
    [self.view addSubview:_wkWebView];
    //    [self.view addSubview:_wkWebView];
}
// 键盘处理
-(void)addNotiOfKeybod{
    // 01  处理键盘
    NSNotificationCenter* center =[NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyBoardShow) name:UIKeyboardWillShowNotification object:nil];
    //  02  点击空白，键盘消失
//        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecv:)];
//        [self.view addGestureRecognizer:singleTap];//这个可以加到任何控件上,比如你只想响应WebView，我正好填满整个屏幕
    //    singleTap.delegate = self;
    //    singleTap.cancelsTouchesInView = NO;
//    self.wkWebView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
        _wkWebView.scrollView.delegate = self;
}
//// webview滚动，键盘就消失

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self keyBdDismiss];

}
-(void)keyBdDismiss{
//    [_wkWebView evaluateJavaScript:@"document.activeElement.blur();" completionHandler:nil];
    [_wkWebView endEditing:YES];
}
//  移除键盘上面的accessView
-(void)keyBoardShow{
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

-(void) removeKeyboard {
    
}
//  设置点击分享后的覆盖视图
-(void)setCover
{
    // 弹出蒙版
    self.seleView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.seleView.backgroundColor = [UIColor blackColor];
    self.seleView.alpha = 0;
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureRecv)];
    [self.seleView addGestureRecognizer:gesture];
    self.seleView.y = [UIScreen mainScreen].bounds.size.height;
    [self.view addSubview:self.seleView];
    
    // 添加分享对象
    JudgeViewType logType;
    logType = 0;
    self.seleObj = [JudgeLogView  instanceJudgeViewStyle:logType];
    //    self.seleObj.width = 20;
    self.seleObj.delegate = self;
//    self.seleObj.alpha = 0;
    self.seleObj.center = self.view.center;
    self.seleObj.y = [UIScreen mainScreen].bounds.size.height;
    [self.view addSubview:self.seleObj];
    
}
#pragma mark -- return click
-(void)returnClick:(UIButton*)returnBtn{
    
    [_wkWebView goBack];
    //    [self.webView goBack];
}
#pragma mark 弹出分享界面


-(void)shareRequest:(UIButton*)shareBtn
{   // 键盘消失
    [self keyBdDismiss];
    //    0 蒙版走起
    self.seleView.y = 0;
    self.seleView.alpha = 0.1;
    //1 弹出SeleObjView
    SeleObjView* sele = self.seleObjView;
    //    sele.x = CGRectGetMaxX(shareBtn.frame) + sele.width;
    //    sele.y = CGRectGetMaxY(shareBtn.frame);
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
        if (tag == 2) {
            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
//            [shareParams SSDKSetupWeChatParamsByText:shareDcrp title:shareTitle url:sharUrl thumbImage:shareImageUrl image:nil musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeWebPage forPlatformSubType:22];
//
//            [shareParams SSDKSetupQQParamsByText:shareDcrp title:shareTitle url:sharUrl thumbImage:shareImageUrl image:nil type:SSDKContentTypeWebPage forPlatformSubType:24];
           
            
            [shareParams SSDKSetupShareParamsByText:shareTitle
                                             images:shareImageUrl
                                                url:sharUrl
                                              title:shareDcrp
                                               type:SSDKContentTypeWebPage];
           
            //2、分享（可以弹出我们的分享菜单和编辑界面）
            [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                     items:nil
                               shareParams:shareParams
                       onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                           
                           switch (state) {
                               case SSDKResponseStateSuccess:
                               {
                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                       message:nil
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"确定"
                                                                             otherButtonTitles:nil];
                                   [alertView show];
                                   break;
                               }
                               case SSDKResponseStateFail:
                               {
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                                   message:[NSString stringWithFormat:@"%@",error]
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil, nil];
                                   [alert show];
                                   break;
                               }
                               default:
                                   break;
                           }
                       }
             ];
        }
}
// 点击 qq 或 微信 分享
-(void)changeScene:(int)scene{
    
    
}

-(void)qqShareSele:(int)tag{

}

#pragma mark delegate of  webview
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if (_clickedUrl) {
    [self.leftNaviItem setHidden:NO];
    }
    NSString* strHtml = navigationAction.request.URL.absoluteString;
    _clickedUrl = strHtml;
    
    
    if([strHtml rangeOfString:WxLoginClick].location != NSNotFound){
        [self loginWx];
//        [_coverView removeFromSuperview];
    }
    if([strHtml rangeOfString:QQloginClick].location != NSNotFound)//_roaldSearchTdecidePolicyForNavigationActionext
    {
        [self loginQQ];
//        [_coverView removeFromSuperview];
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
   
    [self setCompArr];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [_wkWebView stopLoading];
    //    NSLog(@"didFailProvisionalNavigation error%@",error);
    if ([error code] == NSURLErrorCancelled) {
        return;
    }
}
#pragma  mark  登录
-(void)loginQQ{
//    [UMSocialQQHandler setQQWithAppId:@"101227504" appKey:@"02eae420e660266458966976d75b9ecc" url:HomeRequest];
//
    [ShareSDK getUserInfo:SSDKPlatformTypeQQ
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {
             
//             NSLog(@"uid=%@",user.uid);
//             NSLog(@"%@",user.credential);
//             NSLog(@"token=%@",user.credential.token);
//             NSLog(@"nickname=%@",user.nickname);
            NSURL* url = [NSURL URLWithString: QQLoginUrl(user.uid, user.credential.token)];
             NSURLRequest* request = [NSURLRequest requestWithURL:url];
             [_wkWebView loadRequest:request];
             
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

//    [ShareSDK getUserInfo:SSDKPlatformTypeWechat
//           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
//     {
//         
//         if (state == SSDKResponseStateSuccess)
//         {
//             NSLog(@"uid=%@",user.uid);
//             NSLog(@"%@",user.credential);
//             NSLog(@"token=%@",user.credential.token);
//             NSLog(@"nickname=%@",user.nickname);
//             
//             NSURL* url = [NSURL URLWithString:WxreqWithCode(user.credential.token)];
//             NSURLRequest* request = [NSURLRequest requestWithURL:url];
//             [_wkWebView loadRequest:request];
//         }
//         else
//         {
//             NSLog(@"%@",error);
//         }
//     }];
}
//  Delegate  of   WXManager
// delegate of  WeixinLogin
- (void)WxManagerDidRecvAuthResponse:(SendAuthResp *)response{
    NSString* res = WxreqWithCode(response.code);
    //    NSLog(@"code %@: ",res);
    //    041sB2vp0NkBPc1ZcOwp0023vp0sB2vl
    if (res) {
        //        [self.webView loadRequest:[NSURLRequest requestWithString:res]];
        [ _wkWebView loadRequest:[NSURLRequest requestWithString:res]];
    }
    else [_wkWebView loadRequest:[NSURLRequest requestWithString:MembCenter]];
    
    //    [self getTokenWithCode:response.code];
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

#pragma mark  新版本提示更新
// 新版本提示版
-(void)newVersionTest{
    
    //    http://itunes.apple.com/lookup?id=1104919620
    NSString* res = @"http://itunes.apple.com/lookup?id=1121880649";
    NSURL* jsonUrl = [NSURL URLWithString:res];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:res]];
    
    
     NSData *jsonData = [NSData dataWithContentsOfURL:jsonUrl];
    //将请求的url数据放到NSData对象中

    NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    NSArray *infoArray = [weatherDic objectForKey:@"results"];
    NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
    // 从返回的JSON数据中获取新版本号和下载地址
    NSString *latestVersion = [releaseInfo objectForKey:@"version"];
    // 网络版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion =  [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSString *trackViewUrl = [releaseInfo objectForKey:@"trackViewUrl"];
    NSURLRequest* reqDdwnlod = [NSURLRequest requestWithString:trackViewUrl];
    // 开启新线程加载下载页面
    if(![latestVersion isEqualToString:currentVersion]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            [self addAlertNewVsion:reqDdwnlod];
        });
    }

    
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    }
// 设置弹出框
-(void)addAlertNewVsion:(NSURLRequest*)trackViewUrl{
    
    UIAlertController* alertVc = [UIAlertController alertControllerWithTitle:@"屹尚网新版本" message:@"请去AppStore里更新" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action1= [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
//    UIAlertAction* action2= [UIAlertAction actionWithTitle:@"现在去" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self.wkWebView loadRequest:trackViewUrl];
//    }];
    
    [alertVc addAction:action1];
//    [alertVc addAction:action2];
    [self presentViewController:alertVc animated:YES completion:^{
        
    }];
}
#pragma mark  预备和善后
-(void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter* center =[NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyBoardShow) name:UIKeyboardWillShowNotification object:nil];
    
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

// 善后
-(void)viewWillDisappear:(BOOL)animated{
    _wkWebView.navigationDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// 点击蒙版,消失
-(void)gestureRecv{
    [self coverDismiss];
}
-(void)coverDismiss{
    [self.seleObjView removeFromSuperview];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.seleView.y = [UIScreen mainScreen].bounds.size.height;
        self.seleObj.y = self.view.height;
    }];
    [UIView animateWithDuration:0.3 animations:^{
        self.seleView.alpha =0;
        self.seleObj.alpha =0;
    }];
}
@end
