//
//  JudgeLogView.m
//  屹尚网
//
//  Created by mac on 16/7/25.
//  Copyright © 2016年 Jijun_iOS. All rights reserved.
//

#import "JudgeLogView.h"
@interface JudgeLogView()
@property (weak, nonatomic) IBOutlet UILabel *headView;


@end
@implementation JudgeLogView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(JudgeLogView *)instanceJudgeViewStyle:(JudgeViewType)style{
        NSArray* nibView;
//    定义xib加载的异常
//    NSException* exception = [NSException exceptionWithName:@"Xib 加载异常" reason:@"xib 加载异常" userInfo:nil ];
    @try {
        switch (style) {
            case 0:
                nibView =  [[NSBundle mainBundle] loadNibNamed:@"QQAndWx" owner:nil options:nil];
                break;
            case 1:
                nibView =  [[NSBundle mainBundle] loadNibNamed:@"QQCover" owner:nil options:nil];
                break;
            case 2:
                nibView =  [[NSBundle mainBundle] loadNibNamed:@"WxCover" owner:nil options:nil];
                break;
            default:
                break;
        }
    } @catch (NSException* exception) {
        NSLog(@" xib 加载异常");
        return nil;
    } @finally {
        
    }
    JudgeLogView* shareView =  nibView[0];
    shareView.layer.borderWidth = 1;
    shareView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    return shareView;
}
-(IBAction)seleShare:(UIButton*)sender{
    //    [self removeFromSuperview];
    //    [CZCover dismiss];

//    NSNumber* number = [NSNumber numberWithInteger:<#(NSInteger)#>]
//    
//    NSMutableArray* arrPlatform = @[SSDKPlatformSubTypeWechatSession,SSDKPlatformSubTypeWechatTimeline,SSDKPlatformSubTypeQQFriend,SSDKPlatformSubTypeQZone,SSDKPlatformSubTypeWechatFav];
    NSInteger type = 0;
    if ([_delegate respondsToSelector:@selector(changeScene:)]) {
        switch (sender.tag) {
            case 0:
                type = SSDKPlatformSubTypeWechatSession;
                break;
            case 1:
                type = SSDKPlatformSubTypeWechatTimeline;
                break;
            case 2:
                type = SSDKPlatformSubTypeQQFriend;
                break;
            case 3:
                type = SSDKPlatformSubTypeQZone;
                break;
            case 4:
                type = SSDKPlatformSubTypeWechatFav;
                break;
            default:
                break;
        }
        
        [_delegate  changeScene:type];
    }
}
//-(IBAction)qqShare:(UIButton*)sender{
//    //    [CZCover dismiss];
//    if ([_delegate respondsToSelector:@selector(qqShareSele:)]) {
//        [_delegate  qqShareSele:sender.tag];
//    }
//}

@end
