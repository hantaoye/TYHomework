//
//  TYSeparateView.m
//  FITogether
//
//  Created by taoYe on 15/1/16.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import "TYSeparateView.h"

@implementation TYSeparateView


- (void)drawRect:(CGRect)rect {
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(cxt, 1);
    if (_bgColor) {
        [_bgColor set];
    } else {
        [[UIColor blackColor] set];
    }
    CGContextMoveToPoint(cxt, 0, rect.size.height);
    CGContextAddLineToPoint(cxt, rect.size.width, rect.size.height);
    CGContextStrokePath(cxt);
}

- (void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    [self setNeedsDisplay];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ( self = [super initWithCoder:aDecoder]) {
        self.alpha = 0.2;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0.2;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
