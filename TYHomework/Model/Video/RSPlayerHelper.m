//
//  RSPlayerHelper.m
//  FITogether
//
//  Created by taoYe on 15/3/23.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import "RSPlayerHelper.h"

@interface RSPlayerHelper ()
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) CGFloat currentTime;

@end

@implementation RSPlayerHelper

+ (instancetype)currentPlayerHelper {
    static RSPlayerHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[RSPlayerHelper alloc] init];
    });
    return helper;
}

- (instancetype)init {
    if (self = [super init]) {

    }
    return self;
}

- (void)setCurrentTime:(CGFloat)currentTime indexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
    _currentTime = currentTime;
}

- (CGFloat)getCurrentTimeWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _indexPath.row && indexPath.section == _indexPath.section) {
        return _currentTime;
    }
    return 0.0;
}

@end
