//
//  NSString+TY.m
//  TYStatus
//
//  Created by qingyun on 14/10/11.
//  Copyright (c) 2014年 cn.TY. All rights reserved.
//

#import "NSString+TY.h"
#import <Availability.h>


@implementation NSString (TY)

- (CGSize)sizeWithFontSize:(int)fontSize maxWidth:(CGFloat)maxWidth
{
    CGSize size = CGSizeZero;
    if (iOS7) {
#ifdef __IPHONE_7_0
        size = [self boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size;
#else
        size = [self sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)];
#endif   
    } else {
        size = [self sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)];
    }
    return size;
}

- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth
{
    CGSize size = CGSizeZero;
    if (iOS7) {
#ifdef __IPHONE_7_0
        size = [self boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size;
#else
        size = [self sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)];
#endif
    } else {
       size = [self sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)];

    }
    return size;

}


@end
