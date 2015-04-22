//
//  RSVideo.h
//  FITogether
//
//  Created by closure on 3/13/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "TYObject.h"

@class AVURLAsset;
@class RSVideo;

typedef void(^RSVideoAction)(RSVideo *video, NSError *error);

@interface RSVideo : TYObject
@property (strong, nonatomic) AVURLAsset *videoAsset;
@property (strong, nonatomic) NSData *videoData;
@property (strong, nonatomic) NSString *videoURL;

+ (void)generateImage:(AVURLAsset *)asset action:(void (^)(UIImage *image, NSError *error))action;

//- (instancetype)initWithID:(RSIDType)ID filterID:(RSIDType)filterID url:(NSString *)url latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude locationDescription:(NSString *)locationDescription author:(RSIDType)author photoDescription:(NSString *)photoDescription tags:(NSArray *)tags cards:(NSArray *)cards atUsers:(NSArray *)atUsers cardCount:(NSInteger)cardCount videoAsset:(AVURLAsset *)videoAsset;
//
- (void)fillVideoData:(RSVideoAction)action;
@end
