//
//  RSVideo.m
//  FITogether
//
//  Created by closure on 3/13/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "RSVideo.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

static NSString *__videoURLKey = @"video_url";

@interface RSVideo ()
//- (instancetype)initWithPhoto:(RSPhoto *)photo;
@end

//@interface RSPhoto ()
//+ (instancetype)_parseImpl:(id)data;
//@end

@implementation RSVideo
//- (instancetype)initWithPhoto:(RSPhoto *)photo {
//    if (self = [super initWithID:[photo ID] filterID:[photo filterID] url:[photo url] latitude:[photo latitude] longitude:[photo longitude] locationDescription:[photo locationDescription] author:[[photo author] ID] photoDescription:[photo desc] tags:[photo tags] cards:[photo cards] atUsers:[photo atUsers] cardCount:[photo cardCount]]) {
//        [self setAuthor:[photo author]];
//        [self setCommentCount:[photo commentCount]];
//        [self setComments:[photo comments]];
//        [self setLikeCount:[photo likeCount]];
//        [self setLikeUsers:[photo likeUsers]];
//        [self setTime:[photo time]];
//        [self setLiked:[photo isLiked]];
//    }
//    return self;
//}

//+ (instancetype)parse:(id)data {
////    RSPhoto *photo = [RSPhoto _parseImpl:data];
//    if (photo) {
//        RSVideo *video = [[RSVideo alloc] initWithPhoto:photo];
//        if (data[__videoURLKey]) {
//            [video setVideoURL:data[__videoURLKey]];
//        }
//        return video;
//    }
//    return nil;
//}

//- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [super encodeWithCoder:aCoder];
//    [aCoder encodeObject:_videoURL forKey:__videoURLKey];
//}

//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    if (self = [super initWithCoder:aDecoder]) {
//        _videoURL = [aDecoder decodeObjectForKey:__videoURLKey];
//    }
//    return self;
//}

//- (instancetype)initWithID:(RSIDType)ID filterID:(RSIDType)filterID url:(NSString *)url latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude locationDescription:(NSString *)locationDescription author:(RSIDType)author photoDescription:(NSString *)photoDescription tags:(NSArray *)tags cards:(NSArray *)cards atUsers:(NSArray *)atUsers cardCount:(NSInteger)cardCount videoAsset:(AVURLAsset *)videoAsset {
//    if (self = [super initWithID:ID filterID:filterID url:url latitude:latitude longitude:longitude locationDescription:locationDescription author:author photoDescription:photoDescription tags:tags cards:cards atUsers:atUsers cardCount:cardCount]) {
//        _videoAsset = videoAsset;
//    }
//    return self;
//}

+ (void)generateImage:(AVURLAsset *)asset action:(void (^)(UIImage *, NSError *))action {
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    [generator setAppliesPreferredTrackTransform:YES];
    CMTime time = CMTimeMakeWithSeconds(0, 30);
    [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]] completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        if (result != AVAssetImageGeneratorSucceeded) {
            [TYDebugLog errorFormat:@"couldn't generate thumbnail, error %@", error];
            action(nil, error);
            return;
        }
        return action([UIImage imageWithCGImage:image], error);
    }];
}

- (void)fillVideoData:(RSVideoAction)action {
    if (_videoData) {
        return action(self,  nil);
    }
    if (_videoAsset) {
        _videoData = [NSData dataWithContentsOfURL:[_videoAsset URL]];
    }
    if (_videoData) {
        return action(self, nil);
    }
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        int64_t size = [rep size];
        UInt8 *buf = (UInt8 *)malloc(sizeof(UInt8) * size);
        NSError *error = nil;
        if (buf) {
            [rep getBytes:buf fromOffset:0 length:size error:&error];
            if (error != nil) {
                free(buf);
                buf = nil;
                return action(nil, error);
            }
            _videoData = [[NSData alloc] initWithBytesNoCopy:buf length:size freeWhenDone:YES];
            return action(self, nil);
        }
        return action(nil, nil);
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        return action(nil, error);
    };
    [lib assetForURL:[_videoAsset URL] resultBlock:resultBlock failureBlock:failureBlock];
}
@end
