//
//  TYAccount.m
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

static NSString *__userIDKey = @"id";
static NSString *__nameKey = @"user_name";
static NSString *__genderKey = @"gender";
static NSString *__avatarURLStringKey = @"avatar";
static NSString *__passwordKey = @"password";
static NSString *__cardCountKey = @"cards";
static NSString *__continueCardsKey = @"continue_cards";
static NSString *__roleIDKey = @"role_id";


#import "TYAccount.h"
#import <libkern/OSAtomic.h>

static TYAccount *__account = nil;
static OSSpinLock __dispatchTokenLock = OS_SPINLOCK_INIT;
static dispatch_once_t __onceToken;

@implementation TYAccount

+ (instancetype)currentAccount {
    dispatch_once(&__onceToken, ^{
        __account = nil;
    });
    return __account;
}

+ (instancetype)reloadAccount:(TYAccount *)account {
    TYAccount *t = nil;
    OSSpinLockLock(&__dispatchTokenLock);
    __onceToken = 0;
    t = [self setCurrentAccount:account];
    OSSpinLockUnlock(&__dispatchTokenLock);
    return t;
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



+ (instancetype)setCurrentAccount:(TYAccount *)account {
    dispatch_once(&__onceToken, ^{
        __account = account;
    });
    return __account;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [self decode:aDecoder];
//        _name = [aDecoder decodeObjectForKey:__nameKey];
//        _gender = [aDecoder decodeIntegerForKey:__genderKey];
//        _avatarURL = [aDecoder decodeObjectForKey:__avatarURLStringKey];
//        _password = [aDecoder decodeObjectForKey:__passwordKey];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
//    [encoder encodeObject:_name forKey:__nameKey];
//    [encoder encodeInteger:_gender forKey:__genderKey];
//    [encoder encodeObject:_avatarURL forKey:__avatarURLStringKey];
//    [encoder encodeObject:_password forKey:__passwordKey];
    [self encode:encoder];
}


@end
