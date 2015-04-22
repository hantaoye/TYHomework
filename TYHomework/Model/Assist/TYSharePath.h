//
//  TYSharePath.h
//  TYHomework
//
//  Created by taoYe on 15/3/5.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYObject.h"

@interface TYSharePath : TYObject

+ (NSString *)getShareStoragePath;

+ (NSString *)getAccountDataBasePath;

+ (NSString *)getNoteDataBasePath;
@end
