//
//  TYTabbarView.h
//  TYHomework
//
//  Created by taoYe on 15/4/19.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYTabbarButton, TYTabbarView;

@protocol TYTabbarViewDelegate <NSObject>
@optional
- (void)tabbarView:(TYTabbarView *)tabbar fromBtnIndex:(NSUInteger)fromIndex toBtnIndex:(NSUInteger)toIndex;

@end
@interface TYTabbarView : UIView

@property (nonatomic, weak) id<TYTabbarViewDelegate> delegate;

- (void)addTabbarButtonWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage badgeVaule:(NSString *)badgeValue;

- (void)selectedIndex:(NSUInteger)index;

@end
