//
//  EditVideoViewController.m
//  RSVideoDemo
//
//  Created by closure on 3/4/15.
//  Copyright (c) 2015 RenYuXian. All rights reserved.
//

#define RSVideoMinTime 5.0
#define RSVideoMaxTime 15.0

#import "RSVideoEditViewController.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import "SAVideoRangeSlider.h"
#import "RSProgressHUD.h"
#import "SBCaptureToolKit.h"
#import "RSPlayerView.h"
#import "RSVideoPreviewViewController.h"
#import "TYDebugLog.h"
#import "RSVideoAssetCompressor.h"
#import "UIImage+TY.h"
#import "RSMultiImageEditView.h"
#import "RSVideo.h"
//#import "RSWebServiceAccess.h"
#import "IGCropView.h"

@interface RSVideoEditViewController () <SAVideoRangeSliderDelegate, RSPlayerViewDelegate, RSImageEditViewDelegate>
@property (nonatomic, strong) SAVideoRangeSlider *rangeSlider;
@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat stopTime;
@property (nonatomic, assign) CGFloat duration;

@property (weak, nonatomic) IBOutlet IGCropView *preview;

@property (nonatomic, strong) AVURLAsset *currentAsset;

@property (strong, nonatomic) RSPlayerView *player;

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) UIView *progressView;

@property (strong, nonatomic) RSPlayerStateView *videoStateView;
@end

@implementation RSVideoEditViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    _videoStateView.center = _preview.center;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_player pause];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_preview setContentInset:UIEdgeInsetsZero];
    [_preview setAlAsset:_alasset];
    [_preview setClipsToBounds:YES];
    _player = [_preview videoPlayer];
    [_player setPlayerViewDelegate:self];
    [self setStartTime:_startTime];
    [_player pause];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentAsset = [AVURLAsset assetWithURL:_asset.URL];
    _queue = dispatch_queue_create("com.RS-inc.videoService.editQueue", NULL);
    self.view.backgroundColor = [UIColor blackColor];
    [self setupData];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    titleView.text = @"裁剪";
    titleView.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleView;
    
    [self.view addSubview:self.videoStateView];
}

- (void)dealloc {
    NSLog(@"%@ dealloc", self);
}

- (RSPlayerStateView *)videoStateView {
    if (!_videoStateView) {
        CGRect bounds = [[UIScreen mainScreen] bounds];
        _videoStateView = [[RSPlayerStateView alloc] initWithFrame:CGRectMake(0, 44, bounds.size.width, bounds.size.height)];
    }
    return _videoStateView;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}

- (void)tapWithEditView:(RSImageEditView *)sender {
    NSLog(@"%@", sender);
}

- (IBAction)nextButtonPressed:(UIBarButtonItem *)sender {
//    CGFloat duration = CMTimeGetSeconds([_asset duration]);
//    if (_startTime == 0 && _duration - duration >= -0.1) {
//        [self performSegueWithIdentifier:@"segueForVideoPreview" sender:self];
//    } else {
    [sender setEnabled:NO];
        _outputPath = [SBCaptureToolKit getVideoCompressedFilePathString];
        [RSProgressHUD showWithStatus:@"生成中,请稍等" maskType:RSProgressHUDMaskTypeGradient];
        [self exportAction:^(BOOL finished, NSError *error) {
            [sender setEnabled:YES];
            if (finished && error == nil) {
                [[NSFileManager defaultManager] removeItemAtURL:[_currentAsset URL] error:nil];
                _currentAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:_outputPath] options:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RSProgressHUD dismiss];
                    [self performSegueWithIdentifier:@"segueForVideoPreview" sender:self];
                });
            }
        }];
//    }
}

- (void)setStartTime:(CGFloat)startTime {
    _startTime = startTime;
    [_player setPlayingTime:startTime];
}

