//
//  RSTextFieldKeyboardViewController.m
//  FITogether
//
//  Created by taoYe on 15/3/17.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import "RSTextFieldKeyboardViewController.h"

typedef void (^RSTextFieldKeyboardDoneAction)();

@interface RSTextFieldKeyboardViewController () <UITextFieldDelegate>

@property (nonatomic, weak) UITextField *target;
@property (nonatomic, strong) NSMutableArray *textFields;

@property (nonatomic, assign) BOOL floatingKeyboard;

@property (nonatomic, assign) RSTextFieldKeyboardDoneAction doneAction;
@property (nonatomic, assign) BOOL shouldFloatingUI;

@property (nonatomic, strong) UIMotionEffect *motion;

@property (nonatomic, assign) CGFloat fbixt;

@end

@implementation RSTextFieldKeyboardViewController

- (UIMotionEffect *)motion {
    if (!_motion) {
        CGFloat motionXMinValue = -20.0;
        CGFloat motionYMinValue = -20.0;
        CGFloat motionXMaxValue = 20.0;
        CGFloat motionYMaxValue = 20.0;
        UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        xAxis.minimumRelativeValue = @(motionXMinValue);
        xAxis.maximumRelativeValue = @(motionXMaxValue);
        
        UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        yAxis.minimumRelativeValue = @(motionYMinValue);
        yAxis.maximumRelativeValue = @(motionYMaxValue);
        UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
        group.motionEffects = @[xAxis, yAxis];
        _motion = group;
    }
    return _motion;
}

- (void)setFbixt:(CGFloat)fbixt {
    if (fbixt < 1.0) {
        fbixt = 2.2;
    }
    _fbixt = fbixt;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _target = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _target = nil;
}

- (void)setTextFields:(NSMutableArray *)textFields {
    [self deapplyMotion];
    _textFields = textFields;
    for (UITextField *textField in _textFields) {
        textField.delegate = self;
    }
    [self applyMotion];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    int index = 0;
    for (int i = 0; i < _textFields.count; i++) {
        UITextField *tf = _textFields[i];
        if (textField == tf) {
            index = i;
            break;
        }
    }
    if (index == (_textFields.count - 1)) {
        [self tipGestureActive:nil];
        if (_doneAction != nil) {
            [self doneAction];
        }
    } else {
        [_textFields[index + 1] becomeFirstResponder];
    }
    return YES;
}

- (IBAction)tipGestureActive:(UITapGestureRecognizer *)sender {
    [_target resignFirstResponder];
    _target = nil;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.floatingKeyboard) {
        return;
    }
    if (!self.shouldFloatingUI) {
        return;
    }
    self.floatingKeyboard = YES;
    NSDictionary *info = notification.userInfo;
   CGRect newFrame = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = newFrame;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!self.floatingKeyboard) {
        return;
    }
    if (!self.shouldFloatingUI) {
        return;
    }
    self.floatingKeyboard = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = self.view.bounds;
    }];
}

- (void)bindKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)applyMotion {
    for (UIView *view in self.view.subviews) {
        [view addMotionEffect:self.motion];
    }
}

- (void)deapplyMotion {
    for (UIView *view in self.view.subviews) {
        [view removeMotionEffect:self.motion];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self bindKeyboardNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self deapplyMotion];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _fbixt = 2.2;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tipGestureActive:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
