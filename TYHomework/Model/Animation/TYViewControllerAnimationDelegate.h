//
//  TYViewControllerAnimationDelegate.h
//  TYHomework
//
//  Created by taoYe on 15/4/6.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TYViewControllerAnimationDelegate : NSObject <UIViewControllerTransitioningDelegate>

+ (instancetype)shareAnimationDelegate;

@end
