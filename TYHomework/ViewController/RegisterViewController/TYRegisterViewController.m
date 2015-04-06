//
//  RSRegisterViewController.m
//  FITogether
//
//  Created by closure on 2/5/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#define RSPasswordMaxLength 20
#define RSPassworkMinLength 6

#import "TYRegisterViewController.h"
#import "RSOptions.h"
#import "RSProgressHUD.h"
#import "TYAccountAccess.h"
#import "TYAccount.h"
#import "TYNameVerify.h"
#import "TYEmailVerify.h"

@interface TYRegisterViewController ()
@property (nonatomic, weak) UITextField *target;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, assign) BOOL didRegisteredSucceed;

@property (nonatomic, assign) BOOL nameValid;
@property (nonatomic, assign) BOOL emailValid;
@property (nonatomic, assign) BOOL passwordValid;
@property (nonatomic, assign) BOOL verifyValid;
@end

@implementation TYRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"register_background"]];
    [imageView setContentMode:UIViewContentModeScaleToFill];
    [[self tableView] setBackgroundView:imageView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    [self addObserver:self forKeyPath:@"nameValid" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"emailValid" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"passwordValid" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"verifyValid" options:NSKeyValueObservingOptionNew context:nil];
    
    [self setupTapGesture];
}

- (void)keyboardWillShow {
    [self.tableView addGestureRecognizer:_tapGesture];
}

- (void)keyboardWillHide {
    [self.tableView removeGestureRecognizer:_tapGesture];
}

- (void)setupTapGesture {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressedTableView)];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"nameValid"];
    [self removeObserver:self forKeyPath:@"emailValid"];
    [self removeObserver:self forKeyPath:@"passwordValid"];
    [self removeObserver:self forKeyPath:@"verifyValid"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**
 *  退去键盘
 */
- (void)didPressedTableView {
    [self.view.window endEditing:YES];
    [self _verifyVerifyPassword:_verifyPasswordTextField onlyVerify:YES];
    [self updateNextBarButtonStatus];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self didPressedTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextButtonPressed:(UIBarButtonItem *)sender {
    if (![self _verifyName:_nameTextField onlyVerify:YES] ||
        ![self _verifyEmail:_emailTextField onlyVerify:YES] ||
        ![self _verifyPassword:_passwordTextField onlyVerify:YES] ||
        ![self _verifyVerifyPassword:_verifyPasswordTextField onlyVerify:YES]) {
        [RSProgressHUD showErrorWithStatus:@"信息有错误"];
        return;
    }
    [RSProgressHUD showWithStatus:@"注册中..." maskType:RSProgressHUDMaskTypeGradient];
    
    [TYAccountAccess registerWithEmail:[_emailTextField text] password:[_passwordTextField text] name:[_nameTextField text] action:^(TYAccount *account, NSError *error) {
        if (error) {
            [TYDebugLog error:[error localizedDescription]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [RSProgressHUD showErrorWithStatus:@"注册失败, 邮箱或用户名已被使用"];
            });
            return;
        } else {
//            [[TYShareStorage shareStorage] setupCacheStorageIfNecessary];
            dispatch_async(dispatch_get_main_queue(), ^{
                [RSProgressHUD  showSuccessWithStatus:@"注册成功"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _didRegisteredSucceed = YES;
                    [self performSegueWithIdentifier:@"segueForFillProfile" sender:self];
                });
            });
        }
    }];
}

- (BOOL)_verifyName:(UITextField *)textField {
    return [self _verifyName:textField onlyVerify:NO];
}

- (BOOL)_verifyName:(UITextField *)textField onlyVerify:(BOOL)onlyVerify {
    if (![TYNameVerify verify:[textField text]]) {
        [textField setTextColor:[UIColor redColor]];
        if (onlyVerify) {
            return NO;
        }
        
        if (![TYNameVerify verifyShort:[textField text]]) {
            [RSProgressHUD showErrorWithStatus:[[RSOptions option] nameTextFieldShouldOver4Error]];
        } else {
            [RSProgressHUD showErrorWithStatus:[[RSOptions option] nameTextFieldShouldLess14Error]];
        }
        
        return NO;
    }
    [textField setTextColor:[UIColor blackColor]];
    if (onlyVerify) {
        return YES;
    }
    [TYAccountAccess checkName:[textField text] action:^(BOOL success, NSError *error) {
        [self setNameValid:success];
        if (!success) {
            [TYDebugLog error:[error localizedDescription]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [RSProgressHUD showErrorWithStatus:RSOptions.option.nameTextFieldConflictError];
                [textField setTextColor:[UIColor redColor]];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [textField setTextColor:[UIColor blackColor]];
            });
        }
    }];
    return YES;
}

- (BOOL)_verifyEmail:(UITextField *)textField {
    return [self _verifyEmail:textField onlyVerify:NO];
}

