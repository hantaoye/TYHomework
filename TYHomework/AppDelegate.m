//
//  AppDelegate.m
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "AppDelegate.h"
#import <VCTransitionsLibrary/CEBaseInteractionController.h>
#import <VCTransitionsLibrary/CEReversibleAnimationController.h>
#import "TYAnimationController.h"
#import "TYShareStorage.h"
#import <VCTransitionsLibrary/CECrossfadeAnimationController.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.navigationControllerAnimationController = [TYAnimationController new];
    self.settingsAnimationController = [CECrossfadeAnimationController new];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[TYShareStorage shareStorage] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[TYShareStorage shareStorage] synchronize];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[TYShareStorage shareStorage] synchronize];
}

@end
