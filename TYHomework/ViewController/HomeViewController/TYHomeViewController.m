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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (IBAction)pressedRecorderNoteBtn:(UIButton *)sender {
}

- (IBAction)pressedRecorderVideoBtn:(UIButton *)sender {
}

- (IBAction)pressedLookUpNoteBtn:(UIButton *)sender {
}

- (IBAction)pressedDrawBtn:(UIButton *)sender {
}

- (IBAction)pressedRecorderAudioBtn:(UIButton *)sender {
}

/**
 *  tabbar的代理方法
 */
- (void)tabbarView:(TYTabbarView *)tabbar fromBtnIndex:(NSUInteger)fromIndex toBtnIndex:(NSUInteger)toIndex {
#warning to do
}


@end
