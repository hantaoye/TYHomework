//
//  TYPasswordEncoder.h
//  TYHomework
//
//  Created by taoYe on 15/4/6.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Length)
- (NSInteger)complexLength;
@end

@interface TYPasswordEncoder : NSObject
+ (NSString *)encode:(NSString *)string;
+ (NSString *)encodeWechat:(NSString *)openID;

@end
