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

@interface TYBaseNavigationController () <UINavigationControllerDelegate>

@end

@implementation TYBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
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


@end
