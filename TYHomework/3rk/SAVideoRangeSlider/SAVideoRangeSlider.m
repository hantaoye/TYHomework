//
//  SAVideoRangeSlider.m
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

#import "SAVideoRangeSlider.h"
#import "RSProgressHUD.h"
#import "UIImage+TY.h"

#define SLIDER_BORDERS_SIZE 6.0f
#define imageWidth 60
#define SliderHeight 26
#define ORANGE_COLOR [UIColor orangeColor]

@interface SAVideoRangeSlider () <UIScrollViewDelegate>

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) SASliderLeft *leftThumb;
@property (nonatomic, strong) SASliderRight *rightThumb;
@property (nonatomic) CGFloat frame_width;
@property (nonatomic) Float64 durationSeconds;
@property (nonatomic, strong) SAResizibleBubble *popoverBubble;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, assign) CGFloat currentValue;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, assign) CGFloat translation;

@property (assign, nonatomic) CGFloat thumbImageWidth;
@property (assign, nonatomic) CGFloat thumbImageScaleValue;


@end

@implementation SAVideoRangeSlider

- (void)setupSliderWithFrame:(CGRect)frame {
    
    _slider = [[UISlider alloc] initWithFrame:frame];

    [_slider setMaximumTrackTintColor:[UIColor redColor]];
    [_slider setMaximumValue:_maxGap];
    [_slider setMinimumValue:0];
    _slider.value = _minGap;
    [_slider addTarget:self action:@selector(didchangeSliderValue:) forControlEvents:UIControlEventValueChanged];
    
    [_slider setMinimumTrackImage:[UIImage resizedImageWithName:@"video-progress"]forState:UIControlStateNormal];
    [_slider setMinimumTrackImage:[UIImage resizedImageWithName:@"video-progress"]forState:UIControlStateHighlighted];
    
    [_slider setMaximumTrackImage:[UIImage resizedImageWithName:@"video-progress-back"] forState:UIControlStateNormal];
    [_slider setMaximumTrackImage:[UIImage resizedImageWithName:@"video-progress-back"] forState:UIControlStateHighlighted];

    [_slider setThumbImage:[UIImage imageNamed:@"video-thumb"] forState:UIControlStateNormal];
    [_slider setThumbImage:[UIImage imageNamed:@"video-thumb"] forState:UIControlStateHighlighted];
    
//    [self setupThumbImage];
    [self addSubview:_slider];
//    frame.size.width += 15;
//    _slider.frame = frame;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, SLIDER_BORDERS_SIZE)];
    view.backgroundColor = [UIColor grayColor];
    view.alpha = 0.2;
    view.center = CGPointMake(_minGap / _maxGap * frame.size.width, _slider.center.y);
    
    [self addSubview:view];
}

- (void)setupShadowViewWithFrame:(CGRect)frame {
    _shadowView = [[UIView alloc] initWithFrame:frame];
    [self insertSubview:_shadowView belowSubview:_slider];
    _shadowView.backgroundColor = [UIColor blackColor];
//    _bgView.alpha = 0.05;
    _shadowView.alpha = 0.5;
    [_shadowView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didScrollShadowView:)]];
    _shadowView.transform = CGAffineTransformMakeTranslation([self sliderScaleWidth], 0);

}

- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL minGap:(CGFloat)minGap maxGap:(CGFloat)maxGap {
    self = [super initWithFrame:frame];
    if (self) {
        _minGap = minGap;
        _maxGap = maxGap;
        
        _frame_width = frame.size.width;
        int thumbWidth = ceil(frame.size.width*0.05);
        _bgView = [[UIScrollView alloc] init];
        _bgView.bounces = NO;
        _bgView.delegate = self;
//        _bgView.backgroundColor = [UIColor greenColor];
//        _bgView.decelerating = NO;
//        _bgView = [[UIControl alloc] initWithFrame:CGRectMake(thumbWidth-BG_VIEW_BORDERS_SIZE, 0, frame.size.width-(thumbWidth*2)+BG_VIEW_BORDERS_SIZE*2, frame.size.height)];
        _bgView.layer.borderColor = [UIColor whiteColor].CGColor;
        _bgView.layer.borderWidth = BG_VIEW_BORDERS_SIZE;
        [_bgView setShowsHorizontalScrollIndicator:NO];
        [_bgView setShowsVerticalScrollIndicator:NO];
        [_bgView setDecelerationRate:0.0];
        [self addSubview:_bgView];
        [self setupSliderWithFrame:CGRectMake(0, 0, frame.size.width, SliderHeight)];

        _videoURL = videoURL;
        
        
        _topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, SLIDER_BORDERS_SIZE)];
        _topBorder.backgroundColor = [UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 1];
//        [self addSubview:_topBorder];
        
        
        _bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-SLIDER_BORDERS_SIZE, frame.size.width, SLIDER_BORDERS_SIZE)];
        _bottomBorder.backgroundColor = [UIColor colorWithRed: 0.992 green: 0.902 blue: 0.004 alpha: 1];
//        [self addSubview:_bottomBorder];
        
        
        _leftThumb = [[SASliderLeft alloc] initWithFrame:CGRectMake(0, 0, thumbWidth, frame.size.height)];
        _leftThumb.contentMode = UIViewContentModeLeft;
        _leftThumb.userInteractionEnabled = YES;
        _leftThumb.clipsToBounds = YES;
        _leftThumb.backgroundColor = [UIColor clearColor];
        _leftThumb.layer.borderWidth = 0;
//        [self addSubview:_leftThumb];
        
        
        UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
        [_leftThumb addGestureRecognizer:leftPan];
        
        
        _rightThumb = [[SASliderRight alloc] initWithFrame:CGRectMake(0, 0, thumbWidth, frame.size.height)];
        
        _rightThumb.contentMode = UIViewContentModeRight;
        _rightThumb.userInteractionEnabled = YES;
        _rightThumb.clipsToBounds = YES;
        _rightThumb.backgroundColor = [UIColor clearColor];
//        [self addSubview:_rightThumb];
        
        UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
        [_rightThumb addGestureRecognizer:rightPan];
        
        _rightPosition = frame.size.width;
        _leftPosition = 0;
        
        _centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _centerView.backgroundColor = [UIColor clearColor];
//        [self addSubview:_centerView];
        
        UIPanGestureRecognizer *centerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCenterPan:)];
        [_centerView addGestureRecognizer:centerPan];
        
        
        _popoverBubble = [[SAResizibleBubble alloc] initWithFrame:CGRectMake(0, -50, 100, 50)];
        _popoverBubble.alpha = 0;
        _popoverBubble.backgroundColor = [UIColor clearColor];
//        [self addSubview:_popoverBubble];
        
        
        _bubleText = [[UILabel alloc] initWithFrame:_popoverBubble.frame];
        _bubleText.font = [UIFont boldSystemFontOfSize:20];
        _bubleText.backgroundColor = [UIColor clearColor];
        _bubleText.textColor = [UIColor blackColor];
        _bubleText.textAlignment = NSTextAlignmentCenter;
        
        [_popoverBubble addSubview:_bubleText];
        
        [self getMovieFrame];
    }
    
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setPopoverBubbleSize: (CGFloat) width height:(CGFloat)height{
    
    CGRect currentFrame = _popoverBubble.frame;
    currentFrame.size.width = width;
    currentFrame.size.height = height;
    currentFrame.origin.y = -height;
    _popoverBubble.frame = currentFrame;
    
    currentFrame.origin.x = 0;
    currentFrame.origin.y = 0;
    _bubleText.frame = currentFrame;
    
}


