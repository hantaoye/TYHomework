//
//  RSPlayer.m
//  RSVideoDemo
//
//  Created by taoYe on 15/2/6.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "RSPlayer.h"

@interface RSPlayer ()
@property (assign, nonatomic) Float64 time;
@property (strong, nonatomic) UIImageView *imageView;
//@property (nonatomic, strong) UIImageView *imageView;
@property (weak, nonatomic) UIView *showInView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (weak, nonatomic) NSTimer *timer;
@end

@implementation RSPlayer

- (UIView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play"]];
        [_imageView sizeToFit];
    }
    return _imageView;
}

- (instancetype)initWithFileURL:(NSURL *)videoFileURL frame:(CGRect)frame {
    if (self = [super init]) {
        _videoFileURL = videoFileURL;
        _frame = frame;
        [self initPlayLayerWithFrame:(CGRect)frame];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFileURL:nil frame:frame];
}

- (instancetype)init {
    return [self initWithFileURL:nil frame:CGRectZero];
}

- (void)setVideoFileURL:(NSURL *)videoFileURL {
    if (videoFileURL == nil) return;
    
    @synchronized(self) {

        if (_videoFileURL != nil && [_videoFileURL.absoluteString isEqualToString:videoFileURL.absoluteString]) {
            return;
        }
        _videoFileURL = videoFileURL;

        [self initPlayLayerWithFrame:_frame];
    }
}

- (void)initPlayLayerWithFrame:(CGRect)frame {
    if (!_videoFileURL) {
        return;
    }
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePlayerState)];
    
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:_videoFileURL options:nil];
    self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = frame;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    _playerLayer.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_playerLayer.player currentItem]];
//    [self setStartTime:0];
    
    [_playerItem seekToTime:kCMTimeZero];
}

- (void)setStartTime:(CGFloat)startTime {
    _startTime = startTime;
//    if (_playerItem.status == AVPlayerItemStatusReadyToPlay && _player.status == AVPlayerStatusReadyToPlay) {
        int32_t timeScale = _playerItem.asset.duration.timescale;
    [_playerItem seekToTime:CMTimeMakeWithSeconds(_startTime, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
//        [_playerItem seekToTime:CMTimeMakeWithSeconds(_startTime, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
//            [self pause];
//        }];
//    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
//    [p seekToTime:kCMTimeZero];
    int32_t timeScale = p.asset.duration.timescale;
    [p seekToTime:CMTimeMakeWithSeconds(_time, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self pause];
    }];
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    [[self imageView] setHidden:playing];
}

- (void)play {
    [_player play];
    [self setPlaying:YES];
    [self didStartPlaying];
}

- (void)pause {
    [_player pause];
    [self setPlaying:NO];
    [_timer invalidate];
    _timer = nil;
}

- (void)didStartPlaying {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerIsPlaying)]) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.03f target:self.delegate selector:@selector(playerIsPlaying) userInfo:nil repeats:YES];
    }
}

- (void)resetPlayerTime {
    [_playerItem seekToTime:kCMTimeZero];
}

- (void)showInView:(UIView *)view {
    view.userInteractionEnabled = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        [view addGestureRecognizer:_tapGesture];
        
        if (_playerLayer.superlayer != nil) {
            [_playerLayer removeFromSuperlayer];
        }
        [view.layer addSublayer:_playerLayer];

        if (_showInView) {
            [[self imageView] removeFromSuperview];
        }
        _showInView = view;
        
        [view addSubview:[self imageView]];

        self.frame = view.bounds;
    });
}

- (void)changePlayerState {
    if ([self isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self pause];
}

- (void)setQuiet:(BOOL)quiet {
    _quiet = quiet;
    _player.volume = quiet ? 0.0 : 1.0;
}

- (void)setFrame:(CGRect)frame {
    _frame = frame;
    _playerLayer.frame = frame;
    [self setupImageViewFrame];
}

- (void)setupImageViewFrame {
    CGFloat scale = _showInView.frame.size.width / [UIScreen mainScreen].bounds.size.width;
    self.imageView.frame = CGRectMake(0, 0, scale * self.imageView.image.size.width, scale * self.imageView.image.size.height);
    [self imageView].center = CGPointMake(_showInView.bounds.size.width / 2, _showInView.bounds.size.height / 2);
}

- (void)setPlayingTime:(Float64)time {
    _time = time;
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay && _player.status == AVPlayerStatusReadyToPlay) {
        int32_t timeScale = _playerItem.asset.duration.timescale;
        [_playerItem seekToTime:CMTimeMakeWithSeconds(time, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            [self pause];
        }];
    }
}

- (CGFloat)currentTime {
    return CMTimeGetSeconds(_playerItem.currentTime);
}

@end
