//
//  EditVideoViewController.h
//  RSVideoDemo
//
//  Created by closure on 3/4/15.
//  Copyright (c) 2015 RenYuXian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h> 

@interface RSVideoEditViewController : UIViewController
@property (nonatomic, strong) NSString *outputPath;
@property (nonatomic, strong) AVURLAsset *asset;
@property (strong, nonatomic) ALAsset *alasset;
- (void)exportAction:(void (^)(BOOL finished, NSError *error))block;
@end
