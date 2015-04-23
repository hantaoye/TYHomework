//
//  TYViewControllerHelp.m
//  TYHomework
//
//  Created by taoYe on 15/4/23.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYViewControllerHelp.h"

@implementation TYViewControllerHelp

+ (instancetype)shareHelp {
    static TYViewControllerHelp *__help = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __help = [[TYViewControllerHelp alloc] init];
    });
    return __help;
}

@end
