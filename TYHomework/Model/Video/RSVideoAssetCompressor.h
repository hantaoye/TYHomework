//
//  RSVideoAssetCompressor.h
//  FITogether
//
//  Created by closure on 3/9/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSInteger, LBVideoOrientation) {
    LBVideoOrientationUp,               //Device starts recording in Portrait
    LBVideoOrientationDown,             //Device starts recording in Portrait upside down
    LBVideoOrientationLeft,             //Device Landscape Left  (home button on the left side)
    LBVideoOrientationRight,            //Device Landscape Right (home button on the Right side)
    LBVideoOrientationNotFound = 99     //An Error occurred or AVAsset doesn't contains video track
} ;

@interface AVAsset (VideoOrientation)

/**
 Returns a LBVideoOrientation that is the orientation
 of the iPhone / iPad whent starst recording
 
 @return A LBVideoOrientation that is the orientation of the video
 */
@property (nonatomic, readonly) LBVideoOrientation videoOrientation;

@end

@interface RSVideoAssetCompressor : NSObject
+ (void)exportALAsset:(ALAsset *)asset inLibrary:(ALAssetsLibrary *)library action:(void (^)(AVURLAsset * avAsset, NSError *error))action;
+ (void)compressVideoAsset:(ALAsset *)asset inLibrary:(ALAssetsLibrary *)library action:(void (^)(AVURLAsset *avAsset, NSError *error))action;
+ (void)compressVideoAsset:(AVURLAsset *)asset outputPath:(NSString *)outputPath action:(void (^)(AVURLAsset *avAsset, NSError *error))action;
+ (void)editAVAsset:(AVURLAsset *)asset outputPath:(NSString *)outputPath timeRange:(CMTimeRange)timeRange croppedRect:(CGRect)rect action:(void (^)(AVURLAsset * avAsset, NSError *error))action;
@end
