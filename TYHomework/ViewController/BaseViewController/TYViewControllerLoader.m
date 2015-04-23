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
#import "TYDrawViewController.h"

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
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"TYHomeViewController" bundle:nil];
    [self loadRootVC:[mainStoryboard instantiateInitialViewController]];
}

+ (void)loadResgiterEntry {
    UIStoryboard *registerStoryboard = [UIStoryboard storyboardWithName:@"TYRegisterViewController" bundle:nil];
    [self loadRootVC:[registerStoryboard instantiateInitialViewController]];
}

+ (void)layout {
    [self loadResgiterEntry];
}



+ (UIStoryboard *)welcomeStoryboard {
    static UIStoryboard *stoyrboard = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stoyrboard = [UIStoryboard storyboardWithName:@"WelcomeViewController" bundle:nil];
    });
    return stoyrboard;
}

+ (UIStoryboard *)homeStoryboard {
    static UIStoryboard *stoyrboard = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stoyrboard = [UIStoryboard storyboardWithName:@"TYHomeViewController" bundle:nil];
    });
    return stoyrboard;
}
+ (UIStoryboard *)registerStoryboard {
    static UIStoryboard *stoyrboard = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stoyrboard = [UIStoryboard storyboardWithName:@"RSRegisterViewController" bundle:nil];
    });
    return stoyrboard;
}

+ (UIStoryboard *)drawStoryboard {
    static UIStoryboard *stoyrboard = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stoyrboard = [UIStoryboard storyboardWithName:@"TYDrawViewController" bundle:nil];
    });
    return stoyrboard;
}

+ (UIStoryboard *)videoStoryboard {
    static UIStoryboard *stoyrboard = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stoyrboard = [UIStoryboard storyboardWithName:@"RSTrackViewController" bundle:nil];
    });
    return stoyrboard;
}

+ (UIStoryboard *)noteStoryboard {
    static UIStoryboard *stoyrboard = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stoyrboard = [UIStoryboard storyboardWithName:@"NoteViewController" bundle:nil];
    });
    return stoyrboard;
}

+ (TYDrawViewController *)drawViewController {
    return [[TYViewControllerLoader drawStoryboard] instantiateViewControllerWithIdentifier:@"TYDrawViewController"];
}

+ (TYCheckNoteViewController *)checkNoteViewController {
    return [[self noteStoryboard] instantiateViewControllerWithIdentifier:@"TYCheckNoteViewController"];
}

+ (TYAudioViewController *)audioViewController {
    return [[TYViewControllerLoader drawStoryboard] instantiateViewControllerWithIdentifier:@"TYAudioViewController"];
}

+ (TYWirteNoteViewController *)wirteNoteViewController {
    return [[TYViewControllerLoader noteStoryboard] instantiateViewControllerWithIdentifier:@"TYWirteNoteViewController"];
}

+ (TYHomeViewController *)homeViewController {
    return [[TYViewControllerLoader homeStoryboard] instantiateViewControllerWithIdentifier:@"TYHomeViewController"];
}

@end
