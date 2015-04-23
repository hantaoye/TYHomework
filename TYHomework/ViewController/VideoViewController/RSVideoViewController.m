//
//  ViewController.m
//  RSVideoDemo
//
//  Created by taoYe on 15/2/4.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "RSVideoViewController.h"
#import "UIImage+Resize.h"
#import "SBCaptureToolKit.h"
#import "TYDebugLog.h"
#import "UIImage+TY.h"
#import "RSVideoEditViewController.h"
//#import "RSTrackPostTableViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import "RSProgressHUD.h"
#import "RSVideoProgressBar.h"
#import "DeleteButton.h"
#import "TYCustomBtn.h"
#import <SCRecorder/SCRecorder.h>
#import "SCRecorder+SCRecorderExtension.h"
#import <AVFoundation/AVFoundation.h>
#import "RSVideoPreviewViewController.h"
#import "RSTrackEditPhotoViewController.h"
#import "RSVideoAssetCompressor.h"
#import "RSNavigationController.h"
#import "RSDelaySegue.h"
#import "TYBaseNavigationController.h"
#import "TYWriteHelp.h"
#import "TYViewControllerHelp.h"


#define RSiPhone4S ([UIScreen mainScreen].bounds.size.height <= 480)
#define RSScreenWidth [UIScreen mainScreen].bounds.size.width
#define RSScreenHeight [UIScreen mainScreen].bounds.size.height
#define RSLongPressedTime 0.0
#define RSRecordMaxTime 15.0
#define RSNavBarHeight 44

@implementation ALAsset (Export)

- (BOOL)exportDataToURL:(NSURL*)fileURL error:(NSError**)error {
    ALAssetRepresentation *rep = [self defaultRepresentation];
    int64_t size = [rep size];
    UInt8 *buf = (UInt8 *)malloc(sizeof(UInt8) * size);
    NSData *videoData = nil;
    if (buf) {
        [rep getBytes:buf fromOffset:0 length:size error:error];
        if (error && (*error != nil)) {
            free(buf);
            buf = nil;
            return nil;
        }
        videoData = [[NSData alloc] initWithBytesNoCopy:buf length:size freeWhenDone:YES];
    }
    return [videoData writeToURL:fileURL atomically:YES];
}

@end

@interface RSVideoViewController () <CTAssetsPickerControllerDelegate, UIActionSheetDelegate, SCRecorderDelegate> {
    UIImage *_recorderPhoto;
    BOOL _isRecorderVideo;
    struct {
        BOOL _isPBShinning;
    }_flag;
}

@property (strong, nonatomic) SCRecorder *recorder;
@property (strong, nonatomic) RSVideoProgressBar *progressBar;

@property (strong, nonatomic) NSMutableArray *videoFileDataArray;

@property (strong, nonatomic) DeleteButton *deleteButton;
@property (strong, nonatomic) UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;

@property (nonatomic, weak) UIView *backView;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftGesture;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightGesture;

@property (nonatomic, weak) UIView *preview;
@property (nonatomic, weak) UIView *operateView;
@property (nonatomic, weak) UIButton *recorderBtn;
@property (nonatomic, weak) UIImageView *pointImageView;

@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, weak) UIButton *videoBtn;
@property (nonatomic, weak) UIButton *photoBtn;

@property (nonatomic, assign) CGPoint previewCenter;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGFloat timerDuration;

@property (nonatomic, weak) UILabel *promptLabel;

@property (nonatomic, assign, getter=isStartRecorder) BOOL startRecorder;

@property (nonatomic, assign, getter=isDidMakePhoto) BOOL didMakePhoto;

@property (nonatomic, strong) NSURL *videoFileURL;

@property (nonatomic, weak) UIImageView *focusRectView;

@property (nonatomic, weak) UIButton *libraryBtn;
@property (nonatomic, strong) ALAssetsLibrary *library;

@property (nonatomic, strong) NSArray *assets; // AVURLAssets;
@property (nonatomic, strong) NSArray *alassets;
@property (assign, nonatomic) BOOL isProcessingData;

@end

@implementation RSVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _library = [[ALAssetsLibrary alloc] init];
    
    [SBCaptureToolKit deleteFilePath];
    [SBCaptureToolKit createVideoFolderIfNotExist];
    [self setupViews];
