//
//  TYDrawViewController.m
//  TYHomework
//
//  Created by taoYe on 15/3/17.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYDrawViewController.h"
#import "TYDrawView.h"

@interface TYDrawViewController ()
@property (weak, nonatomic) IBOutlet TYDrawView *drawView;

@end

@implementation TYDrawViewController


- (IBAction)changeColor:(UISlider *)sender {
    
    [self.drawView changeColorWithRed:sender.value green:sender.value blue:sender.value];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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

- (IBAction)save {
    [self.drawView save];
}
@end
