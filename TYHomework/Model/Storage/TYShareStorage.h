//
//  TYShareStorage.h
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYObject.h"

@class TYAccountDao, TYAccount, TYNoteDao, TYNote;
@interface TYShareStorage : TYObject <NSCoding>

@property (strong, nonatomic) TYAccountDao *accountDao;
@property (strong, nonatomic) TYAccount *account;
@property (strong, nonatomic) TYNoteDao *noteDao;
@property (strong, nonatomic) TYNote *note;


- (void)synchronize;
- (void)setupCacheStorageIfNecessary;

+ (instancetype)shareStorage;

@end