//    _videoFileURL = [_recorder currentFileURL];

    [self setStartRecorderState:NO];
    
    if (RSiPhone4S) {
        _backView.transform = CGAffineTransformMakeTranslation(0, -RSNavBarHeight);
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
    }
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _didMakePhoto = NO;
    [self unfreezePreview];
    [[[_recorder previewLayer] connection] setEnabled:YES];
    [_recorder startRunning];
    SCRecordSession *session = [_recorder session];
    CGFloat totalDur = CMTimeGetSeconds([session duration]);
    _okButton.enabled = (totalDur >= MIN_VIDEO_DUR);
    if (NO == _flag._isPBShinning) {
        [_progressBar stopShining];
    }
    if (RSiPhone4S) {
        self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[[_recorder previewLayer] connection] setEnabled:NO];
    _flag._isPBShinning = [_progressBar isShining];
    [_progressBar stopShining];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    if (_recorder.audioConfiguration.enabled) {
        [self setAudioWithEnable:NO];
    }
    [_recorder pause];
    SCRecordSession *session = [_recorder session];
    [session removeAllSegments:YES];
//    [[_recorder captureSession] removeInput:[];
//    [_recorder deleteAllVideo];
}

#pragma mark --
#pragma mark 初始化View
- (void)setupViews {
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupFixedView];

    [self setupProgressBar];
    [self setupRecorder];
    [self setupSelectView];
    [self setupOperateView];

    [self setupPreviewSubView];
}

- (void)setupFixedView {
    UIView *backView = [[UIView alloc] init];
    [self.view addSubview:backView];
    _backView = backView;
    _leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeGesture)];
    _leftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [_backView addGestureRecognizer:_leftGesture];
    _rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeGseture)];
    _rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [_backView addGestureRecognizer:_rightGesture];
    
    UIView *preview = [[UIView alloc] initWithFrame:CGRectMake(0, RSNavBarHeight, RSScreenWidth, RSScreenWidth)];
    [preview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFocusRect:)]];
    preview.clipsToBounds = YES;
    [_backView addSubview:preview];
    _preview = preview;
    
    //前后摄像头转换
//    [_switchButton setImage:[UIImage imageNamed:@"record_lensflip_normal.png"] forState:UIControlStateNormal];
//    [_switchButton setImage:[UIImage imageNamed:@"record_lensflip_disable.png"] forState:UIControlStateDisabled];
//    [_switchButton setImage:[UIImage imageNamed:@"record_lensflip_highlighted.png"] forState:UIControlStateSelected];
//    [_switchButton setImage:[UIImage imageNamed:@"record_lensflip_highlighted.png"] forState:UIControlStateHighlighted];
}

- (void)setupProgressBar {
    self.progressBar = [RSVideoProgressBar getInstance];
    [SBCaptureToolKit setView:_progressBar toOriginY:CGRectGetMaxY(_preview.frame)];
    [_backView addSubview:self.progressBar];
    [self.progressBar setIntervalWithX:RSScreenWidth * (MIN_VIDEO_DUR / MAX_VIDEO_DUR)];
    [_progressBar startShining];
}

