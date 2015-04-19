//
//  TYAccountAccess.m
//  TYHomework
//
//  Created by taoYe on 15/4/6.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYAccountAccess.h"
#import "TYPasswordEncoder.h"

@implementation TYAccountAccess
+ (void)registerWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name action:(RSAccountAction)action {
    NSURLRequest *urlRequest = [self postAssemble:@"register" dict:@{@"mail": email, @"username": name, @"password": [TYPasswordEncoder encode:password], @"need_encrypt": @"false"}];
    [urlRequest performResult:^(NSInteger code, id result, NSError *error) {
        if (error) {
            return action(nil, error);
        }
        __RyxTokenAccountWrapper *t = [__RyxTokenAccountWrapper parse:result];
        if (t) {
            [[t account] setPlatform:0];
            [[t account] setPassword:[RSPasswordEncoder encode:password]];
            if ([t token]) {
                [RSToken reloadToken:[t token]];
            }
            
            if ([t account]) {
                [RSAccount reloadAccount:[t account]];
            }
            
            return action([t account], error);
        }
        return action(nil, error);
    }];
}

+ (void)checkName:(NSString *)name action:(void (^)(BOOL, NSError *))action {
}

+ (void)updateInfo:(NSString *)name gender:(NSInteger)gender age:(NSInteger)age location:(CLLocation *)location locationDescription:(NSString *)locationDescription introduction:(NSString *)introduction height:(NSInteger)height weight:(NSInteger)weight avatar:(id)avatar action:(RSAccountAction)action {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:8];
    if (name) dict[@"username"] = name;
    if (gender != -1) dict[@"gender"] = @(gender);
    if (age != -1) dict[@"age"] = @(age);
    if (location) {
        dict[@"latitude"] = [NSString stringWithFormat:@"%f", [location coordinate].latitude];
        dict[@"longitude"] = [NSString stringWithFormat:@"%f", [location coordinate].longitude];
    }
    if (locationDescription) dict[@"location"] = locationDescription;
    if (introduction) dict[@"intro"] = introduction;
    if (height != -1) dict[@"height"] = @(height);
    if (weight != -1) dict[@"weight"] = @(weight);
    if (avatar) dict[@"file"] = avatar;
    if ([dict count] == 0) {
        return action([RSBaseAccount currentAccount], nil);
    }
    [[self postFormAssemble:@"update" dict:dict] performResult:^(NSInteger code, id result, NSError *error) {
        if (error) {
            return  action(nil, error);
        }
        RSAccount *x = [RSAccount parse:result];
        if (x) {
            RSAccount *a = [RSBaseAccount currentAccount];
            [x setPassword:[a password]];
            [x setPlatform:[a platform]];
            [RSBaseAccount reloadAccount:x];
            return action(x, error);
        }
        return action(nil, error);
    }];
}


+ (void)loginWithEmail:(NSString *)email password:(NSString *)password action:(RSAccountAction)action {
    NSURLRequest *urlRequest = [self postAssemble:@"login" dict:@{@"mail": email, @"password": [RSPasswordEncoder encode:password]}];
    [urlRequest performResult:^(NSInteger code, id result, NSError *error) {
        if (error) {
            return action(nil, error);
        }
        __RyxTokenAccountWrapper *t = [__RyxTokenAccountWrapper parse:result];
        if (t) {
            [[t account] setPlatform:0];
            [[t account] setPassword:[RSPasswordEncoder encode:password]];
            if ([t token]) {
                [RSToken reloadToken:[t token]];
            }
            
            if ([t account]) {
                [RSAccount reloadAccount:[t account]];
            }
            
            return action([t account], error);
        }
        return action(nil, error);
    }];
}

+ (void)loginWithWeiboToken:(NSString *)token action:(RSAccountAction)action {
    NSURLRequest *urlRequest = [self postAssemble:@"login_weibo" dict:@{@"weibo_token": token}];
    [urlRequest performResult:^(NSInteger code, id result, NSError *error) {
        if (error) {
            return action(nil, error);
        }
        __RyxTokenAccountWrapper *t = [__RyxTokenAccountWrapper parse:result];
        if (t) {
            [[t account] setPlatform:1];
            [[t account] setPassword:[RSPasswordEncoder encode:[NSString stringWithFormat:@"sina_%lld", [[t account] sinaID]]]];
            if ([t token]) {
                [RSToken reloadToken:[t token]];
            }
            
            if ([t account]) {
                [RSAccount reloadAccount:[t account]];
            }
            
            return action([t account], error);
        }
        return action(nil, error);
    }];
}


+ (void)_accessWechatTokenWithCode:(NSString *)code action:(void (^)(NSString *token, NSString *openID, NSError *error))action {
    NSString *urlString = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", [RSWechatContent wechatClientID], [RSWechatContent wechatSecretID], code];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request perform:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error != nil) {
            action(nil, nil, error);
            return ;
        }
        NSError *jsonError = nil;
        NSDictionary *dict = [RSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSInteger errorCode = [dict[@"errcode"] integerValue];
            if (errorCode) {
                return action(nil, nil, [NSError errorWithDomain:@"RSWechatErrorDomain" code:errorCode userInfo:nil]);
            }
            NSString *token = dict[@"access_token"];
            NSString *refreshToken __unused = dict[@"refresh_token"];
            NSString *openid = dict[@"openid"];
            return action(token, openid, nil);
        }
    }];
}

+ (void)loginWithWechatCode:(NSString *)code action:(RSAccountAction)action {
    [self _accessWechatTokenWithCode:code action:^(NSString *accessToken, NSString *openID, NSError *error) {
        if (error != nil) {
            action(nil, error);
            return ;
        }
        if (accessToken && openID) {
            NSURLRequest *urlRequest = [self postAssemble:@"login_weixin" dict:@{@"weixin_token": accessToken, @"openid": openID}];
            [urlRequest performResult:^(NSInteger code, id result, NSError *error) {
                __RyxTokenAccountWrapper *t = [__RyxTokenAccountWrapper parse:result];
                if (t) {
                    [[t account] setPlatform:2];
                    [[t account] setPassword:[RSPasswordEncoder encode:[NSString stringWithFormat:@"weixin_%@", [RSPasswordEncoder encodeWechat:openID]]]];
                    if ([t token]) {
                        [RSToken reloadToken:[t token]];
                    }
                    
                    if ([t account]) {
                        [RSAccount reloadAccount:[t account]];
                    }
                    
                    return action([t account], error);
                }
                return action(nil, error);
            }];
        }
    }];
}

+ (void)findPasswordByEmail:(NSString *)email action:(RSDoneAction)action {
    [[self postAssemble:@"findPasswordByEmail" dict:@{@"email": email}] performResult:^(NSInteger code, id result, NSError *error) {
        action(error);
    }];
}

@end
