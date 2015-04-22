//
//  RSTrackViewController.m
//  FITogether
//
//  Created by closure on 12/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RSTrackViewController.h"
#import "TYRoundImageView.h"

NSString * RSTrackViewControllerDidPostPhotoNotification = @"RSTrackViewControllerDidPostPhotoNotification";
NSString * RSTrackViewControllerDidCancelPostNotification = @"RSTrackViewControllerDidCancelPostNotification";

@interface RSTrackViewController ()

@end

@implementation RSTrackViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSelectedState];
}

- (void)setupSelectedState {
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[TYRoundImageView class]]) {
            TYRoundImageView *roundImageView = (TYRoundImageView *)subView;
            roundImageView.clickEnable = YES;
            for (NSString *title in _selectedTags) {
                if ([title isEqualToString:roundImageView.title]) {
                    roundImageView.selected = YES;
                    break;
                }
            }
            //roundImageView.noRound = YES;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToTrackViewController:(UIStoryboardSegue *)sender {
//    if ([[sender sourceViewController] isKindOfClass:[RSTrackPostTableViewController class]]) {
//        [self dismissViewControllerAnimated:YES completion:^{
//            
//        }];
//    }
}

- (IBAction)cancelPassed {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"segueForTrackPostTableViewController"]) {
//        RSTrackPostTableViewController *trackPostVC = segue.destinationViewController;
//        
//        NSMutableArray *selectedTags = [NSMutableArray array];
//        for (UIView *subView in self.view.subviews) {
//            if ([subView isKindOfClass:[TYRoundImageView class]]) {
//                TYRoundImageView *roundImageView = (TYRoundImageView *)subView;
//                if (roundImageView.isSelected) {
//                    [selectedTags addObject:roundImageView.title];
//                }
//            }
//        }
//        trackPostVC.selectedTags = selectedTags;
//    }
}

@end
