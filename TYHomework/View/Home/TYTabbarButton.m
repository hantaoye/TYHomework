//
//  TYTabbarButton.m
//  TYHomework
//
//  Created by taoYe on 15/4/19.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYTabbarButton.h"
#import "TYBadgeButton.h"

@interface TYTabbarButton ()
@property (nonatomic, weak) TYBadgeButton *badgeButton;

@end

@implementation TYTabbarButton


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setTitleColor:[UIColor colorWithRed:246.0/255.0 green:167.0/255.0 blue:80.0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor colorWithRed:140.0/255.0 green:139.0/255.0 blue:143.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        //        [self setBackgroundImage:[UIImage imageNamed:@"tabbar_slider"] forState:UIControlStateSelected];
    }
    return self;
}

/**
 *  边缘的数字
 */
- (TYBadgeButton *)badgeButton
{
    if (!_badgeButton) {
        TYBadgeButton *bader = [[TYBadgeButton alloc] init];
        [self addSubview:bader];
        _badgeButton = bader;
        
        CGFloat badgeX = 0;
        CGFloat badgeY = 3;
        _badgeButton.frame = CGRectMake(badgeX, badgeY, 0, 0);
        
        _badgeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _badgeButton;
}

- (void)setTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage badgeValue:(NSString *)badgeValue {
    [self setTitle:title forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:selectedImage forState:UIControlStateSelected];
    self.badgeButton.badgeValue = badgeValue;
}

/**
 *  重新定义image的位置
 */
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = contentRect.size.width;
    CGFloat imageH = contentRect.size.height * TYTabbarScale;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0;
    CGFloat titleY = contentRect.size.height * TYTabbarScale;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height * (1 - TYTabbarScale);
    return CGRectMake(titleX, titleY, titleW, titleH);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.badgeButton.frame;
    frame.origin.x = self.bounds.size.width / 2 + 5;
    self.badgeButton.frame = frame;
}

@end
