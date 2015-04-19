//
//  RSRoundImageView.h
//  FITogether
//
//  Created by taoYe on 14/12/23.
//  Copyright (c) 2014年 closure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYRoundImageView : UIImageView
@property (nonatomic, assign, getter=isClickEnable) BOOL clickEnable;

@property (nonatomic, assign, getter=isSelected) BOOL selected;

@property (nonatomic, assign, getter=isNoRound) BOOL noRound;

@property (nonatomic, copy) IBInspectable NSString *title;


@end
