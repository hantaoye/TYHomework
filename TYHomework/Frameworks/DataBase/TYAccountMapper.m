//
//  TYAccountMapper.m
//  TYHomework
//
//  Created by taoYe on 15/4/21.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYAccountMapper.h"
#import <FMDB/FMDB.h>
#import "TYAccount.h"

@implementation TYAccountMapper

- (id)rowMapperWithResultSet:(FMResultSet *)resultSet {
    NSData *data = [resultSet objectForColumnName:@"account"];
    TYAccount *account = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    account.ID = [resultSet intForColumn:@"id"];
    return account;
}

@end
