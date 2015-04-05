//
//  TYAnimationController.m
//  Pods
//
//  Created by taoYe on 15/4/5.
//
//

#import "TYAnimationController.h"

@implementation TYAnimationController

- (void)animateTransition:(id)transitionContext fromVC:(id)fromVC toVC:(id)toVC fromView:(id)fromView toView:(id)toView {
    
    [UIView transitionFromView:fromView toView:toView duration:1.0 options:!self.reverse ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
