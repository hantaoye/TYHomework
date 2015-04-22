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
#import "TYAccountMapper.h"

static NSString *RSAccountSQLAddAccount = @"replace into table_account (id, name, avatar) values (?, ?, ?);";
static NSString *RSAccountSQLAddAccountWithName = @"replace into table_account (email, account_password, name, avatar, account) values (?, ?, ?, ?, ?);";

static NSString *RSAccountSQLRemoveAccount = @"delete from table_account where id = ?";
static NSString *RSAccountSQLUpdateAccount = @"update table_account set name = ?, avatar = ? account = ? where email = ?";
static NSString *RSAccountSQLUpdateAccountWithNickName = @"update table_account set name = ?, avatar = ?, nickName =? where id = ?";
static NSString *RSAccountSQLGetAccount = @"select id, name, avatar, nickName, timestamp from table_account where id = ?";
static NSString *RSAccountSQLMultiGetAccount = @"select id, name, avatar, nickName, timestamp from table_account where id in (%@)";

static NSString *RSAccountSQLCreateAccount = @"create table if not exists table_account(id integer primary key autoincrement, access_token text, email text, account_password text, name text, nickName text, avatar text, timestamp integer, account blob)";

static NSString *RSAccountSQLCheckAccount = @"select account from table_account where email = ? and account_password = ?";

static NSString *RSAccountSQLCheckEmail = @"select id, account from table_account where email = ?";


@interface TYAccountDao ()

@property (strong, nonatomic) TYDatabaseConnector *connector;

@end

@implementation TYAccountDao
+ (NSString *)daoName {
    return @"table_account";
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

- (instancetype)initWithConnector:(TYDatabaseConnector *)dataBaseConnector {
    if (self = [super init]) {
        _connector = dataBaseConnector;
        [self createTable];
    }
    return self;
}

- (void)createTable {
    [self.connector executeStatements:RSAccountSQLCreateAccount];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [self decode:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self encode:aCoder];
}

- (void)selectAccountWithEmail:(NSString *)email password:(NSString *)password action:(void(^)(TYAccount *account))action {
    [self.connector queryObjectWithActon:^(TYAccount *obj) {
        action(obj);
    } rowMapper:[[TYAccountMapper alloc] init] SQL:RSAccountSQLCheckAccount, email, password];
}

- (void)selectAccountWithEmail:(NSString *)email action:(void(^)(TYAccount *account))action {
    [self.connector queryObjectWithActon:^(id obj) {
        action(obj);
    } rowMapper:[[TYAccountMapper alloc] init] SQL:RSAccountSQLCheckEmail, email];
}

- (void)insertAccountWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name avatar:(NSString *)avatar action:(void (^)(TYAccount *))action {
    TYAccount *account = [[TYAccount alloc] init];
    account.email = email;
    account.password = password;
    account.name = name;
    account.avatarURL = avatar;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:account];
    if ([self.connector updateWithSQL:RSAccountSQLAddAccountWithName, email, password, name, avatar, data]) {
        action(account);
    } else {
        [RSProgressHUD showErrorWithStatus:@"注册失败"];
    }
}

- (BOOL)updateAccountWithAccountEmail:(NSString *)email account:(TYAccount *)account {
    if ([self.connector updateWithSQL:RSAccountSQLUpdateAccount, account.name, account.avatarURL, account, account.email]) {
        [RSProgressHUD showSuccessWithStatus:@"更新成功"];
        return YES;
    } else {
        [RSProgressHUD showErrorWithStatus:@"更新失败"];
        return NO;
    }
}

@end
