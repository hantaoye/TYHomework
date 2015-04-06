//
//  UIImage+Water.h
//  Image水印
//
//  Created by qingyun on 14-9-21.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TY)

/**
 *  拉伸图片
 */
+ (UIImage *)resizedImageWithName:(NSString *)name;

+ (UIImage *)resizedImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top;

//水印
+ (instancetype)waterWithBackImageName:(NSString *)backImageName waterImageName:(NSString *)waterImageName;

// 添加名字在图片上
+ (instancetype)nameWithBackimageName:(NSString *)backImageName name:(NSString *)name;

//吧图片裁剪成圆形
+ (instancetype)circleImageWithImageName:(NSString *)imageName borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

+ (instancetype)circleImageWithImage:(UIImage *)image borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

//吧View视图截图
+ (instancetype)captureWithView:(UIView *)view;
+ (instancetype)captureWithLayer:(CALayer *)layer;

//两张图片合成一张合成
+ (instancetype)captureWithFirstImage:(UIImage *)firstImage secondImage:(UIImage *)secondImage borderWidth:(CGFloat)borderWith;

- (UIImage *)cropRect:(CGRect)rect;

+ (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage;

- (NSData *)compressPhoto;

- (instancetype)compress:(CGFloat)compression;

+ (void)latestImageFromAssetsLibrary:(void (^)(UIImage *image, NSError *error))hanlder;
@end
