//
//  TYWirteNoteViewController.m
//  TYHomework
//
//  Created by taoYe on 15/4/22.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYWirteNoteViewController.h"
#import "TYPlaceholderTextView.h"
#import "TYNote.h"
#import "TYNoteDao.h"
#import "TYWriteHelp.h"
#import "TYViewControllerLoader.h"
#import "TYAudioViewController.h"
#import "RSPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "TYViewControllerHelp.h"
#import "RSVideo.h"
#import "TYImageHelper.h"
#import "UIImage+TY.h"

@interface TYWirteNoteViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *drawImageButton;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet TYPlaceholderTextView *textView;
@property (strong, nonatomic) UIImageView *showView;
@property (assign, nonatomic) CGRect showViewFrame;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveItem;

@property (strong, nonatomic) TYNoteDao *dao;
@property (copy, nonatomic) NSString *videoPath;
@property (copy, nonatomic) NSString *imageURL;
@property (copy, nonatomic) NSString *drawIamgeURL;
@property (copy, nonatomic) NSString *audioURL;

@property (strong, nonatomic) RSPlayerView *playerView;

@end

@implementation TYWirteNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"letter-paper4"]];
    _textView.layer.cornerRadius = 2.0f;
    _textView.layer.masksToBounds = YES;
}

- (void)setup {
    [TYWriteHelp shareWriteHelp].startWrite = YES;
    _dao = [TYNoteDao sharedDao];
    if (_note) {
        self.textView.text = _note.desc;
        self.titleTextField.text = _note.title;
        if (_note.videopath.length) {
            _videoPath = _note.videopath;
            [RSVideo generateImage:[AVURLAsset assetWithURL:[NSURL URLWithString:_videoPath]] action:^(UIImage *image, NSError *error) {
                [self.videoButton setBackgroundImage:image forState:UIControlStateNormal];
            }];
            _videoButton.tag = 1;
        }
        if (_note.drawImageURL.length) {
            [_drawImageButton setBackgroundImage:[TYImageHelper getImageForPath:_note.drawImageURL] forState:UIControlStateNormal];
            _drawImageButton.tag = 1;
        }
        if (_note.audioURL.length) {
//            _audioButton setBackgroundImage:(UIImage *) forState:<#(UIControlState)#>
            _audioButton.tag = 1;
        }
        if (_note.imageURL.length) {
            [_photoButton setBackgroundImage:[TYImageHelper getImageForPath:_note.imageURL] forState:UIControlStateNormal];
            _photoButton.tag = 1;
        }
    }
}

- (void)dealloc {
    [TYWriteHelp shareWriteHelp].startWrite = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupDelaySegue];
    if ([TYWriteHelp shareWriteHelp].asset) {
        _videoPath = [TYWriteHelp shareWriteHelp].asset.URL.absoluteString;
        [TYWriteHelp shareWriteHelp].asset = nil;
        _videoButton.tag = 1;
        [_videoButton setBackgroundImage:[TYWriteHelp shareWriteHelp].videoImage forState:UIControlStateNormal];
        [TYWriteHelp shareWriteHelp].videoImage = nil;
    }
    if ([TYWriteHelp shareWriteHelp].image) {
        [_photoButton setBackgroundImage:[TYWriteHelp shareWriteHelp].image forState:UIControlStateNormal];
        _photoButton.tag = 1;
        [TYWriteHelp shareWriteHelp].image = nil;
    }
    
    if ([TYWriteHelp shareWriteHelp].drawImage) {
        [_drawImageButton setBackgroundImage:[TYWriteHelp shareWriteHelp].drawImage forState:UIControlStateNormal];
        _drawImageButton.tag = 1;
        [TYWriteHelp shareWriteHelp].drawImage = nil;
    }
}

- (void)setupDelaySegue {
}

- (IBAction)pressedVideoButton:(UIButton *)sender {
    if (sender.tag != 1) {
        [TYViewControllerHelp shareHelp].viewController = self.navigationController;
        UIViewController *VC = [[TYViewControllerLoader videoStoryboard] instantiateInitialViewController];
        [self presentViewController:VC animated:YES completion:^{
        }];
    } else {
        [self startShowViewWithStartRect:sender.frame image:sender.currentBackgroundImage videoURL:[NSURL URLWithString:_videoPath]];
    }
}

