//
//  JudgeLogView.m
//  屹尚网
//
//  Created by mac on 16/7/25.
//  Copyright © 2016年 Jijun_iOS. All rights reserved.
//

#import "JudgeLogView.h"

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
    
    
    return nibView[0];
}
-(IBAction)seleShare:(UIButton*)sender{
    //    [self removeFromSuperview];
    //    [CZCover dismiss];
    if ([_delegate respondsToSelector:@selector(changeScene:)]) {
        [_delegate  changeScene:sender.tag];
    }
}
-(IBAction)qqShare:(UIButton*)sender{
    //    [CZCover dismiss];
    if ([_delegate respondsToSelector:@selector(qqShareSele:)]) {
        [_delegate  qqShareSele:sender.tag];
    }
}

@end
