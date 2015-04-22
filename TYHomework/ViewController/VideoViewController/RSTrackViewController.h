//
//  RSTrackViewController.h
//  FITogether
//
//  Created by closure on 12/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * RSTrackViewControllerDidPostPhotoNotification;
FOUNDATION_EXPORT NSString * RSTrackViewControllerDidCancelPostNotification;

@interface RSTrackViewController : UIViewController

@property (strong, nonatomic) NSArray *selectedTags;

@end
