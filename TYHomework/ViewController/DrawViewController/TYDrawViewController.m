//
//  TYDrawViewController.m
//  TYHomework
//
//  Created by taoYe on 15/3/17.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYDrawViewController.h"
#import "TYDrawView.h"
#import "TYWriteHelp.h"
#import "TYViewControllerLoader.h"

@interface TYDrawViewController ()
@property (weak, nonatomic) IBOutlet TYDrawView *drawView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@end

@implementation TYDrawViewController


- (IBAction)changeColor:(UISlider *)sender {
    
    [self.drawView changeColorWithRed:sender.value green:sender.value blue:sender.value];
}
- (IBAction)pressedNextButton:(UIBarButtonItem *)sender {
    TYWriteHelp *help = [TYWriteHelp shareWriteHelp];
    UIImage *image = [self.drawView getDrawImage];
    help.drawImage = image;
    if (help.isStartWrite) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [RSProgressHUD dismiss];
        }];
    } else {
        [self presentViewController:[[TYViewControllerLoader noteStoryboard] instantiateInitialViewController] animated:YES completion:^{
            [RSProgressHUD dismiss];
        }];
    }
}
- (IBAction)pressedBackButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clear {
    [self.drawView clear];
}

- (IBAction)back {
    [self.drawView back];
}

- (IBAction)save:(UIButton *)button {
    [self.drawView save];
    button.enabled = NO;
    [RSProgressHUD showSuccessWithStatus:@"保存成功"];
}
@end
