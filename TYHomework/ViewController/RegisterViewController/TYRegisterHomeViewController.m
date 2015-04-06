//
//  RSWelcomeViewController.m
//  FITogether
//
//  Created by taoYe on 15/3/17.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import "TYRegisterHomeViewController.h"
//#import "RSWechatConnector.h"
#import "TYShareStorage.h"
#import "TYDebugLog.h"
#import "TYViewControllerLoader.h"

@interface TYRegisterHomeViewController () //<RSWechatResponseDelegate>
@property (nonatomic, weak) IBOutlet UIButton *weiboLoginButton;
@property (nonatomic, weak) IBOutlet UIButton *wechatLoginButton;

@end

@implementation TYRegisterHomeViewController

- (IBAction)weiboLoginButtonPressed:(id)sender {
//    [[RSSharedStorage sharedStorage].middleware.weiboDelegate authorize:^(WBAuthorizeResponse *weiboResponse) {
//        if (weiboResponse != nil) {
//            [RSLoginHelper loginWithWeiboToken:weiboResponse.accessToken action:^(RSAccount *account, NSError *error) {
//                if (account != nil) {
//                    [RSBranchViewControllerLoader loadMainEntry:true];
//                }
//            }];
//        }
//        return;
//    }];
}

- (IBAction)wechatLoginButtonPressed:(UIButton *)sender {
//    [RSSharedStorage sharedStorage].middleware.wechatDelegate.delegate = self;
//    [[RSSharedStorage sharedStorage].middleware.wechatDelegate authorize:self];
}

//- (void)authResponse:(SendAuthResp *)response {
//    if (response.errCode == 0) {
//        [RSLoginHelper loginWithWechatCode:response.code action:^(RSAccount *account, NSError *error) {
//            if (account != nil) {
//                [RSBranchViewControllerLoader loadMainEntry:YES];
//            }
//        }];
//    } else {
//    }
//}

- (BOOL)checkWeiboSDK {
   id weiboSdbDelegateClass = NSClassFromString(@"RSWeiboSDKDelegate");
    if (weiboSdbDelegateClass) {
        return YES;
    }
    return NO;
}

- (BOOL)checkWechateSDK {
    id wechatSDKDelegateClass = NSClassFromString(@"RSWechatSDKDelegate");
    if (wechatSDKDelegateClass) {
        return YES;
    }
    return NO;
}

- (void)check3rdSDK {
    if (![self checkWeiboSDK]) {
        self.weiboLoginButton.enabled = NO;
        self.weiboLoginButton.hidden = YES;
    }
    if (![self checkWechateSDK]) {
        self.wechatLoginButton.enabled = NO;
        self.wechatLoginButton.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self check3rdSDK];
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
