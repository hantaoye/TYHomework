//
//  TYNameVerify.h
//  TYHomework
//
//  Created by taoYe on 15/4/7.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYNameVerify : NSObject
+ (BOOL)verifyShort:(NSString *)name;
+ (BOOL)verifyLong:(NSString *)name;
+ (BOOL)verify:(NSString *)name;

@end
