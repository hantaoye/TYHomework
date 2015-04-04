//
//  TYShareStorage.m
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYShareStorage.h"
#import "TYSharePath.h"

@interface TYShareStorage ()

@property (nonatomic, copy) NSString *path;

@end

@implementation TYShareStorage

- (void)synchronize {
    [[NSKeyedArchiver archivedDataWithRootObject:self] writeToFile:_path atomically:YES];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ([self initWithCoder:aDecoder]) {
        [self decode:aDecoder];
    }
    return self;
}

- (void)encode:(NSCoder *)encoder {
    [self encode:encoder];
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
        }
    });
    return storage;
}


@end