-(void)setMaxGap:(CGFloat)maxGap {
    if (maxGap > _durationSeconds) {
        maxGap = _durationSeconds;
    }
    _leftPosition = 0;
    _rightPosition = _frame_width*maxGap/_durationSeconds;
    _maxGap = maxGap;
}

-(void)setMinGap:(CGFloat)minGap{
    _leftPosition = 0;
    _rightPosition = _frame_width*minGap/_durationSeconds;
    _minGap = minGap;
}


- (void)delegateNotification
{
    if ([_delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:)]){
        [_delegate videoRange:self didChangeLeftPosition:self.leftPosition rightPosition:self.rightPosition];
    }
}

- (void)setupSliderVaule {
    if (_durationSeconds) {
        if (_durationSeconds >= _maxGap) {
            _slider.value = _maxGap;
        } else {
            _slider.value = _durationSeconds;
        }
    } else {
        _slider.value = _minGap;
    }
    _shadowView.transform = CGAffineTransformMakeTranslation([self sliderScaleWidth], 0);
}


#pragma mark - Gestures

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:self];
        
        _leftPosition += translation.x;
        if (_leftPosition < 0) {
            _leftPosition = 0;
        }
        
        if (
            (_rightPosition-_leftPosition <= _leftThumb.frame.size.width+_rightThumb.frame.size.width) ||
            ((self.maxGap > 0) && (self.rightPosition-self.leftPosition > self.maxGap)) ||
            ((self.minGap > 0) && (self.rightPosition-self.leftPosition < self.minGap))
            ){
            _leftPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        
        [self delegateNotification];
        
    }
    
    _popoverBubble.alpha = 1;
    
    [self setTimeLabel];
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        [self hideBubble:_popoverBubble];
    }
}


- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        
        CGPoint translation = [gesture translationInView:self];
        _rightPosition += translation.x;
        if (_rightPosition < 0) {
            _rightPosition = 0;
        }
        
        if (_rightPosition > _frame_width){
            _rightPosition = _frame_width;
        }
        
        if (_rightPosition-_leftPosition <= 0){
            _rightPosition -= translation.x;
        }
        
        if ((_rightPosition-_leftPosition <= _leftThumb.frame.size.width+_rightThumb.frame.size.width) ||
            ((self.maxGap > 0) && (self.rightPosition-self.leftPosition > self.maxGap)) ||
            ((self.minGap > 0) && (self.rightPosition-self.leftPosition < self.minGap))){
            _rightPosition -= translation.x;
        }
        
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        
        [self delegateNotification];
        
    }
    
    _popoverBubble.alpha = 1;
    
    [self setTimeLabel];
    
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        [self hideBubble:_popoverBubble];
    }
}


- (void)handleCenterPan:(UIPanGestureRecognizer *)gesture
{
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:self];
        
        _leftPosition += translation.x;
        _rightPosition += translation.x;
        
        if (_rightPosition > _frame_width || _leftPosition < 0){
            _leftPosition -= translation.x;
            _rightPosition -= translation.x;
        }
        
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        
        [self delegateNotification];
        
    }
    
    _popoverBubble.alpha = 1;
    
    [self setTimeLabel];
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        [self hideBubble:_popoverBubble];
    }
    
}


- (void)layoutSubviews
{
    CGFloat inset = _leftThumb.frame.size.width / 2;
    
    _leftThumb.center = CGPointMake(_leftPosition+inset, _leftThumb.frame.size.height/2);
    
    _rightThumb.center = CGPointMake(_rightPosition-inset, _rightThumb.frame.size.height/2);
    
    _topBorder.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width, 0, _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width/2, SLIDER_BORDERS_SIZE);
    
    _bottomBorder.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width, _bgView.frame.size.height-SLIDER_BORDERS_SIZE, _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width/2, SLIDER_BORDERS_SIZE);
    
    
    _centerView.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width, _centerView.frame.origin.y, _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width, _centerView.frame.size.height);
    
    
    CGRect frame = _popoverBubble.frame;
    frame.origin.x = _centerView.frame.origin.x+_centerView.frame.size.width/2-frame.size.width/2;
    _popoverBubble.frame = frame;
}


