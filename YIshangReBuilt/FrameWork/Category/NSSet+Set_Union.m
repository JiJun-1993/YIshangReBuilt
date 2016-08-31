//
//  NSSet+Set_Union.m
//  YIshangReBuilt
//
//  Created by mac on 16/8/31.
//  Copyright © 2016年 Yishang. All rights reserved.
//

#import "NSSet+Set_Union.h"

@implementation NSSet (Set_Union)
+(NSArray*)unionSetOfA:(NSArray*)arrayA arrayB:(NSArray*)arrayB{
    NSMutableArray* contain = [arrayB mutableCopy];
    for (NSObject* obj in arrayA) {
        if (![arrayB containsObject:obj]) {
            [contain addObject:obj];
        }
    }
    return [contain copy];
}
@end
