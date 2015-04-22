//
//  RSVideoPreviewViewController.m
//  FITogether
//
//  Created by taoYe on 15/3/5.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import "RSVideoPreviewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TYDebugLog.h"
#import "RSVideoTagViewController.h"
#import "RSProgressHUD.h"
#import "RSPlayerView.h"

static NSString *RSPhotoGroupName = @"RSPhoto";
static NSString *RSVideoGroupName = @"RSVideo";

@interface RSVideoPreviewViewController ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (weak, nonatomic) IBOutlet RSPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *saveToLibraryBtn;
@property (weak, nonatomic) IBOutlet UIButton *addTextBtn;

@end

@interface _RyxAssetsManager : NSObject
+ (void)saveAssets:(NSArray *)assets toGroupNamed:(NSString *)name fromLibrary:(ALAssetsLibrary *)assetsLibrary action:(void (^)(AVURLAsset *asset, NSError *error))handler;
@end

@implementation _RyxAssetsManager

+ (void)saveAssets:(NSArray *)assets toGroupNamed:(NSString *)name fromLibrary:(ALAssetsLibrary *)assetsLibrary action:(void (^)(AVURLAsset *asset, NSError *error))handler {
    void(^block)(ALAssetsGroup *group) = ^(ALAssetsGroup *group) {
        for (AVURLAsset *asset in assets) {
            [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:[asset URL] completionBlock:^(NSURL *assetURL, NSError *error) {
                [TYDebugLog debug:@"保存成功"];
                if (assetURL) {
                    [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *alAsset) {
                        [group addAsset:alAsset];
                        handler(asset, error);
                    } failureBlock:^(NSError *error) {
                        handler(asset, error);
                    }];
                } else {
                    handler(asset, error);
                }
            }];
        }
    };
    __weak typeof(assetsLibrary) weakLibrary = assetsLibrary;
    [assetsLibrary addAssetsGroupAlbumWithName:name resultBlock:^(ALAssetsGroup *group) {
        if (group) {
            // do it
            block(group);
        } else if (group == nil) {
            // already create a group, enumerate groups to find it
            [weakLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:name]) {
                    block(group);
                    *stop = YES;
                }
            } failureBlock:^(NSError *error) {
                [TYDebugLog errorFormat:@"unable to find group with error %@", error];
                handler(nil, error);
            }];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Error: Adding on Folder");
        handler(nil, error);
    }];
}

@end

@implementation RSVideoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    [_playerView setAsset:_asset];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    _playerView.frame = _playerView.frame;
    [_playerView play];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_playerView pause];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    CGFloat centerY = ([UIScreen mainScreen].bounds.size.height - CGRectGetMaxY(_playerView.frame)) / 2 + CGRectGetMaxY(_playerView.frame);
//    CGFloat centerX = [UIScreen mainScreen].bounds.size.width / 4;
//    _saveToLibraryBtn.center = CGPointMake(centerX, centerY);
//    _addTextBtn.center = CGPointMake(centerX * 3, centerY);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)saveVideoToAlbum:(UIButton *)sender {
    sender.enabled = NO;
    [_RyxAssetsManager saveAssets:@[_asset] toGroupNamed:RSPhotoGroupName fromLibrary:_assetsLibrary action:^(AVURLAsset *asset, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [RSProgressHUD showErrorWithStatus:[error localizedDescription]];
            });
        } else {
            [RSProgressHUD showSuccessWithStatus:@"保存成功"];
        }
    }];
}

- (IBAction)addTextAndPush:(UIButton *)sender {
    [self performSegueWithIdentifier:@"segueForVideoEditTag" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueForVideoEditTag"]) {
        RSVideoTagViewController *videoTagVC = [segue destinationViewController];
        videoTagVC.asset = _asset;
    }
}

- (IBAction)didPressedCancelBtn:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
