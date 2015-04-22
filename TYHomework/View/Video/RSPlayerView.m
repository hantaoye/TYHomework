//
//  RSPlayerView.m
//  FITogether
//
//  Created by closure on 3/25/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "RSPlayerView.h"
#import <AVFoundation/AVFoundation.h> 

@implementation RSPlayerStateView

- (void)_setup {
    [self setImage:[UIImage imageNamed:@"play"]];
    [self setUserInteractionEnabled:YES];
    [self sizeToFit];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super initWithImage:image]) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    if (self = [super initWithImage:image highlightedImage:highlightedImage]) {
        [self _setup];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)didMoveToSuperview {
    if ([self superview]) {
        [self setupImageViewFrame:[[self superview] bounds]];
    }
}

- (void)setupImageViewFrame:(CGRect)frame {
    CGFloat scale = frame.size.width / [UIScreen mainScreen].bounds.size.width;
    self.frame = CGRectMake(0, 0, scale * self.image.size.width, scale * self.image.size.height);
    self.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
}
@end

NSString *__RSPlayerViewWillPlayVideoNotification = @"RSPlayerViewWillPlayVideoNotification";

@interface RSPlayerView () {
    BOOL _playing;
}
@property (strong, nonatomic) RSPlayerStateView *imageView;
@property (assign, nonatomic) Float64 time;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@property (strong, nonatomic) id observer;

- (AVPlayerLayer *)_playerLayer;
@end

@implementation RSPlayerView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)_playerLayer {
    return (AVPlayerLayer *)[self layer];
}

- (RSPlayerStateView *)imageView {
    if ([self automaticallyShowStateView]) {
        if (!_imageView) {
            _imageView = [[RSPlayerStateView alloc] init];
        }
        return _imageView;
    }
    return nil;
}

- (RSPlayerStateView *)stateView {
    return [self imageView];
}

- (void)setStateView:(RSPlayerStateView *)stateView {
    [_imageView removeFromSuperview];
    _imageView = stateView;
}

- (void)setAutomaticallyShowStateView:(BOOL)automaticallyShowStateView {
    _automaticallyShowStateView = automaticallyShowStateView;
    if (!_automaticallyShowStateView) {
        if (_imageView) {
            [_imageView removeFromSuperview];
            _imageView = nil;
        }
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _asset = nil;
        _automaticallyShowStateView = YES;
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _asset = nil;
        _automaticallyShowStateView = YES;
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

- (instancetype)initWithAVURLAsset:(AVURLAsset *)asset {
    if (self = [super initWithFrame:CGRectZero]) {
        _automaticallyShowStateView = YES;
        [self setUserInteractionEnabled:YES];
        [self setAsset:asset];
    }
    return self;
}

- (void)setAsset:(AVURLAsset *)asset {
    NSLog(@"asset (%@) -> %@", asset, [NSThread callStackSymbols]);
    if (!asset) {
        _asset = nil;
        _playerItem = nil;
        _player = nil;
        [[self _playerLayer] removeAllAnimations];
        [[self _playerLayer] setPlayer:nil];
        return;
    } else if ([[_asset URL] isEqual:[asset URL]]) {
        return;
    } else if (_asset) {
        _asset = asset;
        _playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
        [_player replaceCurrentItemWithPlayerItem:_playerItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerWillPlayVideoNotificationAction:) name:__RSPlayerViewWillPlayVideoNotification object:nil];
        return;
    } else {
        _asset = asset;
        _playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
        _player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
        [[self _playerLayer] removeAllAnimations];
        [[self _playerLayer] setPlayer:_player];
        [[self _playerLayer] setFrame:[self frame]];
        [[self _playerLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            [_player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePlayerState)];
        [self addGestureRecognizer:_tapGesture];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerWillPlayVideoNotificationAction:) name:__RSPlayerViewWillPlayVideoNotification object:nil];
    }
    [[self imageView] removeFromSuperview];
    [self addSubview:[self imageView]];
    [self bringSubviewToFront:[self imageView]];
}

- (void)changePlayerState {
    if ([self isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)playerWillPlayVideoNotificationAction:(NSNotification *)notification {
    if ([notification userInfo][@"object"] != self) {
        [self pause];
    }
}

- (CMTime)playerItemDuration {
    AVPlayerItem *thePlayerItem = [_player currentItem];
    if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay) {
        return([thePlayerItem duration]);
    }
    return(kCMTimeInvalid);
}

- (void)play {
    if (_playerViewDelegate && [_playerViewDelegate respondsToSelector:@selector(playerWillPlay:)]) {
        [_playerViewDelegate playerWillPlay:self];
    }
    [self setPlaying:YES];
    [[self imageView] setHidden:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:__RSPlayerViewWillPlayVideoNotification object:nil userInfo:@{@"object": self}];
    if ([self playerViewDelegate] && [[self playerViewDelegate] respondsToSelector:@selector(playingTick:progress:)]) {
        double interval = .05f;
        
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            interval = 0.05;
        }
        
        /* Update the scrubber during normal playback. */
        __weak typeof(self) weakSelf = self;
        _observer = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
            [weakSelf syncScrubber];
        }];
    }
    [_player play];
}

- (void)syncScrubber {
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        [[self playerViewDelegate] playingTick:self progress:0];
        return;
    }
    
    NSTimeInterval duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration) && (duration > 0)) {
        float minValue = 0;
        float maxValue = 100;
        double time = CMTimeGetSeconds([[self player] currentTime]);
        [[self playerViewDelegate] playingTick:self progress:(maxValue - minValue) * time / duration + minValue];
    }
}

- (void)pause {
    if (_playerViewDelegate && [_playerViewDelegate respondsToSelector:@selector(playerWillPause:)]) {
        [_playerViewDelegate playerWillPause:self];
    }
    [self setPlaying:NO];
    [[self imageView] setHidden:NO];
    if (_observer) {
        [_player removeTimeObserver:_observer];
        _observer = nil;
    }
    [_player pause];
}

- (void)resetPlayerTime {
    [_playerItem seekToTime:kCMTimeZero];
}

- (void)setQuite:(BOOL)quite {
    [_player setVolume:quite ? 0 : 1];
}

- (BOOL)isQuite {
    return [_player volume] == 0.0;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    int32_t timeScale = p.asset.duration.timescale;
    [p seekToTime:CMTimeMakeWithSeconds(_time, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self pause];
    }];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [[self _playerLayer] setFrame:frame];
    [[self _playerLayer] removeAllAnimations];
    [self setupImageViewFrame:[self frame] bounds:[self bounds]];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        [self pause];
    }
}

- (void)setPlayingTime:(Float64)time {
    _time = time;
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay && _player.status == AVPlayerStatusReadyToPlay) {
        CMTimeScale timeScale = _playerItem.asset.duration.timescale;
        [_playerItem seekToTime:CMTimeMakeWithSeconds(time, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            [self pause];
        }];
    }
}

- (void)setupImageViewFrame:(CGRect)frame bounds:(CGRect)bounds {
    CGFloat scale = frame.size.width / [UIScreen mainScreen].bounds.size.width;
    self.imageView.frame = CGRectMake(0, 0, scale * self.imageView.image.size.width, scale * self.imageView.image.size.height);
    self.imageView.center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([_player respondsToSelector:aSelector]) {
        return _player;
    } else if ([_playerItem respondsToSelector:aSelector]) {
        return _playerItem;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (void)dealloc {
    [self pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