- (void)setupOperateView {
    CGFloat operationH = 80;
    
    CGFloat operationY = CGRectGetMaxY(_backView.frame) - (RSiPhone4S ? RSNavBarHeight : 0);
    operationY += (RSScreenHeight - operationY - operationH) / 2;
    
    UIView *operateView = [[UIView alloc] initWithFrame:CGRectMake(0, operationY, RSScreenWidth, operationH)];
    [self.view insertSubview:operateView atIndex:1];
    _operateView = operateView;
    
    UIButton *recorderBtn = [[UIButton alloc] init];
    CGFloat recorderBtnX = (RSScreenWidth - operationH) / 2;
//    recorderBtn.backgroundColor = [UIColor whiteColor];
    [recorderBtn setBackgroundImage:[UIImage imageNamed:@"video-operation"] forState:UIControlStateNormal];
    [recorderBtn setBackgroundImage:[UIImage imageNamed:@"video-operation-heightLight"] forState:UIControlStateHighlighted];
//    [recorderBtn setTitle:@"拍照" forState:UIControlStateNormal];
//    [recorderBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    recorderBtn.frame = CGRectMake(recorderBtnX, 0, operationH, operationH);
    recorderBtn.userInteractionEnabled = NO;
    [_operateView addSubview:recorderBtn];
    _recorderBtn = recorderBtn;
    [self setupDeleteBtnAndOkBtn];
    
    TYCustomBtn *libraryBtn = [[TYCustomBtn alloc] initWithFrame:_okButton.frame];
    [_operateView addSubview:libraryBtn];
    [libraryBtn setTitle:@"相册选取" forState:UIControlStateNormal];
    [libraryBtn setImage:[UIImage imageNamed:@"video-library-heightLight"] forState:UIControlStateHighlighted];
    [libraryBtn setImage:[UIImage imageNamed:@"video-library"] forState:UIControlStateNormal];
    [libraryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [libraryBtn addTarget:self action:@selector(persentLibrary) forControlEvents:UIControlEventTouchUpInside];
    [libraryBtn setTitleEdgeInsets:UIEdgeInsetsMake(20, 0, 0, 0)];
    libraryBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    _libraryBtn = libraryBtn;

}

- (void)setupDeleteBtnAndOkBtn {
    if (_isProcessingData) {
        return;
    }
    CGFloat height = _operateView.frame.size.height - 20;
    CGFloat width = height;
    self.deleteButton = [[DeleteButton alloc] initWithFrame:CGRectMake(20, 0, width, height)];
    [_deleteButton setButtonStyle:DeleteButtonStyleDisable];
    [_deleteButton addTarget:self action:@selector(pressDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    [self.operateView addSubview:_deleteButton];
    
    CGFloat okButtonX = RSScreenWidth - width - _deleteButton.frame.origin.x;
    self.okButton = [[UIButton alloc] initWithFrame:CGRectMake(okButtonX, 0, width, height)];
    _okButton.enabled = NO;
    
    [_okButton setBackgroundImage:[UIImage imageNamed:@"video-cancel-bg"] forState:UIControlStateNormal];
    [_okButton setBackgroundImage:[UIImage imageNamed:@"video-cancel-bg-heightLight"] forState:UIControlStateHighlighted];
    
    [_okButton setImage:[UIImage imageNamed:@"video-OK"] forState:UIControlStateNormal];
    [_okButton setImage:[UIImage imageNamed:@"video-OK-heightLight"] forState:UIControlStateHighlighted];
    
    [_okButton addTarget:self action:@selector(okButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.operateView addSubview:_okButton];
    CGPoint center = _recorderBtn.center;
    [_okButton setCenter:CGPointMake(_okButton.center.x, center.y)];
    [_deleteButton setCenter:CGPointMake(_deleteButton.center.x, center.y)];
}

- (void)pressDeleteButton {
    if (_deleteButton.style == DeleteButtonStyleNormal) {//第一次按下删除按钮
        [_progressBar setLastProgressToStyle:ProgressBarProgressStyleDelete];
        [_deleteButton setButtonStyle:DeleteButtonStyleDelete];
    } else if (_deleteButton.style == DeleteButtonStyleDelete) {//第二次按下删除按钮
        [self deleteLastVideo];
        [_progressBar deleteLastProgress];
        if ([[[_recorder session] segments] count]) {
            [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
        } else {
            [_deleteButton setButtonStyle:DeleteButtonStyleDisable];
            [self setStartRecorderState:NO];
        }
    }
}

- (void)okButtonPressed {
    if (_isProcessingData) {
        return;
    }
    _isProcessingData = YES;
    [RSProgressHUD showWithStatus:@"生成中" maskType:RSProgressHUDMaskTypeGradient];
    [_recorder pause:^{
        SCRecordSession *session = [_recorder session];
        [session mergeSegmentsUsingPreset:AVAssetExportPresetMediumQuality completionHandler:^(NSURL *outputURL, NSError *error) {
            self.videoFileURL = outputURL;
            dispatch_async(dispatch_get_main_queue(), ^{
                _okButton.enabled = NO;
                _isProcessingData = NO;
                [self performSegueWithIdentifier:@"segueForVideoPreview" sender:self];
            });
        }];
    }];
//    [_recorder mergeVideoFiles];
}

//删除最后一段视频
- (void)deleteLastVideo {
    [_recorder pause];
    SCRecordSession *session = [_recorder session];
    [[_recorder session] removeLastSegment];
    CGFloat totalDur = CMTimeGetSeconds([session duration]);
    dispatch_async(dispatch_get_main_queue(), ^{
        _okButton.enabled = (totalDur >= MIN_VIDEO_DUR);
    });
}

- (void)setupRecorder {
//    _recorder = [[SBVideoRecorder alloc] init];
//    _recorder.previewLayer.frame = _preview.bounds;
//    [_preview.layer addSublayer:_recorder.previewLayer];
//    _previewCenter = _preview.center;
//    [_recorder setDelegate:self];
//    _switchButton.enabled = [_recorder isFrontCameraSupported];
    _recorder = [SCRecorder recorder];
    [_recorder continuousFocusAtPoint:self.view.center];
    [_recorder setFastRecordMethodEnabled:YES];
    _recorder.previewView = _preview;
    _recorder.delegate = self;
    _switchButton.enabled = [_recorder isFrontCameraSupported];
//    _recorder.
    [_recorder setCaptureSessionPreset:AVAssetExportPresetMediumQuality];
    SCRecordSession *session = [SCRecordSession recordSession];
    [_recorder setSession:session];
    [self setPhoto];
    [self setAudioWithEnable:YES];
    if (![_recorder isPrepared]) {
        NSError *error = nil;
        [_recorder prepare:&error];
    }
    [_recorder startRunning];
//    [_recorder openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
//        [_recorder startRunningSession];
//        
//    }];
}

- (void)setupPreviewSubView {
    //focus rect view
    UIImageView *focusRectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    focusRectView.image = [UIImage imageNamed:@"touch_focus_not"];
    focusRectView.alpha = 0.0;
    [_preview addSubview:focusRectView];
    _focusRectView = focusRectView;
    
}

- (void)showFocusRect:(UITapGestureRecognizer *)gesture {
    CGPoint touchPoint = [gesture locationInView:_preview];
    [_recorder autoFocusAtPoint:touchPoint];
    [self showFocusRectAtPoint:touchPoint];
}

- (void)showFocusRectAtPoint:(CGPoint)point {
    _focusRectView.alpha = 1.0f;
    _focusRectView.center = point;
    _focusRectView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    [UIView animateWithDuration:0.2f animations:^{
        _focusRectView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.values = @[@0.5f, @1.0f, @0.5f, @1.0f, @0.5f, @1.0f];
        animation.duration = 0.5f;
        [_focusRectView.layer addAnimation:animation forKey:@"opacity"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3f animations:^{
                _focusRectView.alpha = 0;
            }];
        });
    }];
}

- (void)persentLibrary {
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    [picker setAssetsLibrary:_library];
    if (!_isRecorderVideo) {
        picker.assetsFilter              = [ALAssetsFilter allPhotos];
    } else {
        picker.assetsFilter              = [ALAssetsFilter allVideos];
    }
    picker.showsCancelButton         = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
    picker.delegate                  = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)setupSelectView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video-select"]];
    imageView.frame = CGRectMake((RSScreenWidth - 5) / 2, CGRectGetMaxY(_progressBar.frame) + 18, 5, 5);
    [_backView addSubview:imageView];
    _pointImageView = imageView;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(RSScreenWidth / 5, CGRectGetMaxY(imageView.frame) + 8, RSScreenWidth / 5 * 2, 17)];
    view.userInteractionEnabled = YES;
    [_backView addSubview:view];
    _backView.frame = CGRectMake(0, 0, RSScreenWidth, CGRectGetMaxY(view.frame));
    
    UIButton *photoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width / 2, view.bounds.size.height)];
    [photoBtn setTitle:@"照片" forState:UIControlStateNormal];
    [photoBtn setTitleColor:BAR_ORANGE_COLOR forState:UIControlStateNormal];
    photoBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [photoBtn addTarget:self action:@selector(chooseCamera:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:photoBtn];
    
    UIButton *videoBtn =[[UIButton alloc] initWithFrame:CGRectMake(view.bounds.size.width / 2, 0, view.bounds.size.width / 2, view.bounds.size.height)];
    [videoBtn setTitle:@"视频" forState:UIControlStateNormal];
    [videoBtn addTarget:self action:@selector(chooseCamera:) forControlEvents:UIControlEventTouchUpInside];
    videoBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:videoBtn];
    _selectView = view;
    [_selectView setTransform:CGAffineTransformMakeTranslation(_selectView.bounds.size.width / 2, 0)];

    _videoBtn = videoBtn;
    _photoBtn = photoBtn;
}

