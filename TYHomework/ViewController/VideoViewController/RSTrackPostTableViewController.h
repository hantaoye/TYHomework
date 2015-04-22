//
//  RSTrackPostTableViewController.h
//  FITogether
//
//  Created by closure on 12/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RSTrackPostTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSArray *selectedTags;    // NSString -> RSCardTag

@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate2D;
@property (weak, nonatomic) IBOutlet UISwitch *shareToWeiboSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) BOOL deleteAfterDone;
@end
