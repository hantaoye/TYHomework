//
//  TYWirteHelp.m
//  TYHomework
//
//  Created by taoYe on 15/4/23.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYWriteHelp.h"

@implementation TYWriteHelp

+ (instancetype)shareWriteHelp {
    static TYWriteHelp *__help = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __help = [[TYWriteHelp alloc] init];
    });
    return __help;
}

@end
