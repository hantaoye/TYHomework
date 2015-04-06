//
//  TYThread.h
//  TYHomework
//
//  Created by taoYe on 15/4/7.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYThread : NSObject

void go(dispatch_block_t b);
void run(dispatch_block_t b);

@end
