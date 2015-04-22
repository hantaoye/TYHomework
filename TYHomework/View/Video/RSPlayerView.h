//
//  RSPlayerView.h
//  FITogether
//
//  Created by closure on 3/25/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class RSPlayerView;

@protocol RSPlayerViewDelegate <NSObject>
@optional
- (void)playerWillPlay:(RSPlayerView *)playerView;
- (void)playerWillPause:(RSPlayerView *)playerView;
- (void)playingTick:(RSPlayerView *)playerView progress:(CGFloat)progress;
@end

@interface RSPlayerStateView : UIImageView
- (void)setupImageViewFrame:(CGRect)frame;
@end

@interface RSPlayerView : UIView
@property (assign, nonatomic, getter=isPlaying) BOOL playing;
@property (assign, nonatomic, getter=isQuite) BOOL quite;
@property (strong, nonatomic) AVURLAsset *asset;
@property (weak, nonatomic) id <RSPlayerViewDelegate> playerViewDelegate;
@property (assign, nonatomic) BOOL automaticallyShowStateView; // default is YES;

@property (assign, nonatomic) CGFloat progressBarWidth;

- (instancetype)initWithFrame:(CGRect)frame;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (instancetype)initWithAVURLAsset:(AVURLAsset *)asset;

- (void)setPlayingTime:(Float64)time;

@property (nonatomic, readonly) AVPlayerStatus status;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic) float rate;
- (void)play;
- (void)pause;

- (void)resetPlayerTime;

- (RSPlayerStateView *)stateView;
- (void)setStateView:(RSPlayerStateView *)stateView;

@property (nonatomic) AVPlayerActionAtItemEnd actionAtItemEnd;

- (CMTime)currentTime;
- (void)seekToDate:(NSDate *)date;
- (void)seekToDate:(NSDate *)date completionHandler:(void (^)(BOOL finished))completionHandler NS_AVAILABLE(10_7, 5_0);
- (void)seekToTime:(CMTime)time;
- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter;
- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler NS_AVAILABLE(10_7, 5_0);
- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL finished))completionHandler NS_AVAILABLE(10_7, 5_0);

- (void)setRate:(float)rate time:(CMTime)itemTime atHostTime:(CMTime)hostClockTime NS_AVAILABLE(10_8, 6_0);
- (void)prerollAtRate:(float)rate completionHandler:(void (^)(BOOL finished))completionHandler NS_AVAILABLE(10_8, 6_0);
- (void)cancelPendingPrerolls NS_AVAILABLE(10_8, 6_0);
@property (nonatomic, retain) __attribute__((NSObject)) CMClockRef masterClock NS_AVAILABLE(10_8, 6_0);

@property (nonatomic) float volume NS_AVAILABLE(10_7, 7_0);
@property (nonatomic, getter=isMuted) BOOL muted NS_AVAILABLE(10_7, 7_0);
@property (nonatomic, getter=isClosedCaptionDisplayEnabled) BOOL closedCaptionDisplayEnabled;
@property (nonatomic, copy) NSString *audioOutputDeviceUniqueID NS_AVAILABLE_MAC(10_9);

@property (nonatomic, readonly) CMTime duration NS_AVAILABLE(10_7, 4_3);
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly) NSArray *timedMetadata;
@property (nonatomic, readonly) NSArray *automaticallyLoadedAssetKeys NS_AVAILABLE(10_9, 7_0);
@property (nonatomic, readonly) BOOL canPlayFastForward NS_AVAILABLE(10_8, 5_0);
@property (nonatomic, readonly) BOOL canPlaySlowForward NS_AVAILABLE(10_8, 6_0);
@property (nonatomic, readonly) BOOL canPlayReverse NS_AVAILABLE(10_8, 6_0);
@property (nonatomic, readonly) BOOL canPlaySlowReverse NS_AVAILABLE(10_8, 6_0);
@property (nonatomic, readonly) BOOL canPlayFastReverse NS_AVAILABLE(10_8, 5_0);
@property (nonatomic, readonly) BOOL canStepForward NS_AVAILABLE(10_8, 6_0);
@property (nonatomic, readonly) BOOL canStepBackward NS_AVAILABLE(10_8, 6_0);

@property (nonatomic, copy) AVVideoComposition *videoComposition;
@property (nonatomic, readonly) id<AVVideoCompositing> customVideoCompositor NS_AVAILABLE(10_9, 7_0);
@property (nonatomic) BOOL seekingWaitsForVideoCompositionRendering NS_AVAILABLE(10_9, 6_0);
@property (nonatomic, copy) NSString *audioTimePitchAlgorithm NS_AVAILABLE(10_9, 7_0);
@property (nonatomic, copy) AVAudioMix *audioMix;

@end
