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

@property (assign, nonatomic) long long ID;

@property (nonatomic, copy) NSString *name;//用户名
@property (assign, nonatomic) NSInteger age;

@property (nonatomic, copy) NSString *account;

@property (nonatomic, copy) NSString *password;

@property (nonatomic, copy) NSString *profileImageURL;//头像

@property (copy, nonatomic) NSString *avatarURL;
@property (copy, nonatomic) NSString *introduction;

@property (assign, nonatomic) NSInteger gender;//性别

@property (copy, nonatomic) NSString *location;




+ (instancetype)currentAccount;

- (instancetype)initWithName:(NSString *)name ID:(long long)ID password:(NSString *)password profileIamgeURL:(NSString *)profileImageURL introduction:(NSString *)introduction;
@end
