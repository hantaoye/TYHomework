//
//  TYThread.m
//  TYHomework
//
//  Created by taoYe on 15/4/7.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYThread.h"

@implementation TYThread
void go(dispatch_block_t b) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 2), b);
}

void run(dispatch_block_t b) {
    if ([NSThread isMainThread]) {
        b();
    } else {
        dispatch_async(dispatch_get_main_queue(), b);
    }
}

@end
