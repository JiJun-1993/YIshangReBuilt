//
//  JudgeLogView.h
//  屹尚网
//
//  Created by mac on 16/7/25.
//  Copyright © 2016年 Jijun_iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, JudgeViewType) {
    JudgeViewBothINstalled = 0,
    JudgeViewOnlyQQ, 
    JudgeViewOnlyWx
};

@class JudgeLogView;
@protocol JudgeLogViewDelegate <NSObject>
@required
-(void)changeScene:(int)scene;
-(void)qqShareSele:(int)tag;
@end
@interface JudgeLogView : UIView
@property(nonatomic,weak)id<JudgeLogViewDelegate> delegate;
+(JudgeLogView *)instanceJudgeViewStyle:(JudgeViewType)style;
@end
