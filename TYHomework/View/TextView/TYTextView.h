//
//  TYTextView.h
//  TYStatus
//
//  Created by qingyun on 14/10/16.
//  Copyright (c) 2014年 cn.TY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYTextView : UITextView

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

- (void)textChange;
@end
