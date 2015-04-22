//
//  RSVideoPostViewController.h
//  FITogether
//
//  Created by closure on 3/5/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class AVURLAsset;

@interface RSVideoPostViewController : UIViewController
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSMutableArray *tags;

@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate2D;
@property (nonatomic, strong) NSString *desc;
- (IBAction)shareVideo:(id)sender;
@end
