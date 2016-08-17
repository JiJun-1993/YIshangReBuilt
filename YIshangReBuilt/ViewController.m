//
//  ViewController.m
//  YIshangReBuilt
//
//  Created by mac on 16/7/31.
//  Copyright © 2016年 Yishang. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#define screenBounds [UIScreen mainScreen].bounds
#define NaviHeight 55
#define Margin 5
#define ItemSize 24
#define sysFontSize  16
#define HomeRequest @"http://www.vipysw.com/mobile/"

@interface ViewController ()<WKNavigationDelegate>
@property(nonatomic,strong)WKWebView* wkWebView;

//@property (weak, nonatomic) IBOutlet UIWebView *wkWebView;

@property(nonatomic,strong)UIView* naviView;

@property(strong,nonatomic)UIButton* leftNaviItem;
@property(strong,nonatomic)UIButton* btnShare;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setNaviBar];
    
    [self initParameter];
    
    [self setMainPage ];
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
//    _clickedUrl = nil;
    //  02  初始化新的webView
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    _wkWebView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:config];
    
    _wkWebView.x = 0;
    _wkWebView.y = CGRectGetMaxY(self.naviView.frame);
    _wkWebView.width = screenBounds.size.width;
    _wkWebView.height = (screenBounds.size.height - self.naviView.height);
    _wkWebView.navigationDelegate = self;
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

#pragma mark -- return click
-(void)returnClick:(UIButton*)returnBtn{
    
    [_wkWebView goBack];
    //    [self.webView goBack];
}
#pragma mark 弹出分享界面
-(void)shareRequest:(UIButton*)shareBtn
{

}
// delegate of  webview
-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
