//
//  RSDelaySegue.h
//  FITogether
//
//  Created by closure on 3/24/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "TYObject.h"
#import <UIKit/UIKit.h>

@interface RSDelaySegue : TYObject
@property (strong, nonatomic, readonly) UIStoryboard *storyboard;
@property (strong, nonatomic, readonly) NSString *identifier;
@property (strong, nonatomic) void (^completion)(void);
@property (strong, nonatomic) id delayObjectPlaceholder;

+ (instancetype)segueWithViewController:(UIViewController *)vc storyboard:(UIStoryboard *)sb;
+ (instancetype)segueWithViewController:(UIViewController *)vc storyboard:(UIStoryboard *)sb identifier:(NSString *)identifier;
- (instancetype)initWithViewController:(UIViewController *)vc storyboard:(UIStoryboard *)sb;
- (instancetype)initWithViewController:(UIViewController *)vc storyboard:(UIStoryboard *)sb identifier:(NSString *)identifier;

+ (instancetype)segueWithViewController:(UIViewController *)vc storyboard:(UIStoryboard *)sb toViewController:(UIViewController *)toVC;
- (instancetype)initWithViewController:(UIViewController *)vc storyboard:(UIStoryboard *)sb toViewController:(UIViewController *)toVC;

- (void)performWithCompletion:(void (^)(void))completion;
@end