- (IBAction)pressedPhotoButton:(UIButton *)sender {
    if (sender.tag != 1) {
        [TYViewControllerHelp shareHelp].viewController = self.navigationController;
        UIViewController *VC = [[TYViewControllerLoader videoStoryboard] instantiateInitialViewController];
        [self presentViewController:VC animated:YES completion:^{
        }];
    } else {
        [self startShowViewWithStartRect:sender.frame image:sender.currentBackgroundImage videoURL:nil];
    }
}

- (IBAction)drawButton:(UIButton *)sender {
    if (sender.tag != 1) {
        UIViewController *VC = [[TYViewControllerLoader drawStoryboard] instantiateInitialViewController];
        [self presentViewController:VC animated:YES completion:^{
            
        }];
    } else {
        [self startShowViewWithStartRect:sender.frame image:sender.currentBackgroundImage videoURL:nil];
    }
}

- (IBAction)pressedAudioButton:(UIButton *)sender {
    if (sender.tag != 1) {
        TYAudioViewController *VC = [TYViewControllerLoader audioViewController];
        [self.navigationController pushViewController:VC animated:YES];
    } else {
        [self startShowViewWithStartRect:sender.frame image:nil videoURL:[NSURL URLWithString:_audioURL]];
    }
}

- (IBAction)pressedSaveButton:(UIBarButtonItem *)sender {
    if (!_titleTextField.text.length) {
        [RSProgressHUD showErrorWithStatus:@"请输出标题"];
        return;
    }
    
    if (!_textView.text.length && !_videoPath && !_imageURL && !_drawIamgeURL && !_audioURL) {
        [RSProgressHUD showErrorWithStatus:@"请选择填充内容"];
    }
    
    if (_photoButton.tag == 1) {
        NSLog(@"%@", _photoButton.currentBackgroundImage);
        _imageURL = [TYImageHelper setPhotoImage:_photoButton.currentBackgroundImage];
    }
    
    if (_drawImageButton.tag == 1) {
        _drawIamgeURL = [TYImageHelper setDrawImage:_drawImageButton.currentBackgroundImage];
    }
    
    if (_audioButton.tag == 1) {
        
    }
    if (_note) {
//        删除
        [_dao deleteWithNoteID:_note.ID];
        [_dao deleteWithNoteTitle:_note.title];
    }
    
    [_dao insertNoteWithID:0 title:_titleTextField.text desc:_textView.text videoPagth:_videoPath imageURL:_imageURL drawImageURL:_drawIamgeURL audioURL:_audioURL action:^(TYNote *note) {
        run(^{
            [RSProgressHUD showSuccessWithStatus:@"保存成功"];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }];
}
- (IBAction)pressedBackButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImageView *)showView {
    if (!_showView) {
        _showView = [[UIImageView alloc] init];
        [self.view addSubview:_showView];
        _showView.userInteractionEnabled = YES;
        [_showView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelShowView:)]];
    }
    return _showView;
}

- (void)startShowViewWithStartRect:(CGRect)frame image:(UIImage *)image videoURL:(NSURL *)videoURL {
    self.showView.frame = frame;
    _showViewFrame = frame;
    self.showView.image = image;
    self.showView.hidden = NO;
    if (videoURL) {
        _playerView = [[RSPlayerView alloc] initWithAVURLAsset:[AVURLAsset assetWithURL:videoURL]];
        _playerView.automaticallyShowStateView = NO;
        _playerView.frame = self.showView.bounds;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        for (UIGestureRecognizer *gesture in _playerView.gestureRecognizers) {
        [_playerView removeGestureRecognizer:gesture];
        }
        [self.showView addSubview:_playerView];
        [_playerView play];
    } else {
        [_playerView removeFromSuperview];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.showView.frame = self.view.bounds;
        _playerView.frame = self.showView.bounds;
    }];
}

- (void)cancelShowView:(UITapGestureRecognizer *)gesture {
    [_playerView pause];
    [UIView animateWithDuration:0.3 animations:^{
        self.showView.frame = _showViewFrame;
        _playerView.frame = _showView.bounds;
    } completion:^(BOOL finished) {
        self.showView.hidden = YES;
        [_playerView removeFromSuperview];
    }];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_playerView play];
    });
}
@end
