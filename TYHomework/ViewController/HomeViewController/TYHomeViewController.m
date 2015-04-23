//
//  TYHomeViewController.m
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYHomeViewController.h"
#import <VCTransitionsLibrary/CEBaseInteractionController.h>
#import "TYTabbarView.h"
#import "TYViewControllerLoader.h"
#import "TYBaseNavigationController.h"
#import "TYCheckNoteViewController.h"
#import "TYDrawViewController.h"
#import "TYAudioViewController.h"
#import "TYWirteNoteViewController.h"
#import "TYViewControllerHelp.h"
#import "UIImage+TY.h"

@interface TYHomeViewController () <TYTabbarViewDelegate>
@property (weak, nonatomic) IBOutlet TYTabbarView *tabbarView;

@end

@implementation TYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *images = @[@"tabbar-feed", @"tabbar-message", @"tabbar-record"];
    NSArray *selectedImages = @[@"tabbar-feed-selected",  @"tabbar-message-selected", @"tabbar-record-selected"];
    NSArray *titles = @[@"相机", @"记笔记", @"搜索"];
    for (int idx = 0; idx < 3; idx++) {
        [self.tabbarView addTabbarButtonWithTitle:titles[idx] image:[UIImage imageNamed:images[idx]] selectedImage:[UIImage imageNamed:selectedImages[idx]] badgeVaule:0];
    }
    [self setupSwipeGesture];
}

- (void)setupSwipeGesture {
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backHomeVC)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGesture];
}

- (void)backHomeVC {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)pressedRecorderNoteBtn:(UIButton *)sender {
    TYWirteNoteViewController *VC = [[TYViewControllerLoader noteStoryboard] instantiateInitialViewController];
    [self presentViewController:VC animated:YES completion:^{
    }];
}

- (IBAction)pressedRecorderVideoBtn:(UIButton *)sender {
    UIViewController *VC = [[TYViewControllerLoader videoStoryboard] instantiateInitialViewController];
    [TYViewControllerHelp shareHelp].viewController = self.navigationController;
    [self presentViewController:VC animated:YES completion:^{
    }];
}

- (IBAction)pressedLookUpNoteBtn:(UIButton *)sender {
    TYCheckNoteViewController *VC = [TYViewControllerLoader checkNoteViewController];
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)pressedDrawBtn:(UIButton *)sender {
    UIViewController *VC = [[TYViewControllerLoader drawStoryboard] instantiateInitialViewController];
    [self presentViewController:VC animated:YES completion:^{
        
    }];
}

- (IBAction)pressedRecorderAudioBtn:(UIButton *)sender {
    TYAudioViewController *VC = [TYViewControllerLoader audioViewController];
    [self.navigationController pushViewController:VC animated:YES];
}

/**
 *  tabbar的代理方法
 */
- (void)tabbarView:(TYTabbarView *)tabbar fromBtnIndex:(NSUInteger)fromIndex toBtnIndex:(NSUInteger)toIndex {
    
#warning to do
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

@end