- (BOOL)_verifyEmail:(UITextField *)textField  onlyVerify:(BOOL)onlyVerify {
    if (![TYEmailVerify verify:[textField text]]) {
        [textField setTextColor:[UIColor redColor]];
        if (onlyVerify) {
            return NO;
        }
        [RSProgressHUD showErrorWithStatus:[[RSOptions option] emailAddressFormatInvalid]];
        return NO;
    }
    [textField setTextColor:[UIColor blackColor]];
    
    if (onlyVerify) {
        return YES;
    }
    
    [TYAccountAccess checkEmail:[textField text] action:^(BOOL success, NSError *error) {
        [self setEmailValid:success];
        if (!success) {
            [TYDebugLog error:[error localizedDescription]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [RSProgressHUD showErrorWithStatus:[[RSOptions option] emailTextFieldConflictError]];
                [textField setTextColor:[UIColor redColor]];
            });
            return;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [textField setTextColor:[UIColor blackColor]];
            });
        }
    }];
    return YES;
}

- (BOOL)_verifyPassword:(UITextField *)textField onlyVerify:(BOOL)onlyVerify {
    BOOL result;
    if (textField.text.length < RSPassworkMinLength) {
        if (!onlyVerify) {
            [RSProgressHUD showErrorWithStatus:[[RSOptions option] passwordLengthShouldOver6Error]];
        }
        result = NO;
    } else if (textField.text.length > RSPasswordMaxLength) {
        if (!onlyVerify) {
            [RSProgressHUD showErrorWithStatus:[[RSOptions option] passwordLengthShouldLess20Error]];
        }
        result = NO;
    } else {
        result = YES;
    }
    return result;
}

- (BOOL)_verifyVerifyPassword:(UITextField *)textField onlyVerify:(BOOL)onlyVerify {
    BOOL result = NO;
    if (![textField.text isEqualToString:_passwordTextField.text]) {
        if (!onlyVerify) {
            [RSProgressHUD showErrorWithStatus:@"两次密码输入不一致"];
        }
        result = NO;
    } else {
        result = YES;
    }
    return result;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _target = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_didRegisteredSucceed) {
        return;
    }
    
    BOOL result = NO;
    if ([[textField text] length] == 0) {
        return;
    }
    if (textField == _nameTextField) {
        result = [self _verifyName:textField];
        [self setNameValid:result];
    } else if (textField == _emailTextField) {
        result = [self _verifyEmail:textField];
        [self setEmailValid:result];
    } else if (textField == _passwordTextField) {
        result = [self _verifyPassword:textField onlyVerify:NO];
        [self setPasswordValid:result];
    } else if (textField == _verifyPasswordTextField) {
        result = [self _verifyVerifyPassword:textField onlyVerify:NO];
        [self setVerifyValid:result];
    }
    return;
}

- (void)updateNextBarButtonStatus {
    if ([NSThread isMainThread]) {
        [_nextButton setEnabled:_nameValid && _emailValid && _passwordValid && (_verifyValid)];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_nextButton setEnabled:_nameValid && _emailValid && _passwordValid && (_verifyValid)];
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL result = NO;
    if (textField == _nameTextField) {
        result = [self _verifyName:textField];
        [self setNameValid:result];
        if (result) {
            [_emailTextField becomeFirstResponder];
            [textField resignFirstResponder];
        }
    } else if (textField == _emailTextField) {
        result = [self _verifyEmail:textField];
        [self setEmailValid:result];
        if (result) {
            [_passwordTextField becomeFirstResponder];
            [textField resignFirstResponder];
        }
    } else if (textField == _passwordTextField) {
        result = [self _verifyPassword:textField onlyVerify:NO];
        [self setPasswordValid:result];
        if (result) {
            [textField resignFirstResponder];
            [_verifyPasswordTextField becomeFirstResponder];
        }
    } else if (textField == _verifyPasswordTextField) {
        result = [self _verifyVerifyPassword:textField onlyVerify:NO];
        [self setVerifyValid:result];
        if (result) {
            [textField resignFirstResponder];
            [self nextButtonPressed:_nextButton];
        }
    }
    return result;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context     {
    if ([keyPath isEqualToString:@"nameValid"]) {
        [self updateNextBarButtonStatus];
    } else if ([keyPath isEqualToString:@"emailValid"]) {
        [self updateNextBarButtonStatus];
    } else if ([keyPath isEqualToString:@"passwordValid"]) {
        [self updateNextBarButtonStatus];
    } else if ([keyPath isEqualToString:@"verifyValid"]) {
        [self updateNextBarButtonStatus];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _emailTextField) {
        return YES;
    }
    if (textField == _verifyPasswordTextField) {
        NSMutableString *str = [[textField text] mutableCopy];
        [str replaceCharactersInRange:range withString:string];
        if ([str length]) {
            [self setVerifyValid:YES];
        } else {
            [self setVerifyValid:NO];
        }
    }
    
    return YES;
}

@end
