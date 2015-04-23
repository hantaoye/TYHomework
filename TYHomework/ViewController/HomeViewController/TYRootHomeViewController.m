//
//  TYRootHomeViewController.m
//  TYHomework
//
//  Created by taoYe on 15/4/19.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYRootHomeViewController.h"
#import "TYRoundImageView.h"
#import "TYAnimationController.h"
#import "TYAccount.h"
#import "UIImage+TY.h"

@interface TYRootHomeViewController ()
@property (weak, nonatomic) IBOutlet TYRoundImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@end

@implementation TYRootHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    self.navigationController.navigationBarHidden = YES;
}

- (void)setupData {
    [TYShareStorage shareStorage];
    TYAccount *account = [TYAccount currentAccount];
//    assert(account != nil && @"account 为nil");
    NSData *data = [NSData dataWithContentsOfFile:account.avatarURL];
    _iconImageView.image = [UIImage imageWithData:data];
    _welcomeLabel.text = [NSString stringWithFormat:@"欢迎回来: %@", account.name];
    _nameLabel.text = account.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)pressedNextButton:(UIButton *)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    UIViewController *VC = segue.destinationViewController;
//    VC.transitioningDelegate = [TYAnimationController new];
}

@end
