//
//  TYNameVerify.m
//  TYHomework
//
//  Created by taoYe on 15/4/7.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYNameVerify.h"
#import "TYPasswordEncoder.h"

@implementation TYNameVerify
+ (BOOL)verifyShort:(NSString *)name {
    return [name complexLength] >= 4;
}

+ (BOOL)verifyLong:(NSString *)name {
    return [name complexLength] <= 14;
}

+ (BOOL)verify:(NSString *)name {
    NSInteger l = [name complexLength];
    if (l <= 14 && l >= 4) {
        return YES;
    }
    return NO;
}

@end