- (IBAction)quitRecoderVC {
    if ([[[_recorder session] segments] count]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"提醒" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"放弃" otherButtonTitles:nil, nil];
        [actionSheet showInView:self.view];
    } else {
        [self dropTheVideo];
    }
//    if ([_recorder getVideoCount] > 0) {
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"提醒" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"放弃" otherButtonTitles:nil, nil];
//        [actionSheet showInView:self.view];
//    } else {
//        [self dropTheVideo];
//    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self dropTheVideo];
    }
}

//放弃本次视频，并且关闭页面
- (void)dropTheVideo {
//    [_recorder deleteAllVideo];
    [_recorder pause:^{
        [[_recorder session] removeAllSegments:YES];
        [SBCaptureToolKit deleteFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

- (void)chooseCamera:(UIButton *)btn {
    if ([btn.currentTitle isEqualToString:@"视频"] && !_isRecorderVideo) {
        [self changeCamera:YES];
    } else if (![btn.currentTitle isEqualToString:@"视频"] && _isRecorderVideo) {
        [self changeCamera:NO];
    }
}

- (void)rightSwipeGseture {
    if (_isRecorderVideo) {
        [self changeCamera:NO];
    }
}

- (void)leftSwipeGesture {
    if (!_isRecorderVideo) {
        [self changeCamera:YES];
    }
}

- (void)changeCamera:(BOOL)isVideo {
    [UIView animateWithDuration:0.15 animations:^{
        _preview.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            if (isVideo) {
                [self setVideo];
                [_videoBtn setTitleColor:BAR_ORANGE_COLOR forState:UIControlStateNormal];
                [_photoBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [_selectView setTransform:CGAffineTransformIdentity];
            } else {
                [self setPhoto];
                [_photoBtn setTitleColor:BAR_ORANGE_COLOR forState:UIControlStateNormal];
                [_videoBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [_selectView setTransform:CGAffineTransformMakeTranslation(_selectView.bounds.size.width / 2, 0)];
            }
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.15 animations:^{
                    _preview.alpha = 1.0;
                }];
            });
        }];
    }];
}

- (void)setAudioWithEnable:(BOOL)enable {
       // Get the audio configuration object
    SCAudioConfiguration *audio = _recorder.audioConfiguration;
    
    // Whether the audio should be enabled or not
    audio.enabled = enable;
    // the bitrate of the audio output
    audio.bitrate = 44100; // 128kbit/s
    // Number of audio output channels
    audio.channelsCount = 1; // Mono output
    // The sample rate of the audio output
    audio.sampleRate = 0; // Use same input
    // The format of the audio output
    audio.format = kAudioFormatMPEG4AAC; // AAC
    audio.shouldIgnore = !enable;
    
}

- (void)setPhoto {
    _recorder.captureSessionPreset = AVCaptureSessionPresetPhoto;
    
    _isRecorderVideo = NO;
    _recorder.maxRecordDuration = CMTimeMakeWithSeconds(MAX_VIDEO_DUR, 600);
    
    [_recorder beginConfiguration];
    
    [self setStartRecorderState:NO];
    
    _progressBar.alpha = 0.0;

    SCPhotoConfiguration *photo = _recorder.photoConfiguration;
    photo.options = @{
                                        AVVideoCodecKey : AVVideoCodecJPEG,
                                                                  AVVideoWidthKey: @(320),
                                                                  AVVideoHeightKey: @(320),
                                                                  AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill                                                                };
    photo.enabled = YES;
    [_recorder commitConfiguration];
}

- (void)setVideo {
    _recorder.captureSessionPreset = AVCaptureSessionPresetMedium;
    _recorder.session.fileType = AVFileTypeMPEG4;
    [_recorder beginConfiguration];
    // Get the video configuration object

    SCVideoConfiguration *video = _recorder.videoConfiguration;
    
    // Whether the video should be enabled or not
    video.enabled = YES;
    // The bitrate of the video video
    video.bitrate = 480000; // 2Mbit/s
    // Size of the video output
    video.size = CGSizeMake(320, 320);
    // Scaling if the output aspect ratio is different than the output one
    video.scalingMode = AVVideoScalingModeResizeAspectFill;
    // The timescale ratio to use. Higher than 1 makes the time go slower, between 0 and 1 makes the time go faster
    video.timeScale = 1;
    // Whether the output video size should be infered so it creates a square video
    video.sizeAsSquare = YES;
    // The filter to apply to each output video buffer (this do not affect the presentation layer)
//    video.filterGroup = [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectInstant"]];
    
    
    _recorder.videoConfiguration.enabled = YES;
    _recorder.audioConfiguration.enabled = YES;
    _recorder.photoConfiguration.enabled = NO;
    
    [_recorder commitConfiguration];
    [_recorder startRunning];
    
//    [_recorderBtn setTitle:@"按住拍" forState:UIControlStateNormal];
//    [_libraryBtn setTitle:@"相册选取" forState:UIControlStateNormal];
    _progressBar.alpha = 1.0;
    _isRecorderVideo = YES;
}

- (void)freezePreview {
    if (_recorder.previewLayer)
        _recorder.previewLayer.connection.enabled = NO;
}

- (void)unfreezePreview {
    if (_recorder.previewLayer)
        _recorder.previewLayer.connection.enabled = YES;
}

- (IBAction)pressSwitchButton {
    _switchButton.selected = !_switchButton.selected;

    [UIView animateWithDuration:0.2 animations:^{
        _preview.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            [_recorder switchCaptureDevices];
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.2 animations:^{
                    _preview.alpha = 1.0;
                }];
            });
        }];
    }];

}

