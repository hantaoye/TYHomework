//
//  TYViewControllerLoader.m
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYViewControllerLoader.h"
#import "TYHomeViewController.h"
#import "TYWelcomeViewController.h"
#import "TYLoginViewController.h"

@implementation TYViewControllerLoader

+ (void)loadRootVC:(UIViewController *)rootVC {
    if (!rootVC) return;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            window.rootViewController = rootVC;
            [window makeKeyAndVisible];
        });
    } else {
        window.rootViewController = rootVC;
        [window makeKeyAndVisible];
    }
}

+ (void)loadMainEntry {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self loadRootVC:[mainStoryboard instantiateInitialViewController]];
}

+ (void)loadResgiterEntry {
    UIStoryboard *registerStoryboard = [UIStoryboard storyboardWithName:@"TYRegisterViewController" bundle:nil];
    [self loadRootVC:[registerStoryboard instantiateInitialViewController]];
}

+ (void)layout {
    [self loadResgiterEntry];
}


@end
