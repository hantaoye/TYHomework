//
//  TYTabbarView.m
//  TYHomework
//
//  Created by taoYe on 15/4/19.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYTabbarView.h"
#import "TYTabbarButton.h"
#import "UIImage+TY.h"

@interface TYTabbarView ()
@property (nonatomic, weak) TYTabbarButton *selectedBtn;

@property (nonatomic, strong) NSMutableArray *tabBarButtons;

@end

@implementation TYTabbarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupData];
    }
    return self;
}

- (void)setupData {
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage resizedImageWithName:@"tabbar-bg"]];
    self.tabBarButtons = [NSMutableArray array];
}

/**
 *  监听点击事件
 */
- (void)btnClick:(TYTabbarButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(customTabbar:fromBtnIndex:toBtnIndex:)]) {
        [self.delegate tabbarView:self fromBtnIndex:self.selectedBtn.tag - 1 toBtnIndex:btn.tag - 1];
    }
    self.selectedBtn.selected = NO;
    self.selectedBtn = btn;
    self.selectedBtn.selected = YES;
}

- (void)selectedIndex:(NSUInteger)index {
    [self btnClick:self.tabBarButtons[index]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat btnY = 0;
    CGFloat btnH = self.bounds.size.height;
    CGFloat btnW = self.bounds.size.width / (self.subviews.count);
    for (int i = 0;i < self.tabBarButtons.count; i++) {
        TYTabbarButton *btn = self.tabBarButtons[i];
        CGFloat btnX = i * btnW;
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        
        btn.tag = i + 1;
    }
}

/**
 *  添加自定义的tabbarItem
 */
- (TYTabbarButton *)addCustomTabBarItem:(UITabBarItem *)item
{
    TYTabbarButton *btn = [[TYTabbarButton alloc] init];
    [self addSubview:btn];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    [self.tabBarButtons addObject:btn];
    if (self.subviews.count == 2) {
        [self btnClick:btn];
    }
    return btn;
}


@end
