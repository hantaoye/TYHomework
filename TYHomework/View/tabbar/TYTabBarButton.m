//
//  TYTabBarButton.m
//  TYStatus
//
//  Created by qingyun on 14/10/8.
//  Copyright (c) 2014年 cn.TY. All rights reserved.
//

#define kTYBtnImageScale 0.7
#define kTYNornalColor (iOS7 ? [UIColor blackColor] : [UIColor whiteColor])
#define kTYSelectedColor (iOS7 ? RGBColor(234, 103, 7, 1) : RGBColor(248, 139, 0, 1))

#import "TYTabBarButton.h"
#import "TYBadgeButton.h"

@interface TYTabBarButton ()

@property (nonatomic, weak) TYBadgeButton *badgeButton;

@end

@implementation TYTabBarButton

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

- (void)setHighlighted:(BOOL)highlighted
{}

/**
 *  设置btn的属性
 */
- (void)setItem:(UITabBarItem *)item
{
    _item = item;
        //添加kvo
    [item addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"selectedImage" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"badgeValue" options:NSKeyValueObservingOptionNew context:nil];
    
    [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
}

/**
 *  删除kvo添加的观察者。
 */
- (void)dealloc
{
    [self.item removeObserver:self forKeyPath:@"title"];
    [self.item removeObserver:self forKeyPath:@"image"];
    [self.item removeObserver:self forKeyPath:@"selectedImage"];
    [self.item removeObserver:self forKeyPath:@"badgeValue"];
}

/**
 *  监听对象改变， KVO的方法
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    [self setItem:self.item];
    [self setTitle:self.item.title forState:UIControlStateNormal];
    [self setImage:self.item.image forState:UIControlStateNormal];
    [self setImage:self.item.selectedImage forState:UIControlStateSelected];
    self.badgeButton.badgeValue = self.item.badgeValue;
}

/**
 *  重新定义image的位置
 */
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = contentRect.size.width;
    CGFloat imageH = contentRect.size.height * kTYBtnImageScale;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0;
    CGFloat titleY = contentRect.size.height * kTYBtnImageScale;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height * (1 - kTYBtnImageScale);
    return CGRectMake(titleX, titleY, titleW, titleH);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.badgeButton.frame;
    frame.origin.x = self.bounds.size.width / 2 + 5;
    self.badgeButton.frame = frame;
}
@end
