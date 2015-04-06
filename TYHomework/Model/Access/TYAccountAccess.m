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


@end
