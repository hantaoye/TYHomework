//
//  RSTrackEditPhotoViewController.h
//  FITogether
//
//  Created by closure on 12/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsLibrary;

@interface RSTrackEditPhotoViewController : UIViewController
@property (strong, nonatomic) ALAssetsLibrary *library;
@property (nonatomic, strong) NSArray *assets;
@property (nonatomic, assign) BOOL deleteAfterDone;
@end
