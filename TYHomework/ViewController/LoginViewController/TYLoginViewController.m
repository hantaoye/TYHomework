//
//  RSLoginViewController.m
//  FITogether
//
//  Created by taoYe on 15/3/17.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import "TYLoginViewController.h"
#import "TYEmailVerify.h"
#import "RSProgressHUD.h"
#import "RSLoginHelper.h"
#import "RSBranchViewControllerLoader.h"

@interface TYLoginViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UILabel *loginLabel;
@property (nonatomic, assign) BOOL emailValid;
@property (nonatomic, assign) BOOL passwordValid;

@property (nonatomic, strong) UITapGestureRecognizer *gestureEmailTextField;
@property (nonatomic, strong) UITapGestureRecognizer *gesturePasswordTextField;

@end

@implementation TYLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _gestureEmailTextField = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
    _gesturePasswordTextField = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"register_background"]];
    imageView.contentMode = UIViewContentModeScaleToFill;
    self.tableView.backgroundView = imageView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [TalkingData beginTrack:[self class]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [TalkingData endTrack:[self class]];
}

- (void)keyboardShow:(NSNotification *)notification {
    [self.tableView addGestureRecognizer:_gestureEmailTextField];
    [self.tableView addGestureRecognizer:_gesturePasswordTextField];
}

- (void)keyboardHide:(NSNotification *)notification {
    [self.tableView removeGestureRecognizer:_gestureEmailTextField];
    [self.tableView removeGestureRecognizer:_gesturePasswordTextField];
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateUI:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _emailTextField) {
        if (_emailTextField.text.length) {
            _emailValid = [RSEmailVerify verify:_emailTextField.text];
        }
        if (_emailValid) {
            [textField resignFirstResponder];
            [_passwordTextField becomeFirstResponder];
        } else {
            self.loginLabel.enabled = NO;
            if (_emailTextField.text == 0) {
                [RSProgressHUD showErrorWithStatus:@"邮箱不能为空"];
            } else {
                [RSProgressHUD showErrorWithStatus:@"邮箱格式错误"];
            }
            return NO;
        }
    } else if (textField == _passwordTextField) {
        _passwordValid = [self verifyPassword:_passwordTextField.text];
        if (_emailValid && _passwordValid) {
            _loginLabel.enabled = YES;
            [_passwordTextField resignFirstResponder];
            [self loginBtnPressed:nil];
        } else {
            _loginLabel.enabled = NO;
            return NO;
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *str = [textField.text mutableCopy];
    [str stringByReplacingCharactersInRange:range withString:string];
    if (textField == _passwordTextField) {
        if ([self verifyPassword:str] && _emailValid) {
            _passwordValid = YES;
            _loginLabel.enabled = true;
        } else {
            _passwordValid = NO;
            _loginLabel.enabled = NO;
        }
    } else if (textField == _emailTextField) {
        if ([RSEmailVerify verify:str] && _passwordValid) {
            _emailValid = YES;
            _loginLabel.enabled = YES;
        } else {
            _emailValid = NO;
            _loginLabel.enabled = NO;
        }
    }
    return true;
}

- (BOOL)verifyPassword:(NSString *)password {
    if (password.length) {
        return password.length >= 1;
    }
    return NO;
}

- (void)updateUI:(UITextField *)textField {
    if (textField == _emailTextField) {
        if (_emailTextField.text.length) {
            _emailValid = [RSEmailVerify verify:_emailTextField.text];
        }
        if (_emailValid) {
            [_emailTextField resignFirstResponder];
            [_passwordTextField becomeFirstResponder];
        } else {
            _loginLabel.enabled = NO;
            if (_emailTextField.text.length == 0) {
                [RSProgressHUD showErrorWithStatus:@"邮箱不能为空"];
            } else {
                [RSProgressHUD showErrorWithStatus:@"邮箱格式错误"];
            }
            return;
        }
    }
    _passwordValid = [self verifyPassword:_passwordTextField.text];
    if (_emailValid && _passwordValid) {
        self.loginLabel.enabled = YES;
        [self.passwordTextField resignFirstResponder];
    } else {
        self.loginLabel.enabled = NO;
    }
}

- (IBAction)loginBtnPressed:(UIButton *)sender {
    [RSLoginHelper loginWithEmail:_emailTextField.text password:_passwordTextField.text action:^(RSAccount *account, NSError *error) {
        if (account != nil) {
            [RSBranchViewControllerLoader loadMainEntry:YES];
        }
    }];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return _loginLabel.enabled;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_loginLabel.enabled && indexPath.section == 1 && indexPath.row == 0) {
        [self loginBtnPressed:nil];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.view != _emailTextField) {
        [_emailTextField resignFirstResponder];
        if (touch.view == _passwordTextField) {
            [_passwordTextField becomeFirstResponder];
            [self updateUI:_emailTextField];
        }
    } else if (touch.view != _passwordTextField) {
        [_passwordTextField resignFirstResponder];
        if (touch.view == _emailTextField) {
            [_emailTextField becomeFirstResponder];
            [self updateUI:_passwordTextField];
        }
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
