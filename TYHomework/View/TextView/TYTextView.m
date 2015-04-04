//
//  TYTextView.m
//  TYStatus
//
//  Created by qingyun on 14/10/16.
//  Copyright (c) 2014年 cn.TY. All rights reserved.
//

#import "TYTextView.h"
#import "NSString+TY.h"

#define TYNotificationCenter [NSNotificationCenter defaultCenter]

@interface TYTextView ()
@property (nonatomic, weak) UILabel *placeholderLabel;

@end

@implementation TYTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel *label = [[UILabel alloc] init];
        [self insertSubview:label atIndex:0];
        label.font = [UIFont systemFontOfSize:14];//使得默认大小跟self字体的大小一样
        label.numberOfLines = 0;
        label.hidden = YES;
        label.textColor = [UIColor lightGrayColor];
        self.placeholderLabel = label;
        
        [TYNotificationCenter addObserver:self selector:@selector(textChange) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (void)textChange
{
    self.placeholderLabel.hidden = (self.text.length != 0);
}

- (void)dealloc
{
    [TYNotificationCenter removeObserver:self];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = [placeholder copy];
    self.placeholderLabel.text = placeholder;
    if (placeholder.length == 0) {
        self.placeholderLabel.hidden = YES;
        return;
    }
    self.placeholderLabel.hidden = NO;
    CGFloat labelX = 5;
    CGFloat labelY = 8;
    CGSize labelSize = [placeholder sizeWithFont:self.placeholderLabel.font maxWidth:self.bounds.size.width - 2 * labelX];
    
    self.placeholderLabel.frame = CGRectMake(labelX, labelY, labelSize.width, labelSize.height);
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = placeholderColor;
}

- (void)setFont:(UIFont *)font//第一次调用的时候，    self.placeholderLabel.font = nil；
{
    [super setFont:font];
    
    self.placeholderLabel.font = font;
    self.placeholder = self.placeholder;//再次调用， 用来计算大小
}

@end