#pragma mark - Video

-(void)getMovieFrame{
    _bgView.frame = CGRectMake(0, CGRectGetMaxY(_slider.frame) - offset, self.bounds.size.width, self.bounds.size.height - SliderHeight);
    [_bgView setContentInset:UIEdgeInsetsMake(0, 0, 0, (_bgView.bounds.size.width / _maxGap) * (_maxGap - _minGap))];
    
    [self setupShadowViewWithFrame:_bgView.frame];
    
    AVAsset *myAsset = [[AVURLAsset alloc] initWithURL:_videoURL options:nil];
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    if ([self isRetina]){
        self.imageGenerator.maximumSize = CGSizeMake(_bgView.frame.size.width*2, _bgView.frame.size.height*2);
    } else {
        self.imageGenerator.maximumSize = CGSizeMake(_bgView.frame.size.width, _bgView.frame.size.height);
    }
    
    int picWidth = imageWidth;
    
    // First image
    NSError *error;
    CMTime actualTime;
    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
    if (halfWayImage != NULL) {
        UIImage *videoScreen;
        if ([self isRetina]){
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
        } else {
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
        }
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        CGRect rect=tmp.frame;
        rect.size.width=picWidth;
        tmp.frame=rect;
        [_bgView addSubview:tmp];
        picWidth = tmp.frame.size.width;
        CGImageRelease(halfWayImage);
    }
    
    
    _durationSeconds = CMTimeGetSeconds([myAsset duration]);
    [self setupSliderVaule];
//    int picsCnt = ceil(_bgView.frame.size.width / picWidth);

    int picsCnt = ceill(_durationSeconds / _maxGap * _bgView.frame.size.width / imageWidth);
    
    NSMutableArray *allTimes = [[NSMutableArray alloc] init];
    
    int time4Pic = 0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        // Bug iOS7 - generateCGImagesAsynchronouslyForTimes
        int prefreWidth=0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [RSProgressHUD show];
        });
        
        for (int i=1, ii=1; i<picsCnt; i++){
            time4Pic = i*picWidth;
            
            CMTime timeFrame = CMTimeMakeWithSeconds(_durationSeconds*time4Pic/_bgView.frame.size.width, 600);
//            CMTime timeFrame = CMTimeMakeWithSeconds(i, 600);

            [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
        
            
            CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:timeFrame actualTime:&actualTime error:&error];
            
            UIImage *videoScreen;
            if ([self isRetina]){
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
            } else {
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
            }
            
            
            UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
    
            
            
            CGRect currentFrame = tmp.frame;
            currentFrame.origin.x = ii*picWidth;
            
            currentFrame.size.width=picWidth;
            
            if (i == picsCnt - 1) {
                if (_slider.value / _slider.maximumValue * _slider.frame.size.width > (prefreWidth + imageWidth)) {
                    currentFrame.size.width = _slider.value / _slider.maximumValue * _slider.frame.size.width - prefreWidth - imageWidth;
                }
            }
            
            prefreWidth+=currentFrame.size.width;
            
            if( i == picsCnt-1){
                currentFrame.size.width-=6;
            }
            tmp.frame = currentFrame;
            int all = (ii+1)*tmp.frame.size.width;
            
            if (all > _bgView.frame.size.width){
                int delta = all - _bgView.frame.size.width;
                currentFrame.size.width -= delta;
            }
            
            ii++;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_bgView addSubview:tmp];
            });
            
            
            
            
            CGImageRelease(halfWayImage);
        
        }
        _bgView.contentSize = CGSizeMake(prefreWidth + picWidth, 0);
