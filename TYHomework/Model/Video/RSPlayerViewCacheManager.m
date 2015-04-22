//
//  RSPlayerViewCacheManager.m
//  FITogether
//
//  Created by closure on 3/25/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "RSPlayerViewCacheManager.h"

@interface RSPlayerViewCacheManager ()
@property (strong, nonatomic) NSMapTable *mt;
@end

@implementation RSPlayerViewCacheManager
+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static RSPlayerViewCacheManager *__manager;
    dispatch_once(&onceToken, ^{
        __manager = [[RSPlayerViewCacheManager alloc] init];
    });
    return __manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _mt = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

//- (RSPlayerView *)objectForKey:(RSVideo *)aKey {
//    RSPlayerView *view = [_mt objectForKey:[aKey getInKey]];
//    return view;
//}
//
//- (void)setObject:(RSPlayerView *)obj forKey:(RSVideo *)aKey {
//    if (!obj) {
//        [_mt removeObjectForKey:[aKey getInKey]];
//        return;
//    }
//    [_mt setObject:obj forKey:[aKey getInKey]];
//}
@end
