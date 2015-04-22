//
//  DeleteButton.m
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-14.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "DeleteButton.h"

#define DELETE_BTN_NORMAL_IAMGE @"video-cancel-bg"
#define DELETE_BTN_DELETE_IAMGE @"video-cancel-bg-highLight"
//#define DELETE_BTN_DISABLE_IMAGE @"record_delete_disable@2x.png"

@interface DeleteButton ()


@end

@implementation DeleteButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initalize];
    }
    return self;
}

- (void)initalize
{
    [self setImage:[UIImage imageNamed:@"video-cancel"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"video-cancel-heightLight"] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageNamed:@"video-cancel-bg"] forState:UIControlStateNormal];
}

+ (DeleteButton *)getInstance
{
    DeleteButton *deleteButton = [[DeleteButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    return deleteButton;
}

- (void)setButtonStyle:(DeleteButtonStyle)style
{
    self.style = style;
    switch (style) {
        case DeleteButtonStyleNormal:
        {
            self.enabled = YES;
            [self setBackgroundImage:[UIImage imageNamed:DELETE_BTN_NORMAL_IAMGE] forState:UIControlStateNormal];
        }
            break;
        case DeleteButtonStyleDisable:
        {
            self.enabled = NO;
        }
            break;
        case DeleteButtonStyleDelete:
        {
            self.enabled = YES;
            [self setBackgroundImage:[UIImage imageNamed:DELETE_BTN_DELETE_IAMGE] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

@end
