//
//  TYViewControllerHelp.h
//  TYHomework
//
//  Created by taoYe on 15/4/23.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYObject.h"

@interface TYViewControllerHelp : TYObject

@property (strong, nonatomic) UIViewController *viewController;

+ (instancetype)shareHelp;

@end
