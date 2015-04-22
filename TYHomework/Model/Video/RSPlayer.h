//
//  RSPlayer.h
//  RSVideoDemo
//
//  Created by taoYe on 15/2/6.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@class RSPlayer;
@protocol RSPlayerDelegate <NSObject>
@optional
- (void)playerIsPlaying;

@end

@interface RSPlayer : NSObject
@property (nonatomic, strong) NSURL *videoFileURL;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;
@property (nonatomic, weak) id<RSPlayerDelegate> delegate;

@property (nonatomic, assign) CGFloat startTime;

@property (nonatomic, assign, readonly) CGFloat currentTime;

@property (nonatomic, assign, getter=isQuiet) BOOL quiet;
@property (nonatomic, assign) CGRect frame;
- (instancetype)initWithFileURL:(NSURL *)videoFileURL frame:(CGRect)frame ;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)play;
- (void)pause;
- (void)resetPlayerTime;
- (void)showInView:(UIView *)view;
- (void)setPlayingTime:(Float64)time;
@end
