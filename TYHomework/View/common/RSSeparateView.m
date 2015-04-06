//
//  RSSeparateView.m
//  FITogether
//
//  Created by taoYe on 15/1/16.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import "RSSeparateView.h"

@implementation RSSeparateView


- (void)drawRect:(CGRect)rect {
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(cxt, 1);
    [[UIColor blackColor] set];
    CGContextMoveToPoint(cxt, 0, rect.size.height);
    CGContextAddLineToPoint(cxt, rect.size.width, rect.size.height);
    CGContextStrokePath(cxt);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ( self = [super initWithCoder:aDecoder]) {
        self.alpha = 0.3;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0.3;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
