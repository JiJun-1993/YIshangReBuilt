//
//  ShareCustom.m
//  YIshangReBuilt
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 Yishang. All rights reserved.
//

#import "ShareCustom.h"

#import <ShareSDK/SSDKTypeDefine.h>


//设备物理大小
#define kScreenWidth   [UIScreen mainScreen].bounds.size.width
#define kScreenHeight  [UIScreen mainScreen].bounds.size.height
#define SYSTEM_VERSION   [[UIDevice currentDevice].systemVersion floatValue]

#define JJWindow  [UIApplication sharedApplication].keyWindow;
//屏幕宽度相对iPhone6屏幕宽度的比例
#define KWidth_Scale    [UIScreen mainScreen].bounds.size.width/375.0f
@implementation ShareCustom
static id _publishContent;//类方法中的全局变量这样用（类型前面加static）
/*
 自定义的分享类，使用的是类方法，其他地方只要 构造分享内容publishContent就行了
 */
-(void)shareViewShow{
//    _publishContent = publishContent;
    UIWindow *window = JJWindow;
    [window setUserInteractionEnabled:YES];
    // 添加蒙版
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    blackView.backgroundColor = [UIColor lightGrayColor];
    blackView.alpha = 0.2f;
    blackView.tag = 440;
    [window addSubview:blackView];
    
//    添加分享items按钮
    UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth-300*KWidth_Scale)/2.0f, (kScreenHeight-270*KWidth_Scale)/2.0f, 300*KWidth_Scale, 270*KWidth_Scale)];
    
    shareView.backgroundColor = [UIColor whiteColor];
    shareView.tag = 441;
    [window addSubview:shareView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, shareView.width, 45*KWidth_Scale)];
    titleLabel.text = @"分享到";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:15*KWidth_Scale];
    titleLabel.textColor = [UIColor redColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [shareView addSubview:titleLabel];
    
    NSArray *btnImages = @[@"icon_invite_weixin.png", @"icon_invite_pengyou.png", @"icon_invite_qq.png", @"icon_invite_kongjian.png", @"IOS-微信收藏@2x.png", @"IOS-微博@2x.png", @"IOS-豆瓣@2x.png", @"IOS-短信@2x.png"];
    NSArray *btnTitles = @[@"微信好友", @"微信朋友圈", @"QQ好友", @"QQ空间", @"微信收藏", @"新浪微博", @"豆瓣", @"短信"];
    
    CGFloat margin = kScreenWidth / 15;
    for (NSInteger i=0; i<8; i++) {
        CGFloat top = 0.0f;
        if (i<4) {
            top = 10*KWidth_Scale;
            
        }else{
            top = 90*KWidth_Scale;
        }
        
        CGFloat itemSize = 70 * KWidth_Scale;
        CGFloat y = (i / 4) * (margin + itemSize) + margin;

        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10*KWidth_Scale+(i%4)*70*KWidth_Scale, y , itemSize, itemSize)];
        [button setImage:[UIImage imageNamed:btnImages[i]] forState:UIControlStateNormal];
        [button setTitle:btnTitles[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:11*KWidth_Scale];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor colorWithString:@"2a2a2a"] forState:UIControlStateNormal];
        
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 15*KWidth_Scale, 30*KWidth_Scale, 15*KWidth_Scale)];
        if (SYSTEM_VERSION >= 8.0f) {
            [button setTitleEdgeInsets:UIEdgeInsetsMake(45*KWidth_Scale, -40*KWidth_Scale, 5*KWidth_Scale, 0)];
        }else{
            [button setTitleEdgeInsets:UIEdgeInsetsMake(45*KWidth_Scale, -90*KWidth_Scale, 5*KWidth_Scale, 0)];
        }
        
        button.tag = 331+i;
        [button addTarget:self action:@selector(btnResponse) forControlEvents:UIControlEventTouchUpInside];
        
        [shareView addSubview:button];
    }
    UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake((shareView.width-40*KWidth_Scale)/2.0f, shareView.height-40*KWidth_Scale-18*KWidth_Scale, 40*KWidth_Scale, 40*KWidth_Scale)];
    [cancleBtn setBackgroundImage:[UIImage imageNamed:@"IOS-取消@2x.png"] forState:UIControlStateNormal];
    cancleBtn.tag = 339;
    [cancleBtn addTarget:self action:@selector(btnResponse) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:cancleBtn];
    
    //为了弹窗不那么生硬，这里加了个简单的动画
    shareView.transform = CGAffineTransformMakeScale(1/300.0f, 1/270.0f);
    blackView.alpha = 0;
    [UIView animateWithDuration:0.35f animations:^{
        shareView.transform = CGAffineTransformMakeScale(1, 1);
        blackView.alpha = 0.5;
    } completion:^(BOOL finished) {
        
    }];
    
    
}
-(void)setParameters:(NSMutableDictionary *)parameters{
    _parameters = parameters;
}
-(void)btnResponse{
    
}


-(void)shareBtnClick:(UIButton *)btn
{
    //    NSLog(@"%@",[ShareSDK version]);
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *blackView = [window viewWithTag:440];
    UIView *shareView = [window viewWithTag:441];
    
    //    为了弹窗不那么生硬，这里加了个简单的动画
    shareView.transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateWithDuration:0.35f animations:^{
        shareView.transform = CGAffineTransformMakeScale(1/300.0f, 1/270.0f);
        blackView.alpha = 0;
    } completion:^(BOOL finished) {
        
        [shareView removeFromSuperview];
        [blackView removeFromSuperview];
    }];
    
    int shareType = 0;
    id publishContent = _publishContent;
    switch (btn.tag) {
        case 331:
        {
            shareType = SSDKPlatformSubTypeWechatSession;
        }
            break;
            
        case 332:
        {
            shareType = SSDKPlatformSubTypeWechatTimeline;
        }
            break;
            
        case 333:
        {
            shareType = SSDKPlatformSubTypeQQFriend;
        }
            break;
            
        case 334:
        {
            shareType = SSDKPlatformSubTypeQZone;
        }
            break;
            
        case 335:
        {
            shareType = SSDKPlatformSubTypeWechatFav;
        }
          break;
             default:
         break;
    }
    /*
     调用shareSDK的无UI分享类型，
     链接地址：http://bbs.mob.com/forum.php?mod=viewthread&tid=110&extra=page%3D1%26filter%3Dtypeid%26typeid%3D34
     */
    [ShareSDK share:shareType parameters:_parameters onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        
        switch (state) {
            case SSDKResponseStateSuccess:
            {
//                alertAction = [UIAlertAction actionWithTitle:@"分享成功" style:UIAlertActionStyleCancel handler:nil];
                NSLog(@"分享成功 ");
                break;
            }
            case SSDKResponseStateFail:
            {
//                alertAction = [UIAlertAction actionWithTitle:@"分享成功" style:UIAlertActionStyleCancel handler:nil];
                 NSLog(@"分享失败");
                break;
            }
            default:
                break;
        }
    }];
}

-(void)shareViewHidden{

}

@end