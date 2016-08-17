//
//  CoverVc.m
//  屹尚网
//
//  Created by mac on 16/7/5.
//  Copyright © 2016年 Jijun_iOS. All rights reserved.
//

#import "SeleObjView.h"

@interface SeleObjView ()

@end

@implementation SeleObjView

+(SeleObjView*)seleView{
    NSArray* sele = [[NSBundle mainBundle] loadNibNamed:@"SeleObjView" owner:nil options:nil];
    return sele[0];
}
+(SeleObjView*)showWithPoint:(CGRect)rect{
    SeleObjView* sele = [[NSBundle mainBundle] loadNibNamed:@"SeleObjView" owner:nil options:nil][0];
    sele.x = CGRectGetMaxX(rect) + sele.width;
    sele.y = CGRectGetMaxY(rect);
//    UIView* view  = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
////    view.backgroundColor = [UIColor redColor];
//    [view addSubview:sele];
//    [JJKeyWindow addSubview:view];
    return sele; 
}
- (IBAction)seleClick:(UIButton*)sender {
    if ([self.delegate respondsToSelector:@selector(seleObjViewWithTag:)]) {
//        [self.delegate seleObjViewWithTag:sender.tag];
        [self.delegate seleObjViewWithTag:sender.tag];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
