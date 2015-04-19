//
//  TYLoginHelper.h
//  TYHomework
//
//  Created by taoYe on 15/4/7.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYAccountAccess.h"

@interface TYLoginHelper : NSObject
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password action:(RSAccountAction)action;
+ (void)loginWithWeiboToken:(NSString *)weiboToken action:(RSAccountAction)action;
+ (void)loginWithWechatCode:(NSString *)wechatCode action:(RSAccountAction)action;

@end
