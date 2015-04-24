//
//  TYShareStorage.m
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYShareStorage.h"
#import "TYSharePath.h"
#import "TYDebugLog.h"
#import "TYAccountDao.h"
#import "TYDatabaseConnector.h"
#import "TYAccount.h"
#import "TYNoteDao.h"
#import "TYNote.h"

static NSString *__accountKey = @"accountKey";
static NSString *__noteKey = @"noteKey";

static NSString *__pathKey = @"pathKey";

@interface TYShareStorage ()

@property (nonatomic, copy) NSString *path;

@property (strong, nonatomic) TYDatabaseConnector *accountDBC;
@property (strong, nonatomic) TYDatabaseConnector *noteDBC;
@property (strong, nonatomic) dispatch_queue_t syncQueue;

@end

@implementation TYShareStorage

- (void)synchronize {
    dispatch_sync(_syncQueue, ^{
    [[NSKeyedArchiver archivedDataWithRootObject:self] writeToFile:_path atomically:YES];
        return;
    });
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _syncQueue = dispatch_queue_create("com.RS-inc.sharedStorage.syncQueue", nil);
        _account = [aDecoder decodeObjectForKey:__accountKey];
        [TYAccount reloadAccount:_account];
        _note = [aDecoder decodeObjectForKey:__noteKey];
        _path = [aDecoder decodeObjectForKey:__pathKey];
        
        [self resetDatabase];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.path forKey:__pathKey];
    [aCoder encodeObject:self.account forKey:__accountKey];
    [aCoder encodeObject:self.note forKey:__noteKey];
}

+ (instancetype)shareStorage {
    static TYShareStorage *storage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       NSString *filePath = [TYSharePath getShareStoragePath];
        storage = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (!storage) {
            storage = [[TYShareStorage alloc] init];
            storage.path = filePath;
            storage.syncQueue = dispatch_queue_create("com.RS-inc.sharedStorage.syncQueue", nil);
            [storage resetDatabase];
        }
    });
    return storage;
}

- (void)resetDatabase {
    [TYDebugLog debug:NSStringFromSelector(_cmd)];
    _accountDBC = [[TYDatabaseConnector alloc] initWithPath:[TYSharePath getAccountDataBasePath] name:@"account.db"];
    _accountDao = [[TYAccountDao alloc] initWithConnector:_accountDBC];
    _noteDBC = [[TYDatabaseConnector alloc] initWithPath:[TYSharePath getNoteDataBasePath] name:@"note.db"];
    _noteDao = [[TYNoteDao alloc] initWithConnector:_noteDBC];
}

- (void)_setCurrentAccount:(TYAccount *)account {
    BOOL same = [[self account] isEqual:account];
    if (account) {
            [self resetDatabase];
            _account = account;
        } else {
            if (_accountDBC == nil) {
                [self resetDatabase];
            }
        }
    if (same && account) {
        return;
    }
    [self synchronize];
}

- (void)setupCacheStorageIfNecessary {
    if ([TYAccount currentAccount]) {
        [self _setCurrentAccount:[TYAccount currentAccount]];
        return;
    }
    [self resetDatabase];
    [self setCurrentAccount:[TYAccount currentAccount]];
}

- (void)setCurrentAccount:(TYAccount *)currentAccount {
 [TYAccount reloadAccount:currentAccount];
 [self _setCurrentAccount:currentAccount];
}


@end
