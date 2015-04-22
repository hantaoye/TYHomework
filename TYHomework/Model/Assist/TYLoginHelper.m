//
//  TYLoginHelper.m
//  TYHomework
//
//  Created by taoYe on 15/4/7.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYLoginHelper.h"
#import "TYAccountAccess.h"
#import "TYShareStorage.h"

@implementation TYLoginHelper
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password action:(RSAccountAction)action {
    dispatch_async(dispatch_get_main_queue(), ^{
        [RSProgressHUD showWithStatus:@"登陆中..." maskType:RSProgressHUDMaskTypeGradient];
        [TYAccountAccess loginWithEmail:email password:password action:^(TYAccount *account, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RSProgressHUD showErrorWithStatus:@"邮箱或密码错误"];
                });
                action(nil, error);
                [RSProgressHUD dismiss];
                return ;
            }
            if (account) {
                [[TYShareStorage shareStorage] setupCacheStorageIfNecessary];
                [[TYShareStorage shareStorage] synchronize];
            }
            action(account, error);
            [RSProgressHUD dismiss];
        }];
    });
}

+ (void)loginWithWeiboToken:(NSString *)weiboToken action:(RSAccountAction)action {
    dispatch_async(dispatch_get_main_queue(), ^{
        [RSProgressHUD showWithStatus:@"微博登陆中..." maskType:RSProgressHUDMaskTypeGradient];
        [TYAccountAccess loginWithWeiboToken:weiboToken action:^(TYAccount *account, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RSProgressHUD showErrorWithStatus:@"微博授权失败"];
                });
                action(nil, error);
                return;
            }
            if (account) {
//                [[RSSharedStorage sharedStorage] setupCacheStorageIfNecessary];
//                [[RSSharedStorage sharedStorage] synchronize];
            }
            action(account, error);
        }];
    });
}

+ (void)loginWithWechatCode:(NSString *)wechatCode action:(RSAccountAction)action {
    dispatch_async(dispatch_get_main_queue(), ^{
        [RSProgressHUD showWithStatus:@"微信登陆中..." maskType:RSProgressHUDMaskTypeGradient];
        [TYAccountAccess loginWithWechatCode:wechatCode action:^(TYAccount *account, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RSProgressHUD showErrorWithStatus:@"微信授权失败"];
                });
                action(nil, error);
                return;
            }
            if (account) {
//                [[RSSharedStorage sharedStorage] setupCacheStorageIfNecessary];
//                [[RSSharedStorage sharedStorage] synchronize];
            }
            action(account, error);
        }];
    });
}

@end
