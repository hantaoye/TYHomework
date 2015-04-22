//
//  RSDelaySegue.m
//  FITogether
//
//  Created by closure on 3/24/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "RSDelaySegue.h"

@interface RSDelaySegue ()
@property (strong, nonatomic, readonly) UIViewController *viewController;
@property (strong, nonatomic, readonly) UIViewController *targetViewController;
@end

@implementation RSDelaySegue
+ (instancetype)segueWithViewController:(UIViewController *)vc storyboard:(UIStoryboard *)sb {
    return [[self alloc] initWithViewController:vc storyboard:sb identifier:nil];
}

+ (instancetype)segueWithViewController:(UIViewController *)vc storyboard:(UIStoryboard *)sb identifier:(NSString *)identifier {
    return [[self alloc] initWithViewController:vc storyboard:sb identifier:identifier];
}

- (instancetype)initWithViewController:(UIViewController *)vc storyboard:(UIStoryboard *)sb {
    return [self initWithViewController:vc storyboard:sb identifier:nil];
}

- (instancetype)initWithViewController:(UIViewController *)vc storyboard:(UIStoryboard *)sb identifier:(NSString *)identifier {
    if (self = [super init]) {
        _viewController = vc;
        _storyboard = sb;
        _identifier = identifier;
    }
    return self;
}

+ (instancetype)segueWithViewController:(UIViewController *)vc storyboard:(UIStoryboard *)sb toViewController:(UIViewController *)toVC {
    return [[self alloc] initWithViewController:vc storyboard:sb toViewController:toVC];
}

- (instancetype)initWithViewController:(UIViewController *)vc storyboard:(UIStoryboard *)sb toViewController:(UIViewController *)toVC {
    if (self = [super init]) {
        _viewController = vc;
        _storyboard = sb;
        _targetViewController = toVC;
    }
    return self;
}

- (void)performWithCompletion:(void (^)(void))completion {
    if (!_storyboard) {
        return;
    }
    NSLog(@"delay segue performed, %@", NSStringFromSelector(_cmd));
//    CFTimeInterval duration = [UIView animationDuration];
//    [UIView setAnimationDuration:0.25];
    UIViewController *from = _viewController;
    UIViewController *to = _targetViewController;
    if (!to) {
        if (_identifier) {
            to = [_storyboard instantiateViewControllerWithIdentifier:_identifier];
        } else {
            to = [_storyboard instantiateInitialViewController];
        }
    }
    NSLog(@"delay segue will do impl");
    assert(to && "delay segue perfrom failed, toVC is not found");
    [from presentViewController:to animated:YES completion:completion];
}

@end