//        CGImageRef lastImage = [self.imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(_durationSeconds, 600) actualTime:&actualTime error:&error];
//        if (_slider.value / _slider.maximumValue * _slider.frame.size.width > (prefreWidth + imageWidth)) {
//                currentFrame.size.width = _slider.value / _slider.maximumValue * _slider.frame.size.width - prefreWidth - imageWidth;
//            }
//        
//        CGImageRelease(lastImage);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [RSProgressHUD dismiss];
        });
        
        
        return;
    }
    
    for (int i=1; i<picsCnt; i++){
        time4Pic = i*picWidth;
        
        CMTime timeFrame = CMTimeMakeWithSeconds(_durationSeconds*time4Pic/_bgView.frame.size.width, 600);
        
        [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
    }
    
    NSArray *times = allTimes;
    
    __block int i = 1;
    [RSProgressHUD show];
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        
        if (result == AVAssetImageGeneratorSucceeded) {
            
            
            UIImage *videoScreen;
            if ([self isRetina]){
                videoScreen = [[UIImage alloc] initWithCGImage:image scale:2.0 orientation:UIImageOrientationUp];
            } else {
                videoScreen = [[UIImage alloc] initWithCGImage:image];
            }
            
            
            UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
            
            int all = (i+1)*tmp.frame.size.width;
            
            
            CGRect currentFrame = tmp.frame;
            currentFrame.origin.x = i*currentFrame.size.width;
            if (all > _bgView.frame.size.width){
                int delta = all - _bgView.frame.size.width;
                currentFrame.size.width -= delta;
            }
            tmp.frame = currentFrame;
            i++;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_bgView addSubview:tmp];
            });
            if (result == AVAssetImageGeneratorFailed) {
                NSLog(@"Failed with error: %@", [error localizedDescription]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RSProgressHUD showErrorWithStatus:[error localizedDescription]];
                });
                
            } else if (result == AVAssetImageGeneratorCancelled) {
                NSLog(@"Canceled");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RSProgressHUD showErrorWithStatus:@"取消编辑"];
                });
            }
            
            if (i + 1 == [times count]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RSProgressHUD dismiss];
                });
            }
        }
    }];
}



#pragma mark - Properties

- (CGFloat)leftPosition
{
    return _leftPosition * _durationSeconds / _frame_width;
}


- (CGFloat)rightPosition
{
    return _rightPosition * _durationSeconds / _frame_width;
}




#pragma mark - Bubble

- (void)hideBubble:(UIView *)popover
{
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         
                         _popoverBubble.alpha = 0;
                     }
                     completion:nil];
    
    if ([_delegate respondsToSelector:@selector(videoRange:didGestureStateEndedLeftPosition:rightPosition:)]){
        [_delegate videoRange:self didGestureStateEndedLeftPosition:self.leftPosition rightPosition:self.rightPosition];
        
    }
}


-(void) setTimeLabel{
    self.bubleText.text = [self trimIntervalStr];
    //NSLog([self timeDuration1]);
    //NSLog([self timeDuration]);
}


-(NSString *)trimDurationStr{
    int delta = floor(self.rightPosition - self.leftPosition);
    return [NSString stringWithFormat:@"%d", delta];
}


-(NSString *)trimIntervalStr{
    
    NSString *from = [self timeToStr:self.leftPosition];
    NSString *to = [self timeToStr:self.rightPosition];
    return [NSString stringWithFormat:@"%@ - %@", from, to];
}




#pragma mark - Helpers

- (NSString *)timeToStr:(CGFloat)time
{
    // time - seconds
    NSInteger min = floor(time / 60);
    NSInteger sec = floor(time - min * 60);
    NSString *minStr = [NSString stringWithFormat:min >= 10 ? @"%li" : @"0%li", (long)min];
    NSString *secStr = [NSString stringWithFormat:sec >= 10 ? @"%li" : @"0%li", (long)sec];
    return [NSString stringWithFormat:@"%@:%@", minStr, secStr];
}


