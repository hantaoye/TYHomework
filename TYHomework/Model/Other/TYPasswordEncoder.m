//
//  TYPasswordEncoder.m
//  TYHomework
//
//  Created by taoYe on 15/4/6.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYPasswordEncoder.h"
#import <CommonCrypto/CommonCrypto.h>
#import <zlib.h>

@implementation NSString (length)

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

@implementation TYPasswordEncoder
+ (NSString *)encode:(NSString *)string {
    return [string sha1];
}
+ (NSString *)encodeWechat:(NSString *)openID {
    return [[NSString alloc] initWithFormat:@"%ld", [openID crc32]];
}


@end