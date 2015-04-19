//
//  TYCustomTabbar.h
//  TYStatus
//
//  Created by qingyun on 14/10/8.
//  Copyright (c) 2014年 cn.TY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYCustomTabbar, TYTabBarButton;
@protocol TYCustomTabbarDelegate <NSObject>
@optional
- (void)customTabbar:(TYCustomTabbar *)tabbar fromBtnIndex:(NSUInteger)fromIndex toBtnIndex:(NSUInteger)toIndex;
- (void)customTabbar:(TYCustomTabbar *)tabbar didClickAddBtn:(UIButton *)addBtn;

- (void)customTabbar:(TYCustomTabbar *)tabbar longPressedAddBtn:(UIButton *)addBtn;

@end

@interface TYCustomTabbar : UIView

@property (nonatomic, weak) id<TYCustomTabbarDelegate> delegate;
- (TYTabBarButton *)addCustomTabBarItem:(UITabBarItem *)item;
- (void)selectedIndex:(NSUInteger)index;
@end
