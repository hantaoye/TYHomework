//
//  UIImage+Water.m
//  Image水印
//
//  Created by qingyun on 14-9-21.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "UIImage+TY.h"
#import "TYDebugLog.h"
//#import "RyxDebugLogger.h"
#import <UIImage-ResizeMagick/UIImage+ResizeMagick.h>

#define borders 10

#define MAX_IMAGE_WIDTH 640.0f
#define MAX_IMAGE_HEIGHT 1136.0f
#define MAX_FILE_SIZE 100*1024

@implementation UIImage (TY)


+ (instancetype)captureWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [view.layer renderInContext:context];
    
    UIImage *lastImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return lastImage;
}

- (NSData *)compressPhoto {
    UIImage *_image = self;
    NSData *photoData = nil;
    NSUInteger loop = 0;
    @autoreleasepool {
        [self resizedImageWithMaximumSize:CGSizeMake(MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT)];
        photoData = UIImageJPEGRepresentation(_image, 0.45);
        CGFloat compression = 0.9f;
        CGFloat maxCompression = 0.1f;
        while ([photoData length] > MAX_FILE_SIZE && compression > maxCompression) {
            [TYDebugLog debugFormat:@"image compress process (%ld): currentSize -> %ld", (unsigned long)loop++, (unsigned long)[photoData length]];
            compression -= 0.1;
            photoData = UIImageJPEGRepresentation(_image, compression);
        }
        [TYDebugLog debugFormat:@"image compress process (%ld [final]): currentSize -> %ld", (unsigned long)loop++, (unsigned long)[photoData length]];
    }
    return photoData;
}

- (instancetype)compress:(CGFloat)compression {
    return [[UIImage alloc] initWithData:[self compressPhoto]];
    //    return [[UIImage alloc] initWithData:UIImageJPEGRepresentation(self, compression)];
}

+ (instancetype)captureWithFirstImage:(UIImage *)firstImage secondImage:(UIImage *)secondImage borderWidth:(CGFloat)borderWith {
    //    return [self imageByCombiningImage:firstImage withImage:secondImage];
    UIImage *resultImage = nil;
    @autoreleasepool {
        CGSize firstSize = firstImage.size;
        CGSize secondSize = secondImage.size;
        //    CGFloat width = ([UIScreen mainScreen].bounds.size.width - borderWith) / 2;
        CGFloat width = MAX(firstSize.width, secondSize.width);
        CGFloat height = MAX(firstSize.height, secondSize.height);
        UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(width + borderWith, 0, width, height)];
        imageView1.contentMode = UIViewContentModeScaleToFill;
        imageView2.contentMode = UIViewContentModeScaleToFill;
        imageView1.image = firstImage;
        imageView2.image = secondImage;
        //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2 * width + borderWith, height)];
        
        
        [view addSubview:imageView1];
        [view addSubview:imageView2];
        resultImage = [[UIImage alloc] initWithData:UIImageJPEGRepresentation([self captureWithView:view], 0.8)];
    }
    return resultImage;
}

- (UIImage *)cropRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

+ (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    @autoreleasepool {
        CGSize newImageSize = CGSizeMake(MAX(firstImage.size.width, secondImage.size.width), MAX(firstImage.size.height, secondImage.size.height));
        if (UIGraphicsBeginImageContextWithOptions != NULL) {
            UIGraphicsBeginImageContextWithOptions(newImageSize, NO, [[UIScreen mainScreen] scale]);
        } else {
            //            UIGraphicsBeginImageContext(newImageSize);
        }
        [firstImage drawAtPoint:CGPointMake(roundf((newImageSize.width-firstImage.size.width)/2),
                                            roundf((newImageSize.height-firstImage.size.height)/2))];
        [secondImage drawAtPoint:CGPointMake(roundf((newImageSize.width-secondImage.size.width)/2),
                                             roundf((newImageSize.height-secondImage.size.height)/2))];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

+ (instancetype)waterWithBackImageName:(NSString *)backImageName waterImageName:(NSString *)waterImageName
{
    UIImage *backImage = [UIImage imageNamed:backImageName];
    
    UIGraphicsBeginImageContextWithOptions(backImage.size, NO, 0.0);
    
    //    CGMutablePathRef ptah = CGPathCreateMutable();
    [backImage drawInRect:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    
    UIImage *waterImage = [UIImage imageNamed:waterImageName];
    [waterImage drawInRect:CGRectMake(backImage.size.width - waterImage.size.width - borders, backImage.size.height - waterImage.size.height - borders, waterImage.size.width, waterImage.size.height)];
    
    UIImage *lastImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return lastImage;
}

+ (instancetype)nameWithBackimageName:(NSString *)backImageName name:(NSString *)name
{
    UIImage *backImage = [UIImage imageNamed:backImageName];
    
    UIGraphicsBeginImageContextWithOptions(backImage.size, NO, 0.0);
    
    //    CGMutablePathRef ptah = CGPathCreateMutable();
    [backImage drawInRect:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    dict[NSForegroundColorAttributeName] = [UIColor redColor];
    
    CGSize nameSize = [name sizeWithAttributes:dict];
    
    [name drawAtPoint:CGPointMake(backImage.size.width - nameSize.width - borders, backImage.size.height - nameSize.height - borders) withAttributes:dict];
    
    UIImage *lastImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return lastImage;
    
}

+ (instancetype)circleImageWithImageName:(NSString *)imageName borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    UIImage *image = [UIImage imageNamed:imageName];
    return [self circleImageWithImage:image borderWidth:borderWidth borderColor:borderColor];
}

+ (instancetype)circleImageWithImage:(UIImage *)image borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    
    CGFloat newImageX = image.size.width + 2 * borderWidth;
    CGFloat newImageY = image.size.height + 2 * borderWidth;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newImageX, newImageY), NO, 0.0) ;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat bigRadius = MIN(image.size.width, image.size.height) * 0.5 + borderWidth;
    
    CGFloat centerX = bigRadius;
    CGFloat centerY = bigRadius;
    
    CGContextAddArc(context, centerX, centerY, bigRadius, 0, M_PI * 2, 1);
    [borderColor set];
    CGContextFillPath(context);
    
    CGContextAddArc(context, centerX, centerY, bigRadius - borderWidth, 0, M_PI * 2, 1);
    CGContextClip(context);
    [image drawAtPoint:CGPointMake(borderWidth, borderWidth)];
    // [image drawInRect:CGRectMake(borderWidth, borderWidth, image.size.width, image.size.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)resizedImageWithName:(NSString *)name
{
    return [self resizedImageWithName:name left:0.5 top:0.5];
}

+ (UIImage *)resizedImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top
{
    UIImage *image = [self imageNamed:name];
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * top, image.size.width * left, image.size.height * (1 - top), image.size.width * (1 - left)) resizingMode:UIImageResizingModeTile];
}

@end
