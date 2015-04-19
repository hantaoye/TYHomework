//
//  TYBaderButton.m
//  TYStatus
//
//  Created by qingyun on 14/10/8.
//  Copyright (c) 2014年 cn.TY. All rights reserved.
//

#import "TYBadgeButton.h"
#import "UIImage+TY.h"

@implementation TYBadgeButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        [self setBackgroundImage:[UIImage resizedImageWithName:@"main_badge"] forState:UIControlStateNormal];
    }
    return self;
}

/**
 *  在内部设置大小Value
 */
- (void)setBadgeValue:(NSString *)badgeValue
{
    _badgeValue = [badgeValue copy];
    
    if (!badgeValue || [badgeValue intValue] == 0) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
        [self setTitle:badgeValue forState:UIControlStateNormal];
        
            CGFloat badgeW = self.currentBackgroundImage.size.width;
            CGFloat badgeH = self.currentBackgroundImage.size.height;
        
        if (badgeValue.length > 1) {
             CGSize size = [self.badgeValue sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
            badgeW = size.width + 10;
        }
        CGRect frame = self.frame;
        frame.size.width = badgeW;
        frame.size.height = badgeH;
        self.frame = frame;
    }
}


@end
