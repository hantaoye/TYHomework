//
//  TYAccount.h
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYObject.h"

@interface TYAccount : TYObject <NSCoding>

@property (nonatomic, copy) NSString *access_token;

/** fdasfa*/
@property (nonatomic, strong) NSDate *expiresTime; // 账号的过期时间

@property (nonatomic, copy) NSString *name;//用户名

@property (nonatomic, copy) NSString *account;

@property (nonatomic, copy) NSString *pasword;

@property (nonatomic, copy) NSString *profileImageName;//头像


+ (instancetype)currentAccount;

@end
