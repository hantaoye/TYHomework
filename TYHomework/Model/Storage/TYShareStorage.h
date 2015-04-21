//
//  TYShareStorage.h
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYObject.h"

@class TYAccountDao, TYAccount;
@interface TYShareStorage : TYObject <NSCoding>

@property (strong, nonatomic) TYAccountDao *accountDao;
@property (strong, nonatomic) TYAccount *account;

- (void)synchronize;


+ (instancetype)shareStorage;

@end
