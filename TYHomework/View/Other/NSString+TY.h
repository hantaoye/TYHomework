//
//  NSString+TY.h
//  TYStatus
//
//  Created by qingyun on 14/10/11.
//  Copyright (c) 2014年 cn.TY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TY)

- (CGSize)sizeWithFontSize:(int)fontSize maxWidth:(CGFloat)maxWidth;

- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth;
- (NSInteger)complexLength;
- (NSString *)sha1;
- (unsigned long)crc32;
@end
