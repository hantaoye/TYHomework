//
//  TYAccountAccess.m
//  TYHomework
//
//  Created by taoYe on 15/4/6.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYAccountAccess.h"
#import "TYPasswordEncoder.h"
#import "TYSharePath.h"
#import "TYAccount.h"

@implementation TYAccountAccess
+ (void)registerWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name action:(RSAccountAction)action {
    NSString *path = [TYSharePath getAccountDateBasePath];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    if (!array) {
        TYAccount *account = [[TYAccount alloc] init];
        NSString *encodeString = [TYPasswordEncoder encode:password];
       return action(account, nil);
    }
    NSError *error = nil;
    return action(nil, error);
}

+ (void)checkName:(NSString *)name action:(void (^)(BOOL, NSError *))action {
}

+ (void)updateInfo:(NSString *)name gender:(NSInteger)gender age:(NSInteger)age location:(CLLocation *)location locationDescription:(NSString *)locationDescription introduction:(NSString *)introduction height:(NSInteger)height weight:(NSInteger)weight avatar:(id)avatar action:(RSAccountAction)action {
    TYAccount *account = [TYAccount currentAccount];
    account.name = name;
    if (gender != -1) account.gender = gender;
    if (age != -1) account.age = age;
//    if (location) {
//        dict[@"latitude"] = [NSString stringWithFormat:@"%f", [location coordinate].latitude];
//        dict[@"longitude"] = [NSString stringWithFormat:@"%f", [location coordinate].longitude];
//    }
    if (locationDescription) account.location = locationDescription;
    if (introduction) account.introduction = introduction;
    
    [[TYShareStorage shareStorage] synchronize];
    return action(account, nil);
}


+ (void)loginWithEmail:(NSString *)email password:(NSString *)password action:(RSAccountAction)action {
    NSString *encoderString = [TYPasswordEncoder encode:password];

//        __RyxTokenAccountWrapper *t = [__RyxTokenAccountWrapper parse:result];
//        if (t) {
//            [[t account] setPlatform:0];
//            [[t account] setPassword:[RSPasswordEncoder encode:password]];
//            if ([t token]) {
//                [RSToken reloadToken:[t token]];
//            }
//            
//            if ([t account]) {
//                [RSAccount reloadAccount:[t account]];
//            }
//            
//            return action([t account], error);
//        }
//        return action(nil, error);
//    }];
}

+ (void)loginWithWeiboToken:(NSString *)token action:(RSAccountAction)action {
//    NSURLRequest *urlRequest = [self postAssemble:@"login_weibo" dict:@{@"weibo_token": token}];
//    [urlRequest performResult:^(NSInteger code, id result, NSError *error) {
//        if (error) {
//            return action(nil, error);
//        }
//        __RyxTokenAccountWrapper *t = [__RyxTokenAccountWrapper parse:result];
//        if (t) {
//            [[t account] setPlatform:1];
//            [[t account] setPassword:[RSPasswordEncoder encode:[NSString stringWithFormat:@"sina_%lld", [[t account] sinaID]]]];
//            if ([t token]) {
//                [RSToken reloadToken:[t token]];
//            }
//            
//            if ([t account]) {
//                [RSAccount reloadAccount:[t account]];
//            }
//            
//            return action([t account], error);
//        }
//        return action(nil, error);
//    }];
}


+ (void)_accessWechatTokenWithCode:(NSString *)code action:(void (^)(NSString *token, NSString *openID, NSError *error))action {
//    NSString *urlString = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", [RSWechatContent wechatClientID], [RSWechatContent wechatSecretID], code];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    [request perform:^(NSURLResponse *response, NSData *data, NSError *error) {
//        if (error != nil) {
//            action(nil, nil, error);
//            return ;
//        }
//        NSError *jsonError = nil;
//        NSDictionary *dict = [RSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
//        if ([dict isKindOfClass:[NSDictionary class]]) {
//            NSInteger errorCode = [dict[@"errcode"] integerValue];
//            if (errorCode) {
//                return action(nil, nil, [NSError errorWithDomain:@"RSWechatErrorDomain" code:errorCode userInfo:nil]);
//            }
//            NSString *token = dict[@"access_token"];
//            NSString *refreshToken __unused = dict[@"refresh_token"];
//            NSString *openid = dict[@"openid"];
//            return action(token, openid, nil);
//        }
//    }];
}

+ (void)loginWithWechatCode:(NSString *)code action:(RSAccountAction)action {
//    [self _accessWechatTokenWithCode:code action:^(NSString *accessToken, NSString *openID, NSError *error) {
//        if (error != nil) {
//            action(nil, error);
//            return ;
//        }
//        if (accessToken && openID) {
//            NSURLRequest *urlRequest = [self postAssemble:@"login_weixin" dict:@{@"weixin_token": accessToken, @"openid": openID}];
//            [urlRequest performResult:^(NSInteger code, id result, NSError *error) {
//                __RyxTokenAccountWrapper *t = [__RyxTokenAccountWrapper parse:result];
//                if (t) {
//                    [[t account] setPlatform:2];
//                    [[t account] setPassword:[RSPasswordEncoder encode:[NSString stringWithFormat:@"weixin_%@", [RSPasswordEncoder encodeWechat:openID]]]];
//                    if ([t token]) {
//                        [RSToken reloadToken:[t token]];
//                    }
//                    
//                    if ([t account]) {
//                        [RSAccount reloadAccount:[t account]];
//                    }
//                    
//                    return action([t account], error);
//                }
//                return action(nil, error);
//            }];
//        }
//    }];
}

+ (void)findPasswordByEmail:(NSString *)email action:(RSDoneAction)action {
//    [[self postAssemble:@"findPasswordByEmail" dict:@{@"email": email}] performResult:^(NSInteger code, id result, NSError *error) {
//        action(error);
//    }];
}

@end
