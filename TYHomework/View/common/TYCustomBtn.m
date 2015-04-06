//
//  TYAddToolBar.m
//  TYStatus
//
//  Created by qingyun on 14/10/15.
//  Copyright (c) 2014年 cn.TY. All rights reserved.
//


#import "TYCustomBtn.h"


@interface TYCustomBtn ()

@end

@implementation TYCustomBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

//- (void)setHighlighted:(BOOL)highlighted
//{}

/**
 *  重新定义image的位置
 */
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = contentRect.size.width;
//    CGFloat imageH = contentRect.size.height - 2 * TYCustomBtnImageBorder;
    CGFloat imageH = contentRect.size.height * TYCustomBtnImageScale;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0;
    CGFloat titleY = contentRect.size.height * TYCustomBtnImageScale;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height * (1.0 -TYCustomBtnImageScale);
    return CGRectMake(titleX, titleY, titleW, titleH);
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//    [UIView animateWithDuration:0.3f animations:^{
//        self.transform = CGAffineTransformScale(self.transform, 1.2, 1.2);
//    }];
//
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesEnded:touches withEvent:event];
//    [UIView animateWithDuration:0.3f animations:^{
//        self.transform = CGAffineTransformIdentity;
//    }];
//}

@end
