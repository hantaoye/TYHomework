//
//  RSForgetPasswordViewController.m
//  FITogether
//
//  Created by taoYe on 15/3/17.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import "TYForgetPasswordViewController.h"
#import "RSProgressHUD.h"
#import "TYEmailVerify.h"
#import "TYAccountAccess.h"
#import "TYDebugLog.h"

@interface TYForgetPasswordViewController () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;

@end

@implementation TYForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)updateUI {
    if (_emailTextField.text.length == 0) {
        [RSProgressHUD showErrorWithStatus:@"邮箱不能为空"];
        return;
    } else if ([TYEmailVerify verify:_emailTextField.text]) {
        [RSProgressHUD showErrorWithStatus:@"邮箱格式错误"];
        return;
    }
    [_emailTextField resignFirstResponder];
    _doneButton.enabled = YES;
}

- (IBAction)doneButtonPressed:(id)sender {
    [RSProgressHUD showWithStatus:@"邮件发送中..." maskType:RSProgressHUDMaskTypeGradient];
    [TYAccountAccess findPasswordByEmail:_emailTextField.text action:^(NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [RSProgressHUD showErrorWithStatus:@"发送失败"];
                [TYDebugLog error:error.localizedDescription];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [RSProgressHUD showSuccessWithStatus:@"发送成功, 请注意查收"];
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _emailTextField) {
        [self updateUI];
        if (_doneButton.enabled) {
            
        }
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

@end
