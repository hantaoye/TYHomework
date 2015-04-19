//
//  TYTabbarButton.h
//  TYHomework
//
//  Created by taoYe on 15/4/19.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TYTabbarScale 0.7

@interface TYTabbarButton : UIButton

- (void)setTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage badgeValue:(NSString *)badgeValue;

@end