- (void)setStartRecorderState:(BOOL)isRecorder {
    _deleteButton.hidden = !isRecorder;
    _okButton.hidden = !isRecorder;
    _libraryBtn.hidden = isRecorder;
    _selectView.hidden = isRecorder;
    _pointImageView.hidden = isRecorder;
    if (isRecorder) {
        [_backView removeGestureRecognizer:_leftGesture];
        [_backView removeGestureRecognizer:_rightGesture];
    } else {
        [_backView addGestureRecognizer:_leftGesture];
        [_backView addGestureRecognizer:_rightGesture];
    }
}

#pragma mark --
#pragma mark recorder
//- (void)startRecorderVideo {
//    if (_timer) return;
////    _progressView.trackTintColor = [UIColor greenColor];
//    _promptLabel.text = @"上移取消";
//    _promptLabel.textColor = [UIColor greenColor];
////    [_progressView resetProgressView];
//    
//    _timerDuration = 0;
//    _cancleRecorder = NO;
//    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(recordingDuration) userInfo:nil repeats:YES];
//}
//
//- (void)recordingDuration {
//    if (!_startRecorder && _timerDuration > RSLongPressedTime) {
//        [_recorder startRecording];
////        [_progressView startProgressing];
////        _progressView.alpha = 1.0;
//        _promptLabel.alpha = 1.0;
//        _startRecorder = YES;
//    }
//    _timerDuration += _timer.timeInterval;
//    if (_timerDuration >= RSRecordMaxTime + RSLongPressedTime) {
//        [self selectRecoderState];
//    }
//}
//
//- (void)selectRecoderState {
//    [_timer invalidate];
//    _timer = nil;
//    if (_startRecorder) {
//        if (!_cancleRecorder && _timerDuration > RSLongPressedTime + 1) {
//            [_recorder stopCurrentVideoRecording];
//        } else {
//            [_recorder cancelRecording];
//            [TYDebugLog debug:@"时间太短， 或者取消了录制"];
//        }
////        [_progressView stopProgressing];
//        _promptLabel.alpha = 0;
////        _progressView.alpha = 0;
//        _startRecorder = NO;
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView.contentOffset.y >= 0) {
//        _preview.alpha = (_preview.bounds.size.height - scrollView.contentOffset.y) / _preview.bounds.size.height;
//        _topView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1 - (_preview.bounds.size.height - scrollView.contentOffset.y) / _preview.bounds.size.height];
//        
//    } else {
//        CGFloat scale = (RSScreenWidth - 2 * scrollView.contentOffset.y) / RSScreenWidth;
//        _preview.transform = CGAffineTransformMakeScale(scale, scale);
//    }
//}

#pragma mark SCRecorderDelegate

- (void)recorder:(SCRecorder *)recorder didBeginSegmentInSession:(SCRecordSession *)session error:(NSError *)error {
    NSLog(@"正在录制视频: %@", session);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressBar addProgressView];
        [_progressBar stopShining];
        [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
    });
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)session error:(NSError *)error {
    [_progressBar startShining];
    
    if (CMTimeGetSeconds([session duration]) >= MAX_VIDEO_DUR) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self okButtonPressed];
        });
    }
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)session {
    CGFloat videoDuration = CMTimeGetSeconds([session currentSegmentDuration]);
    CGFloat totalDur = CMTimeGetSeconds([session duration]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressBar setLastProgressToWidth:videoDuration / MAX_VIDEO_DUR * _progressBar.frame.size.width];
        _okButton.enabled = (totalDur >= MIN_VIDEO_DUR);
    });
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)session {
    _isProcessingData = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self okButtonPressed];
    });
}

