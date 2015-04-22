//
//  TYAccountDao.h
//  TYHomework
//
//  Created by taoYe on 15/4/19.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TYDatabaseConnector;
@interface TYAccountDao : NSObject <NSCoding>
//- (void)getCurrentAccount;
- (instancetype)initWithConnector:(TYDatabaseConnector *)dataBaseConnector;

+ (instancetype)sharedDao;

- (void)selectAccountWithEmail:(NSString *)email password:(NSString *)password action:(void(^)(TYAccount *account))action;

- (void)insertAccountWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name avatar:(NSString *)avatar action:(void (^)(TYAccount *))action;

- (void)selectAccountWithEmail:(NSString *)email action:(void(^)(TYAccount *account))action;

- (BOOL)updateAccountWithAccountEmail:(NSString *)email account:(TYAccount *)account;

@end
