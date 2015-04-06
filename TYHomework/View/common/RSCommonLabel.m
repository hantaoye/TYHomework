//
//  RSCommonLabel.m
//  FITogether
//
//  Created by taoYe on 15/3/30.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import "RSCommonLabel.h"

@interface RSCommonLabel ()
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@end

@implementation RSCommonLabel

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _edgeInsets = UIEdgeInsetsMake(-1.5, 0, -1.5, 0);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    NSLog(@"%@", NSStringFromCGRect(rect));
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

//- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
//    return CGRectZero;
//}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    size.width  += self.edgeInsets.left + self.edgeInsets.right;
    size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return size;
}
@end