#pragma mark push

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueForVideoPreview"]) {
        RSVideoPreviewViewController *vc = (RSVideoPreviewViewController *)[segue destinationViewController];
        vc.asset = [[AVURLAsset alloc] initWithURL:_videoFileURL options:nil];
    } else if ([segue.identifier isEqualToString:@"segueForVideoEdit"]) {
        RSVideoEditViewController *videoEditVC = segue.destinationViewController;
        if (_assets.count) {
            videoEditVC.asset = _assets[0];
            videoEditVC.alasset = _alassets[0];
        }
        _assets = nil;
        _alassets = nil;
    } else if ([segue.identifier isEqualToString:@"segueForEditPhoto"]) {
        RSClassHomeNavigationContorller *navigationVC = [segue destinationViewController];
        
        RSTrackEditPhotoViewController *editVC = [[navigationVC viewControllers] firstObject];
        [editVC setAssets:_assets];
        [editVC setDeleteAfterDone:_recorderPhoto != nil];
        _recorderPhoto = nil;
        _assets = nil;
    }
    [RSProgressHUD dismiss];
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
}

#pragma mark - Assets Picker Delegate

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group {
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    if (assets.count == 0) {
        return;
    }
    
    void (^code)() = ^{
        [picker dismissViewControllerAnimated:YES completion:^{
            if (_isRecorderVideo) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [RSProgressHUD showWithMaskType:RSProgressHUDMaskTypeClear];
                    [self performSegueWithIdentifier:@"segueForVideoEdit" sender:self];
                });
            } else {
                [self performPhotoEdit];
            }
        }];
    };
    
    if (_isRecorderVideo) {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[[assets[0] defaultRepresentation] url] options:nil];
        if (CMTimeGetSeconds([asset duration]) < MIN_VIDEO_DUR) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [RSProgressHUD showErrorWithStatus:@"视频长度不能小于5秒"];
            });
            return;
        }