-(BOOL)isRetina{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            
            ([UIScreen mainScreen].scale == 2.0));
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x <= 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
        return;
    }
    
//    NSLog(@"_bgView scntentSize width - contentoffset.x -> %f", scrollView.contentSize.width - scrollView.contentOffset.x);
    if (scrollView.contentSize.width - scrollView.contentOffset.x <= [self sliderScaleWidth] + BG_VIEW_BORDERS_SIZE * 2) {
        scrollView.contentOffset = CGPointMake(scrollView.contentSize.width - [self sliderScaleWidth] - BG_VIEW_BORDERS_SIZE * 2, 0);
        return;
    }
    
    double leftPoint = [self leftTime];
    if ([_delegate respondsToSelector:@selector(videoRange:didScrollStateWithLeftPosition:)]) {
        [_delegate videoRange:self didScrollStateWithLeftPosition:leftPoint];
    }
}

- (CGFloat)leftTime {
    return (((_bgView.contentOffset.x * 1000) / _bgView.contentSize.width) * _durationSeconds) / 1000;
}

- (void)didScrollShadowView:(UIPanGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _translation = 0;
    }

    CGFloat translation = [gesture translationInView:_shadowView].x;
    
    [_bgView setContentOffset:CGPointMake(_bgView.contentOffset.x - (translation - _translation), 0) animated:NO];
    _translation = translation;
}

- (void)didchangeSliderValue:(UISlider *)slider {

    @synchronized(slider) {
    if (slider.value <= _minGap) {
        slider.value = _minGap;
        _shadowView.transform = CGAffineTransformMakeTranslation([self sliderScaleWidth], 0);
        return;
    }
    
    if (slider.value >= _durationSeconds) {
        slider.value = _durationSeconds;
        _shadowView.transform = CGAffineTransformMakeTranslation([self sliderScaleWidth], 0);
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _shadowView.transform = CGAffineTransformMakeTranslation([self sliderScaleWidth], 0);
        if (_bgView.contentSize.width - _bgView.contentOffset.x <= [self sliderScaleWidth] && _currentValue < _slider.value && _bgView.contentOffset.x >= 0) {
            _bgView.contentOffset = CGPointMake(_bgView.contentSize.width - [self sliderScaleWidth], 0);
        }
        _currentValue = _slider.value;
        
        if ([_delegate respondsToSelector:@selector(videoRange:sliderValueDidChangeWithRightPosition:)]) {
            [_delegate videoRange:self sliderValueDidChangeWithRightPosition:[self sliderCurrentValue]];
        }
    });
    }
}

/*
 *    初步测试, slider的value 不是在最中间， 而是在最左边的时候， value的最小值是在拇指图的左边， value最大是在取的是拇指图最右边， 引起的偏差问题，
 */
- (CGFloat)sliderScaleWidth {
    CGFloat width = [_slider thumbImageForState:UIControlStateNormal].size.width;
    CGFloat value = (((_slider.value * 1000)/ _slider.maximumValue) * _slider.frame.size.width) / 1000;
    
    CGFloat tempWidth = width * _slider.value / _slider.maximumValue;
    
    return value + width / 2 - tempWidth;
}

- (CGFloat)sliderCurrentValue {
    CGFloat width = [_slider thumbImageForState:UIControlStateNormal].size.width;
    CGFloat tempWidth = width * _slider.value / _slider.maximumValue;
    CGFloat value = (width / 2 - tempWidth) * _slider.maximumValue / _slider.frame.size.width;
    return _slider.value + value;
}

- (void)setupThumbImage {
    CGFloat width = [_slider thumbImageForState:UIControlStateNormal].size.width;
    _thumbImageWidth = width;
    CGFloat tempWidth = width * _minGap / _maxGap;
    CGFloat value = (width / 2 - tempWidth) * _slider.maximumValue / _slider.frame.size.width;
    _thumbImageScaleValue = value;
}

@end
