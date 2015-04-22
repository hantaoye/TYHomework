//
//  RSPlayerViewCacheManager.h
//  FITogether
//
//  Created by closure on 3/25/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "RSPlayerView.h"
#import "RSVideo.h"
#import "TYObject.h"
@interface RSPlayerViewCacheManager : TYObject
+ (instancetype)defaultManager;
- (RSPlayerView *)objectForKey:(RSVideo *)aKey;
- (void)setObject:(RSPlayerView *)obj forKey:(RSVideo *)aKey;
@end
