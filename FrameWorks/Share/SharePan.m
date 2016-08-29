//
//  SharePan.m
//  YIshangReBuilt
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 Yishang. All rights reserved.
//

#import "SharePan.h"

@implementation SharePan

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(instancetype)sharePanWithRect:(CGRect)rect{
    SharePan* sharePan  = [[SharePan alloc]initWithFrame:rect];
    return sharePan;
}
-(instancetype)initWithFrame:(CGRect)frame{
   self =  [super initWithFrame:frame];
    if (!self) {
        
    }
    return self;
}
-(void)layoutSubviews{
     

}
@end
