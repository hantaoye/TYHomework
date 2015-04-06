//
//  TYEmailVerify.m
//  TYHomework
//
//  Created by taoYe on 15/4/7.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYEmailVerify.h"

@implementation TYEmailVerify

+ (BOOL)verify:(NSString *)email {
    return [self isValidEmail:email strictFilter:YES];
}

+ (BOOL)isValidEmail:(NSString *)checkString strictFilter:(BOOL)strict {
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = strict ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (!emailTest) {
        return NO;
    }
    return [emailTest evaluateWithObject:checkString];
}

@end
