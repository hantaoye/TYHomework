//
//  TYAccount.m
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYAccount.h"

static TYAccount *__account = nil;


@implementation TYAccount

+ (instancetype)currentAccount {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __account = nil;
    });
    return __account;
}

//- (instancetype)initWithName:(NSString *)name ID:(long long)ID password:(NSString *)password profileIamgeURL:(NSString *)profileImageURL introduction:(NSString *)introduction {
//    if (self = [super init]) {
//        _name = name;
//        _ID = ID;
//        _password = password;
//        
//    }
//    return self;
//}

- (void)setCurrentAccount:(TYAccount *)account {
    __account = account;
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
