//
//  AppDelegate.h
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CEBaseInteractionController, CEReversibleAnimationController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CEReversibleAnimationController *settingsAnimationController;
@property (strong, nonatomic) CEReversibleAnimationController *navigationControllerAnimationController;
@property (strong, nonatomic) CEBaseInteractionController *navigationControllerInteractionController;
@property (strong, nonatomic) CEBaseInteractionController *settingsInteractionController;

@end