- (void)setupData {
    if (_asset) {
        [_rangeSlider removeFromSuperview];
        CGRect rect = CGRectMake(0 - BG_VIEW_BORDERS_SIZE, self.view.frame.size.width + 44 - offset , self.view.frame.size.width + 2 * BG_VIEW_BORDERS_SIZE, 80);
        _rangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:rect videoURL:[_asset URL] minGap:RSVideoMinTime maxGap:RSVideoMaxTime];
        
        [[_rangeSlider bubleText] setFont:[UIFont systemFontOfSize:12]];
        [_rangeSlider setPopoverBubbleSize:120 height:60];
        _duration = CMTimeGetSeconds([_asset duration]);
        
//        _player = [[RSPlayerView alloc] initWithAVURLAsset:_asset];
//        _player.playerViewDelegate = self;
        
        [self setStartTime:0];
        _stopTime = _startTime + _duration;
        
        [_rangeSlider setDelegate:self];
        [[self view] addSubview:_rangeSlider];
        
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(-2, _rangeSlider.bgView.frame.origin.y, 2, _rangeSlider.bgView.frame.size.height)];
        [_rangeSlider addSubview:_progressView];
        _progressView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)change {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)exportAction:(void (^)(BOOL finished, NSError *error))block {
    AVURLAsset *anAsset = _asset;
    [RSProgressHUD show];
    CMTime start = CMTimeMakeWithSeconds(self.startTime, anAsset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(_duration, anAsset.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    CMTimeRangeShow(range);
    
    CGRect croppedRect = [[self preview] visibleRectForCropArea];
    [RSVideoAssetCompressor editAVAsset:anAsset outputPath:self.outputPath timeRange:range croppedRect:croppedRect action:^(AVURLAsset *avAsset, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [TYDebugLog error:error];
                [RSProgressHUD showErrorWithStatus:[error localizedDescription]];
            });
            block(NO, error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [RSProgressHUD dismiss];
            });
            block(YES, error);
        }
    }];
}

//- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition {
//    [TYDebugLog debugFormat:@"leftPosition = %f, rightPosition == %f", leftPosition,rightPosition];
//    self.stopTime = rightPosition;
//    if (fabsf(leftPosition - self.startTime) > 0.2) {
//        self.startTime = leftPosition;
//        [_player setPlayingTime:leftPosition];
//    }
//}

- (void)videoRange:(SAVideoRangeSlider *)videoRange didScrollStateWithLeftPosition:(CGFloat)leftPosition {
    if (fabsf(leftPosition - self.startTime) > 0.2) {
        [self setStartTime:leftPosition];
        _stopTime = _startTime + _duration;
        _progressView.transform = CGAffineTransformIdentity;
    }
}

- (void)videoRange:(SAVideoRangeSlider *)videoRange sliderValueDidChangeWithRightPosition:(CGFloat)rightPosition {
    _duration = rightPosition;
    _stopTime = _startTime + _duration;
}

- (void)playingTick:(RSPlayerView *)playerView progress:(CGFloat)progress {
    _progressView.transform = CGAffineTransformMakeTranslation( (CMTimeGetSeconds(playerView.currentTime) - _startTime) / _duration *  _rangeSlider.frame.size.width * _duration / RSVideoMaxTime, 0);
    if (CMTimeGetSeconds(playerView.currentTime) >= _stopTime) {
        [playerView setPlayingTime:_startTime];
        _progressView.transform = CGAffineTransformIdentity;
    }
}

- (void)playerWillPlay:(RSPlayerView *)playerView {
    [_videoStateView setHidden:YES];
}

- (void)playerWillPause:(RSPlayerView *)playerView {
    [_videoStateView setHidden:NO];
}


- (IBAction)didPressedCancelBtn:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [_player pause];
    if ([[segue identifier] isEqualToString:@"segueForVideoPreview"]) {
        RSVideoPreviewViewController *vc = (RSVideoPreviewViewController *)[segue destinationViewController];
        [vc setAsset:_currentAsset];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
