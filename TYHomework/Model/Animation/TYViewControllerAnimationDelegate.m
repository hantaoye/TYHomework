//
//  TYViewControllerAnimationDelegate.m
//  TYHomework
//
//  Created by taoYe on 15/4/6.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYViewControllerAnimationDelegate.h"
#import "AppDelegate.h"
#import <VCTransitionsLibrary/CEBaseInteractionController.h>
#import <VCTransitionsLibrary/CEReversibleAnimationController.h>

@implementation TYViewControllerAnimationDelegate
#pragma mark - UIViewControllerTransitioningDelegate


+ (instancetype)shareAnimationDelegate {
    static TYViewControllerAnimationDelegate *delegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegate = [[TYViewControllerAnimationDelegate alloc] init];
    });
    return delegate;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    if (AppDelegateAccessor.settingsInteractionController) {
        [AppDelegateAccessor.settingsInteractionController wireToViewController:presented forOperation:CEInteractionOperationDismiss];
    }
    
    AppDelegateAccessor.settingsAnimationController.reverse = NO;
    return AppDelegateAccessor.settingsAnimationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    AppDelegateAccessor.settingsAnimationController.reverse = YES;
    return AppDelegateAccessor.settingsAnimationController;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return AppDelegateAccessor.settingsInteractionController && AppDelegateAccessor.settingsInteractionController.interactionInProgress ? AppDelegateAccessor.settingsInteractionController : nil;
}

@end
