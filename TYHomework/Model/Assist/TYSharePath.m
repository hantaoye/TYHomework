//
//  TYSharePath.m
//  TYHomework
//
//  Created by taoYe on 15/3/5.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYSharePath.h"

@implementation TYSharePath

+ (NSString *)getShareStoragePath {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:TYStoragePathComponent];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fullPath = [path stringByAppendingPathComponent:@"storage.plist"];
    return fullPath;
}

+ (NSString *)getAccountDataBasePath {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:TYStoragePathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
//    NSString *fullPath = [path stringByAppendingPathComponent:@"account.db"];
    return path;
}

+ (NSString *)getNoteDataBasePath {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:TYStoragePathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
@end
