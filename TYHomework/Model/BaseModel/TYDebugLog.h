//
//  TYDebugLog.h
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYObject.h"

@interface TYDebugLog : TYObject

+ (void)debug:(id)debug;
+ (void)debugFormat:(id)debug,...;

+ (void)error:(id)error;
+ (void)errorFormat:(NSString *)error,...;

+ (void)show:(id)obj;

@end
