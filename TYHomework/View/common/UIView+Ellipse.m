//
//  UIView+Ellipse.m
//  FITogether
//
//  Created by taoYe on 14/12/24.
//  Copyright (c) 2014年 closure. All rights reserved.
//

#import "UIView+Ellipse.h"

@implementation UIView (Ellipse)

- (void)becomeEllipseViewWithBorderColor:(UIColor *)color borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = borderWidth;
    self.layer.cornerRadius = cornerRadius;
}

@end
