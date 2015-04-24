//
//  RSLaunchScreenViewController.h
//  FITogether
//
//  Created by closure on 3/15/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InitRootTabViewControllerHelper : NSObject
+ (NSArray *)viewControllers;
@end

@interface RSLaunchScreenViewController : UIViewController
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *launchImage;
@end
