//
//  RSBlurImageHelper.h
//  FITogether
//
//  Created by closure on 2/11/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "TYObject.h"

@interface RSBlurImageStore : TYObject
@property (nonatomic, strong) UIImage *blurImage;
@property (nonatomic, assign) CGFloat brightness;
- (instancetype)initWithBlurImage:(UIImage *)image;
@end

@class RSBaseAccount, RSCoach, SDImageCache;

@interface TYImageHelper : TYObject
+ (instancetype)helper;
- (SDImageCache *)blurImageCache;
+ (NSString *)setDrawImage:(UIImage *)image;

+ (NSString *)setPhotoImage:(UIImage *)image;

+ (UIImage *)getImageForPath:(NSString *)path;

@end