//        [self _compressALAssetVideo:[assets firstObject] complete:^(AVURLAsset *avAsset, NSError *error) {
//            if (error) {
//                [TYDebugLog error:error];
//                [RSProgressHUD showErrorWithStatus:@"转码失败"];
//                return ;
//            }
//            _assets = @[avAsset];
//            code();
//        }];
        _assets = @[asset];
        _alassets = assets;
        code();
    } else {
        _assets = assets;
        code();
    }
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset {
    return (picker.selectedAssets.count < (_isRecorderVideo ? 1 : 2) && asset.defaultRepresentation != nil);
}

- (void)performPhotoEdit {
    UIStoryboard *sb = [self storyboard];//[UIStoryboard storyboardWithName:@"RSTrackViewController" bundle:nil];
    RSClassHomeNavigationContorller *navigationVC =
    [sb instantiateViewControllerWithIdentifier:@"RSTrackPhotoEditEntry"];
    RSTrackEditPhotoViewController *editVC = [[navigationVC viewControllers] firstObject];
    [editVC setAssets:_assets];
    [editVC setDeleteAfterDone:_recorderPhoto != nil];
    [editVC setLibrary:_library];
    _recorderPhoto = nil;
    _assets = nil;
    [RSProgressHUD dismiss];
    
//    if ([TYWriteHelp shareWriteHelp].isStartWrite) {
//       TYWirteNoteViewController *VC = [TYViewControllerLoader wirteNoteViewController];
//        RSDelaySegue *ds = [RSDelaySegue segueWithViewController:VC storyboard:sb toViewController:navigationVC];
//        [VC setDelaySegue:ds];
//        [ds setDelayObjectPlaceholder:self];
//    } else {
//        TYHomeViewController *VC = [TYViewControllerLoader homeViewController];
//        RSDelaySegue *ds = [RSDelaySegue segueWithViewController:VC storyboard:sb toViewController:navigationVC];
//        [VC setDelaySegue:ds];
//        [ds setDelayObjectPlaceholder:self];
//    }
    
    TYBaseNavigationController *VC = (TYBaseNavigationController *)[TYViewControllerHelp shareHelp].viewController;
    RSDelaySegue *ds = [RSDelaySegue segueWithViewController:VC storyboard:sb toViewController:navigationVC];
    [VC setDelaySegue:ds];
    [ds setDelayObjectPlaceholder:self];
    
    NSLog(@"dismiss %@", NSStringFromSelector(_cmd));
    [self dismissViewControllerAnimated:YES completion:nil];
//    UIViewController *vc = [tabbarVC selectedViewController];
//    [self dismissViewControllerAnimated:NO completion:^{
////        [RSProgressHUD showWithMaskType:RSProgressHUDMaskTypeGradient];
//        [vc presentViewController:navigationVC animated:YES completion:^{
//            [RSProgressHUD dismiss];
//        }];
//    }];
}

