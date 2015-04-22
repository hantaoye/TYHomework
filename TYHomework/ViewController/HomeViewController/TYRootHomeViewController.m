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

@interface TYRootHomeViewController ()
@property (weak, nonatomic) IBOutlet TYRoundImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@end

@implementation TYRootHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
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
