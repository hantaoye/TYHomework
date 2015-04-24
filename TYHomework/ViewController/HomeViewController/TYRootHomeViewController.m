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
#import "TYImageHelper.h"

@interface TYRootHomeViewController ()
@property (weak, nonatomic) IBOutlet TYRoundImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *introdation;

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
    _iconImageView.image = [TYImageHelper getImageForPath:account.avatarURL];
    _welcomeLabel.text = [NSString stringWithFormat:@"欢迎回来: %@", account.name];
    _nameLabel.text = account.name;
    if (account.introduction.length) {
        _introdation.text = account.introduction;
    } else {
        _introdation.text = @"";
    }
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
