//
//  RSFillPersonalMessageViewControllr.m
//  FITogether
//
//  Created by taoYe on 15/3/17.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import "TYFillPersonalMessageViewControllr.h"
#import "TYPlaceholderTextView.h"
#import "TYPasswordEncoder.h"
#import "TYAccountAccess.h"
#import "TYViewControllerLoader.h"

@interface TYFillPersonalMessageViewControllr () <UITextViewDelegate>
@property (nonatomic, weak) IBOutlet TYPlaceholderTextView *personalMessageTextView;


@end

@implementation TYFillPersonalMessageViewControllr

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.delegate && [self.delegate respondsToSelector:@selector(updatePersonalMessage:)]) {
        [self.delegate updatePersonalMessage:_personalMessageTextView.text];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.personalMessageTextView becomeFirstResponder];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"register_background"]];
    imageView.contentMode = UIViewContentModeScaleToFill;
    self.tableView.backgroundView = imageView;
}

- (IBAction)nextBarButtonPressed:(UIBarButtonItem *)sender {
    if ([_personalMessageTextView.text complexLength] > 100) {
        [RSProgressHUD showErrorWithStatus:@"签名请小于100字符"];
        return;
    }
    if (_personalMessageTextView.text != nil && _personalMessageTextView.text.length > 0) {
        [RSProgressHUD showWithStatus:@"更新中..." maskType:RSProgressHUDMaskTypeGradient];
        [TYAccountAccess updateInfo:nil gender:-1 age:-1 location:nil locationDescription:nil introduction:_personalMessageTextView.text height:-1 weight:-1 avatar:nil action:^(TYAccount *account, NSError *error) {
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RSProgressHUD showSuccessWithStatus:@"完成"];
                    [TYViewControllerLoader loadMainEntry];
                });
                return;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RSProgressHUD showErrorWithStatus:@"更新失败"];
                });
                return;
            }
        }];
    } else {
        [TYViewControllerLoader loadMainEntry];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length >= 1) {
       NSString *lastChar = [textView.text substringFromIndex:textView.text.length - 1];
        if ([lastChar isEqualToString:@"\n"]) {
            textView.text = [textView.text substringToIndex:textView.text.length - 1];
            [textView resignFirstResponder];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
