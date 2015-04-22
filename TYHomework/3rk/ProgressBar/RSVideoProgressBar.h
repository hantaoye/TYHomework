//
//  ProcessBar.h
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-13.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <UIKit/UIKit.h>
#import "SBCaptureDefine.h"

#define BAR_ORANGE_COLOR [UIColor orangeColor]

typedef NS_ENUM(NSInteger, RSVideoProgressBarProgressStyle) {
    ProgressBarProgressStyleNormal,
    ProgressBarProgressStyleDelete,
} ;

@interface RSVideoProgressBar : UIView

+ (RSVideoProgressBar *)getInstance;

- (void)setLastProgressToStyle:(RSVideoProgressBarProgressStyle)style;
- (void)setLastProgressToWidth:(CGFloat)width;

- (void)setIntervalWithX:(CGFloat)X;

- (void)deleteLastProgress;
- (void)addProgressView;

- (void)stopShining;
- (void)startShining;
- (BOOL)isShining;

@end
