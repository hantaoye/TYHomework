//
//  TYWirteHelp.h
//  TYHomework
//
//  Created by taoYe on 15/4/23.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYObject.h"
#import <AVFoundation/AVFoundation.h>
//#import <AssetsLibrary/AssetsLibrary.h>

@interface TYWriteHelp : TYObject

@property (assign, nonatomic, getter=isStartWrite) BOOL startWrite;

@property (strong, nonatomic) AVURLAsset *asset;

@property (strong, nonatomic) UIImage *videoImage;

@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) UIImage *drawImage;

+ (instancetype)shareWriteHelp;

@end
