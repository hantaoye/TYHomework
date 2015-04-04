//
//  TYAccount.m
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYAccount.h"

@implementation TYAccount

+ (instancetype)currentAccount {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static TYAccount *account = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        account = [super allocWithZone:zone];
    });
    return account;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [self decode:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [self encode:encoder];
}


@end
