//
//  RSBlurImageHelper.m
//  FITogether
//
//  Created by closure on 2/11/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "TYImageHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+TY.h"

@implementation RSBlurImageStore

- (instancetype)initWithBlurImage:(UIImage *)image {
    if (self = [super init]) {
        _blurImage = image;
    }
    return self;
}

@end

static NSString *TYPhotoImageKey = @"com.TY.PhotoImage";
static NSString *TYDrawImageKey = @"com.TY.DrawImage";

@interface TYImageHelper ()
@property (nonatomic, strong) SDImageCache *blurImageCache;
+ (instancetype)helper;
- (instancetype)init;
@end

@implementation TYImageHelper
+ (instancetype)helper {
    static dispatch_once_t onceToken;
    static TYImageHelper *_helper = nil;
    dispatch_once(&onceToken, ^{
        _helper = [[self alloc] init];
    });
    return _helper;
}

- (instancetype)init {
    if (self = [super init]) {
        _blurImageCache = [[SDImageCache alloc] initWithNamespace:@"blurImage"];
        [_blurImageCache setMaxCacheSize: 120 * 1024 * 1024];
        [_blurImageCache setMaxMemoryCost:30 * 1024 * 1024];
    }
    return self;
}

+ (NSString *)_keyPathForDate:(BOOL)drawImage {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *path = drawImage ? TYDrawImageKey : TYPhotoImageKey;
    return [NSString stringWithFormat:@"%@%@", path, nowTimeStr];
}

+ (NSString *)setPhotoImage:(UIImage *)image {
    NSString *path = [self _keyPathForDate:NO];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if ([imageData length] > 200000) {
        NSLog(@"imageData original size -> %@", @([imageData length]));
        imageData = [image compressPhoto];
    }
    
    if (imageData == nil) {
        imageData = UIImageJPEGRepresentation(image, 1.0);
    }
    
    [[[self helper] blurImageCache] storeImage:image recalculateFromImage:YES imageData:imageData forKey:path toDisk:YES];
    return path;
}

+ (NSString *)setDrawImage:(UIImage *)image {
    NSString *path = [self _keyPathForDate:YES];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if ([imageData length] > 200000) {
        NSLog(@"imageData original size -> %@", @([imageData length]));
        imageData = [image compressPhoto];
    }
    
    if (imageData == nil) {
        imageData = UIImageJPEGRepresentation(image, 1.0);
    }
    
    [[[self helper] blurImageCache] storeImage:image recalculateFromImage:YES imageData:imageData forKey:path toDisk:YES];
    return path;
}


+ (UIImage *)getImageForPath:(NSString *)path {
    if (path) {
        UIImage *image = [[[self helper] blurImageCache] imageFromDiskCacheForKey:path];
        if (image == nil) {
            NSLog(@"没有图片");
        }
        return image;
    }
    return nil;
}

@end
