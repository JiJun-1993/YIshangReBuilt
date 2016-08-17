//
//  CoverVc.h
//  屹尚网
//
//  Created by mac on 16/7/5.
//  Copyright © 2016年 Jijun_iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SeleObjView;
@protocol SeleObjViewDelegate <NSObject>

-(void)seleObjViewWithTag:(int)tag;
@end
@interface SeleObjView : UIView
@property(nonatomic,weak)id<SeleObjViewDelegate> delegate;
+(SeleObjView*)seleView;
+(SeleObjView*)showWithPoint:(CGRect)rect;
@end
