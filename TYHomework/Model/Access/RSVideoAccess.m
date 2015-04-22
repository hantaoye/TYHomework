//
//  RSVideoAccess.m
//  FITogether
//
//  Created by closure on 3/13/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "RSVideoAccess.h"
#import "UIImage+TY.h"

@implementation RSVideoAccess
+ (NSString *)webService {
    return @"photo/";
}

+ (void)create:(RSVideo *)video action:(RSVideoAction)action {
    assert([video videoAsset] && "video asset is nil");
    NSMutableDictionary *kv = [[NSMutableDictionary alloc] init];
//    dispatch_block_t code = ^{
//        if ([video videoData]) {
//            kv[@"video"] = [video videoData];
//        }
//        
//        if ([video image] == nil) {
//            [RSVideo generateImage:[video videoAsset] action:^(UIImage *image, NSError *error) {
//                if (error != nil) {
//                    return action(nil, error);
//                }
//                [video setImageData:[image compressPhoto]];
//                [RSPhotoAccess create:video external:kv action:^(RSPhoto *photo, NSError *error) {
//                    if (error != nil) {
//                        return action(nil, error);
//                    }
//                    return action(video, nil);
//                }];
//            }];
//        } else {
//            if ([video imageData] == nil) {
//                [video setImageData:[[video image] compressPhoto]];
//            }
//            [RSPhotoAccess create:video external:kv action:^(RSPhoto *photo, NSError *error) {
//                if (error != nil) {
//                    return action(nil, error);
//                }
//                return action(video, nil);
//            }];
//        }
//    };
//    if (![video videoData]) {
//        [video fillVideoData:^(RSVideo *video, NSError *error) {
//            if (error != nil) {
//                return action(nil, error);
//            }
//            code();
//        }];
//    } else {
//        code();
//    }
}
@end
