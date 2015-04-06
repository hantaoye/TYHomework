//
//  TYEmailVerify.h
//  TYHomework
//
//  Created by taoYe on 15/4/7.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYEmailVerify : NSObject
+ (BOOL)verify:(NSString *)email;
+ (BOOL)isValidEmail:(NSString *)checkString strictFilter:(BOOL)strict;

@end
