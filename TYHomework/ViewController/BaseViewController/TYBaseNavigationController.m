//
//  TYBaseNavigationController.m
//  TYHomework
//
//  Created by taoYe on 15/4/5.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYBaseNavigationController.h"
#import "AppDelegate.h"
#import <VCTransitionsLibrary/CEBaseInteractionController.h>
#import <VCTransitionsLibrary/CEReversibleAnimationController.h>

@interface TYBaseNavigationController () <UINavigationControllerDelegate, UIViewControllerTransitioningDelegate>

@end

@implementation TYBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
//    UIColor *tintColor = [UIColor colorWithRed:42.0 / 255 green:184.0 / 255 blue:94.0 / 255 alpha:1.0];
//    [[self navigationBar] setBarTintColor:tintColor];
    self.delegate = self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([[self viewControllers] count]) {
        [viewController setHidesBottomBarWhenPushed:YES];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    viewControllerToPresent.transitioningDelegate = self;
    return [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {

    // when a push occurs, wire the interaction controller to the to- view controller
    if (AppDelegateAccessor.navigationControllerInteractionController) {
        [AppDelegateAccessor.navigationControllerInteractionController wireToViewController:toVC forOperation:CEInteractionOperationPop];
    }
    
    if (AppDelegateAccessor.navigationControllerAnimationController) {
        AppDelegateAccessor.navigationControllerAnimationController.reverse = operation == UINavigationControllerOperationPop;
    }
    return AppDelegateAccessor.navigationControllerAnimationController;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    // if we have an interaction controller - and it is currently in progress, return it
    return AppDelegateAccessor.navigationControllerInteractionController && AppDelegateAccessor.navigationControllerInteractionController.interactionInProgress ? AppDelegateAccessor.navigationControllerInteractionController : nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_delaySegue) {
        NSLog(@"root tabbar vc %@", NSStringFromSelector(_cmd));
        [_delaySegue performWithCompletion:^{
            if ([_delaySegue completion]) {
                [_delaySegue completion]();
            }
            _delaySegue = nil;
        }];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

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
