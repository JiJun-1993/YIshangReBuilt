//
//  viewPro.h
//  WebTest
//
//  Created by mac on 16/7/11.
//  Copyright © 2016年 Jijun_iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class viewPro;
@protocol viewProDelegate <NSObject>
@required
-(void)proTouchDismissWithView:(viewPro*)proView;

@end
@interface viewPro : UIView
{
//    UIPageControl* pageCtl;
//   CADisplayLink *time;
    NSTimer* time;
}
@property(nonatomic,weak)id<viewProDelegate> delegate;
+(viewPro*)showProWithView;
+(void)show;


-(void)startRoll;
@end
