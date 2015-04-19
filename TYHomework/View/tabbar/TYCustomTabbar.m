//
//  TYCustomTabbar.m
//  TYStatus
//
//  Created by qingyun on 14/10/8.
//  Copyright (c) 2014年 cn.TY. All rights reserved.
//
//#define kTYTabbarBtn

#import "TYCustomTabbar.h"
#import "TYTabBarButton.h"
#import "UIImage+TY.h"
#import "UIImage+Resize.h"

#define TYPressedTime 0.5

@interface TYCustomTabbar ()
@property (nonatomic, weak) TYTabBarButton *selectedBtn;
@property (nonatomic, weak) UIButton *addBtn;
@property (nonatomic, strong) NSMutableArray *tabBarButtons;
//@property (nonatomic, strong) NSTimer *timer;
//@property (nonatomic, assign) NSTimeInterval timeInterval;


@end

@implementation TYCustomTabbar

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
//    self.backgroundColor = [UIColor colorWithRed:252.0 / 255.0f green:150.0 / 255.0f blue:39.0 / 255.0f alpha:1.0];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage resizedImageWithName:@"tabbar-bg"]];
    [self.addBtn addTarget:self action:@selector(didPressedAddBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.tabBarButtons = [NSMutableArray array];
}

/**
 *  中间加号
 */
- (UIButton *)addBtn
{
    if (!_addBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn];
        _addBtn = btn;
        //图片
        [btn setBackgroundImage:[UIImage imageNamed:@"tabbar_track_bg"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"tabbar_track"] forState:UIControlStateNormal];
//        [btn setImage:[UIImage imageNamed:@"tabbar_compose_icon_add_highlighted"] forState:UIControlStateHighlighted];
        //大小
        btn.bounds = CGRectMake(0, 0, btn.currentBackgroundImage.size.width, btn.currentBackgroundImage.size.height);
    }
    return _addBtn;
}

/**
 *  添加自定义的tabbarItem
 */
- (TYTabBarButton *)addCustomTabBarItem:(UITabBarItem *)item
{
    TYTabBarButton *btn = [[TYTabBarButton alloc] init];
    btn.item = item;
    [self addSubview:btn];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    [self.tabBarButtons addObject:btn];
    if (self.subviews.count == 2) {
        [self btnClick:btn];
    }
    return btn;
}

/**
 *  监听点击事件
 */
- (void)btnClick:(TYTabBarButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(customTabbar:fromBtnIndex:toBtnIndex:)]) {
        [self.delegate customTabbar:self fromBtnIndex:self.selectedBtn.tag - 1 toBtnIndex:btn.tag - 1];
    }
    self.selectedBtn.selected = NO;
    self.selectedBtn = btn;
    self.selectedBtn.selected = YES;
}

- (void)didPressedAddBtn:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(customTabbar:didClickAddBtn:)]) {
        [self.delegate customTabbar:self didClickAddBtn:_addBtn];
    }
}

- (void)selectedIndex:(NSUInteger)index {
    [self btnClick:self.tabBarButtons[index]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.addBtn.center = self.center;
    
    CGFloat btnY = 0;
    CGFloat btnH = self.bounds.size.height;
    CGFloat btnW = self.bounds.size.width / (self.subviews.count);
    for (int i = 0;i < self.tabBarButtons.count; i++) {
        TYTabBarButton *btn = self.tabBarButtons[i];
        CGFloat btnX = i * btnW;
        if (i > 1) {
            btnX += btnW;
        }
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        
        btn.tag = i + 1;
    }
}

/**
 *  监听加号点击事件
 */

//- (void)startTimer {
//    if (_timer) return;
//    _timeInterval = 0;
//    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(didStartTimer:) userInfo:nil repeats:YES];
//}
//
//- (void)stopTimer {
//    _timeInterval = 0;
//    if (!_timer) return;
//    [_timer invalidate];
//    _timer = nil;
//}
//
//- (void)didStartTimer:(NSTimer *)timer {
//    _timeInterval += timer.timeInterval;
//}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint beginPoint = [touch locationInView:_addBtn.superview];
//    if (CGRectContainsPoint(_addBtn.frame, beginPoint)) {
//        [self startTimer];
//    }
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint endPoint = [touch locationInView:_addBtn.superview];
//    if (CGRectContainsPoint(_addBtn.frame, endPoint)) {
//        if (_timeInterval >= TYPressedTime) {
//            if ([self.delegate respondsToSelector:@selector(customTabbar:longPressedAddBtn:)]) {
//                [self.delegate customTabbar:self longPressedAddBtn:_addBtn];
//            }
//        } else {
//            if ([self.delegate respondsToSelector:@selector(customTabbar:didClickAddBtn:)]) {
//                [self.delegate customTabbar:self didClickAddBtn:_addBtn];
//            }
//        }
//    }
//    [self stopTimer];
//}



@end
