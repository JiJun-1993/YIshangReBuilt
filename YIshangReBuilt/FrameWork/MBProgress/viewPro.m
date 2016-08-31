//
//  viewPro.m
//  WebTest
//
//  Created by mac on 16/7/11.
//  Copyright © 2016年 Jijun_iOS. All rights reserved.
//

#import "viewPro.h"
@interface viewPro()
@property (weak, nonatomic) IBOutlet UILabel *Yi;
@property (weak, nonatomic) IBOutlet UILabel *Shang;
@property (weak, nonatomic) IBOutlet UILabel *Wang;

@property (weak, nonatomic) IBOutlet UIPageControl *pageCtr;


@end
@implementation viewPro

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        pageCtl = [[UIPageControl alloc]init];
//        pageCtl.numberOfPages = 4;
//        pageCtl.currentPage = 1;
//        [pageCtl setPageIndicatorTintColor:[UIColor grayColor]];
//        [pageCtl setCurrentPageIndicatorTintColor:[UIColor redColor]];
//        pageCtl.frame = CGRectMake(200, 200, 100, 20);
//        [self addSubview:pageCtl];
        
    }
    return self;
}
+(viewPro*)showProWithView{
    static viewPro *sharedView = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        UINib *nib = [UINib nibWithNibName:@"viewPro"
                                    bundle:nil];
        NSArray *nibViews = [nib instantiateWithOwner:self
                                              options:0];
        sharedView = nibViews[0];
    });
    return sharedView;
}
+(void)show{
    [[self showProWithView] startRoll];
}
-(void)startRoll{
   time = [NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(work) userInfo:nil repeats:YES];
//    time = [CADisplayLink  displayLinkWithTarget:self selector:@selector(work)];
    [[NSRunLoop mainRunLoop] addTimer:time forMode:NSDefaultRunLoopMode];
//    [time addToRunLoop:[NSRunLoop mainRunLoop]forMode:NSDefaultRunLoopMode];

}
-(void)stop{
    [time invalidate];
}
-(void)work{
    self.pageCtr.currentPage = (self.pageCtr.currentPage + 1) % self.pageCtr.numberOfPages;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // 轻触的时候结束加载
    [self stop];
    if ([self.delegate respondsToSelector:@selector(proTouchDismissWithView:)]) {
        [self.delegate proTouchDismissWithView:self];
    }
}

@end
