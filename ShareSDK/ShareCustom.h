//
//  ShareCustom.h
//  YIshangReBuilt
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 Yishang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareCustom : NSObject
@property(nonatomic,strong)NSMutableDictionary* parameters;

-(void)shareWithContent:(id)publishContent;//自定义分享界面
-(void)shareViewShow;
-(void)shareViewHidden;

@end
