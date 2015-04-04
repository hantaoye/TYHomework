//
//  TyDrawView.h
//  TYHomework
//
//  Created by taoYe on 15/3/17.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYBaseView.h"

@interface TyDrawView : TYBaseView

- (void)clear;

- (void)back;

- (void)save;

-(void)changeColorWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;

@end