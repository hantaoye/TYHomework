//
//  TYAccountAccess.h
//  TYHomework
//
//  Created by taoYe on 15/4/6.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TYAccount;

typedef void (^RSAccountAction)(TYAccount *account, NSError *error);
typedef void (^RSAccountsAction)(NSArray *accounts, NSError *error);

@interface TYAccountAccess : NSObject

+ (void)registerWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name action:(RSAccountAction)action;
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password action:(RSAccountAction)action;
+ (void)loginWithWeiboToken:(NSString *)token action:(RSAccountAction)action;
+ (void)loginWithWechatCode:(NSString *)code action:(RSAccountAction)action;

+ (void)checkName:(NSString *)name action:(void (^)(BOOL success, NSError *error))action;
+ (void)checkEmail:(NSString *)email action:(void (^)(BOOL success, NSError *error))action;
+ (void)resetEmail:(NSString *)email newEmail:(NSString *)newMail password:(NSString *)password action:(RSDoneAction)action;
+ (void)resetPassword:(NSString *)password newPassword:(NSString *)newPassword action:(RSDoneAction)action;
+ (void)findPasswordByEmail:(NSString *)email action:(RSDoneAction)action;
+ (void)updateAvatarImageData:(NSData *)imageData action:(RSAccountAction)action;
+ (void)updateInfo:(NSString *)name gender:(NSInteger)gender age:(NSInteger)age location:(CLLocation *)location locationDescription:(NSString *)locationDescription introduction:(NSString *)introduction height:(NSInteger)height weight:(NSInteger)weight avatar:(id)avatar action:(RSAccountAction)action;
@end
