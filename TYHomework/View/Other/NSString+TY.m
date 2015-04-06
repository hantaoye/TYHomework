//
//  NSString+TY.m
//  TYStatus
//
//  Created by qingyun on 14/10/11.
//  Copyright (c) 2014年 cn.TY. All rights reserved.
//

#import "NSString+TY.h"
#import <Availability.h>
#import <zlib.h>
#import <CommonCrypto/CommonCrypto.h>

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

- (NSString *)sha1 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02X", digest[i]];
    }
    return output;
}

- (unsigned long)crc32
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return crc32(0, [data bytes], (int)[data length]);
}

//字符长度
- (NSInteger)complexLength {
    NSInteger strlength = 0;
    // 这里一定要使用gbk的编码方式，网上有很多用Unicode的，但是混合的时候都不行
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    char* p = (char*)[self cStringUsingEncoding:gbkEncoding];
    for (int i=0 ; i<[self lengthOfBytesUsingEncoding:gbkEncoding] ;i++) {
        if (p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

@end
