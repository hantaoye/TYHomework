//
//  RSPlayerHelper.h
//  FITogether
//
//  Created by taoYe on 15/3/23.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RSPlayerView;

@interface RSPlayerHelper : NSObject
+ (instancetype)currentPlayerHelper;
- (void)setCurrentTime:(CGFloat)currentTime indexPath:(NSIndexPath *)indexPath;
- (CGFloat)getCurrentTimeWithIndexPath:(NSIndexPath *)indexPath;
@end
