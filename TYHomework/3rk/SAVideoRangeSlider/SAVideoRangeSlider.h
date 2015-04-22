//
//  SAVideoRangeSlider.h
//
// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2013 Andrei Solovjev - http://solovjev.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "SASliderLeft.h"
#import "SASliderRight.h"
#import "SAResizibleBubble.h"

#define BG_VIEW_BORDERS_SIZE 2.0f
#define offset 10

@protocol SAVideoRangeSliderDelegate;

@interface SAVideoRangeSlider : UIView


@property (nonatomic, weak) id <SAVideoRangeSliderDelegate> delegate;
@property (nonatomic, strong) UIScrollView *bgView;

@property (nonatomic) CGFloat leftPosition;
@property (nonatomic) CGFloat rightPosition;
@property (nonatomic, strong) UILabel *bubleText;
@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;
@property (nonatomic, assign) CGFloat maxGap;
@property (nonatomic, assign) CGFloat minGap;
- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL minGap:(CGFloat)minGap maxGap:(CGFloat)maxGap;

//- (id)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL;

- (void)setPopoverBubbleSize: (CGFloat) width height:(CGFloat)height;

@end


@protocol SAVideoRangeSliderDelegate <NSObject>

@optional

- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;

- (void)videoRange:(SAVideoRangeSlider *)videoRange didGestureStateEndedLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;

- (void)videoRange:(SAVideoRangeSlider *)videoRange didScrollStateWithLeftPosition:(CGFloat)leftPosition;

- (void)videoRange:(SAVideoRangeSlider *)videoRange sliderValueDidChangeWithRightPosition:(CGFloat)rightPosition;

@end




