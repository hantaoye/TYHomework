//
//  TYAudioViewController.m
//  TYHomework
//
//  Created by taoYe on 15/4/22.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYAudioViewController.h"
#import "TYAudioTool.h"

static NSString *__name = @"aaa.caf";

@interface TYAudioViewController ()

@end

@implementation TYAudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pressedBtn:(UIButton *)sender {
    [TYAudioTool startRecorder:__name];
}

- (IBAction)stopBtn:(UIButton *)sender {
    [TYAudioTool stopRecorder];
}

- (IBAction)play:(UIButton *)sender {
    [TYAudioTool playRecorder:__name];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
