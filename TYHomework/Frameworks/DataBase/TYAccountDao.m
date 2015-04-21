//
//  TYAccountDao.m
//  TYHomework
//
//  Created by taoYe on 15/4/19.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYAccountDao.h"
#import "TYShareStorage.h"
#import "TYAccount.h"
#import "TYDatabaseConnector.h"

static NSString *RSAccountSQLAddAccount = @"replace into account (id, name, avatar) values (?, ?, ?)";
static NSString *RSAccountSQLAddAccountWithNickName = @"replace into account (id, name, avatar, nickName) values (?, ?, ?, ?)";
static NSString *RSAccountSQLRemoveAccount = @"delete from account where id = ?";
static NSString *RSAccountSQLUpdateAccount = @"update account set name = ?, avatar = ? where id = ?";
static NSString *RSAccountSQLUpdateAccountWithNickName = @"update account set name = ?, avatar = ?, nickName =? where id = ?";
static NSString *RSAccountSQLGetAccount = @"select id, name, avatar, nickName, timestamp from account where id = ?";
static NSString *RSAccountSQLMultiGetAccount = @"select id, name, avatar, nickName, timestamp from account where id in (%@)";

@interface TYAccountDao ()

@property (strong, nonatomic) TYDatabaseConnector *connector;

@end

@implementation TYAccountDao
+ (NSString *)daoName {
    return @"account";
}

+ (instancetype)sharedDao {
    return [[TYShareStorage shareStorage] accountDao];
}

- (BOOL)addAccount:(TYAccount *)account {
    return [[self connector] updateWithSQL:RSAccountSQLAddAccount, @([account ID]), [account name], [account avatarURL], nil];
}

- (BOOL)updateCachedAccount:(TYAccount *)account {
    return [[self connector] updateWithSQL:RSAccountSQLUpdateAccount, [account name], [account avatarURL], @([account ID]), nil];
}

@end