#pragma mark --
#pragma mark touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isProcessingData) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:_recorderBtn.superview];
    if (CGRectContainsPoint(_recorderBtn.frame, touchPoint)) {
        [_recorderBtn setHighlighted:YES];
        if ([_recorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
            return;
        } else {
            if (_deleteButton.style == DeleteButtonStyleDelete) {//取消删除
                [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
                [_progressBar setLastProgressToStyle:ProgressBarProgressStyleNormal];
                return;
            }
            [_recorder record];
            [self setStartRecorderState:YES];
        }
    }
}

- (void)makePhoto {
    _didMakePhoto = YES;
    [self freezePreview];
    [_recorder capturePhoto:^(NSError *error, UIImage *image) {
        [RSProgressHUD showWithMaskType:RSProgressHUDMaskTypeClear];
        CGSize size = CGSizeMake(_preview.bounds.size.width * 2, _preview.bounds.size.width * 2);
        UIImage *scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:size interpolationQuality:kCGInterpolationHigh];
        
        CGRect cropFrame = CGRectMake((scaledImage.size.width - size.width) / 2, (scaledImage.size.height - size.height) / 2, size.width, size.height);
        UIImage *croppedImage = [scaledImage croppedImage:cropFrame];
        
        
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        
        CGFloat degree = -90;
        if (orientation == UIDeviceOrientationPortraitUpsideDown) {
            degree = 90;// M_PI;
        } else if (orientation == UIDeviceOrientationLandscapeLeft) {
            degree = -180;// -M_PI_2;
        } else if (orientation == UIDeviceOrientationLandscapeRight) {
            degree = 0;// M_PI_2;
        } else if (orientation == UIDeviceOrientationFaceUp) {
            degree = -90;
        }
        if (degree != 0) {
             croppedImage = [croppedImage rotatedByDegrees:degree];
        }
        
        
        _recorderPhoto = croppedImage;
        [_library writeImageToSavedPhotosAlbum:[_recorderPhoto CGImage] orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TYDebugLog error:[error localizedDescription]];
                });
            } else {
                [_library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    _assets = @[asset];
                    dispatch_async(dispatch_get_main_queue(), ^{
                       [self performPhotoEdit];
                    });
                } failureBlock:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [TYDebugLog error:[error localizedDescription]];
                    });
                }];
            }
        }];
    }];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([_recorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        return;
    }
//    UITouch *touch = [touches anyObject];
//    CGPoint movePoint = [touch locationInView:_recorderBtn];
//    if (movePoint.y < 0) {
//        _promptLabel.text = @"松开取消";
//        _promptLabel.textColor = [UIColor redColor];
//    } else {
//        _promptLabel.text = @"上移取消";
//        _promptLabel.textColor = [UIColor greenColor];
//    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_recorderBtn setHighlighted:NO];
    if (_isProcessingData) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint endPoint = [touch locationInView:_recorderBtn.superview];
    if ([_recorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        if (CGRectContainsPoint(_recorderBtn.frame, endPoint) && (!_didMakePhoto)) {
            [self makePhoto];
        }
    } else {
        [_recorder pause];
    }
}

- (IBAction)unwindToVideoViewController:(UIStoryboardSegue *)segue {
   // if ([[segue sourceViewController] isKindOfClass:[RSTrackPostTableViewController class]]) {
    //    [self dismissViewControllerAnimated:YES completion:nil];
    //} else
     //   if ([[segue sourceViewController] isKindOfClass:[RSVideoPostViewController class]]) {
       // [self dismissViewControllerAnimated:YES completion:nil];
    //}
}

@end
