//
//  TYDebugLog.m
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYDebugLog.h"

@implementation TYDebugLog

+ (void)debug:(id)debug {
#ifdef DEBUG
    NSLog(@"debug -> %@", debug);
#endif
}

+ (void)debugFromat:(NSString *)format ap:(va_list)ap {
#ifdef DEBUG
    NSLogv(format, ap);
#endif
}
+ (void)debugFormat:(id)debug, ... {
#ifdef DEBUG
    va_list ap;
    va_start(ap, debug);
    [self debugFromat:debug ap:ap];
    va_end(ap);
#endif
}

+ (void)error:(id)error {
#ifdef DEBUG
    NSLog(@"error -> %@", error);
#endif
}

+ (void)errorFormat:(NSString *)error, ... {
#ifdef DEBUG
    va_list ap;
    va_start(ap, error);
    [self debugFromat:error ap:ap];
    va_end(ap);
#endif
}

+ (void)show:(id)obj {
#ifdef DEBUG
    NSLog(@"%@", obj);
#endif
}


@end
