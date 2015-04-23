//
//  TYView.h
//  drawText
//
//  Created by qingyun on 14-9-26.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYDrawView : UIView

- (void)clear;

- (void)back;

- (void)save;

- (void)changeColorWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;

- (UIImage *)getDrawImage;


@end
