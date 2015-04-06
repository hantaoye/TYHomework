//
//  MeituImageEditView.m
//  TestAPP
//
//  Created by yangyong on 14-6-4.
//  Copyright (c) 2014年 gainline. All rights reserved.
//


#import "RSMultiImageEditView.h"
#import "ImageHelper.h"
#define MRScreenWidth      CGRectGetWidth([UIScreen mainScreen].applicationFrame)
#define MRScreenHeight     CGRectGetHeight([UIScreen mainScreen].applicationFrame)

@interface RSMultiImageEditView (Utility)

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end

@interface RSImageEditView ()
- (void)initImageView;
@end

@implementation RSImageEditView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initImageView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initImageView];
    }
    return self;
}

- (void)initImageView {
    self.backgroundColor = [UIColor grayColor];
    _contentView = [[UIScrollView alloc] initWithFrame:[self bounds]];
    _contentView.delegate = self;
    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.showsVerticalScrollIndicator = NO;
    [self addSubview:_contentView];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MRScreenWidth * 2.5, MRScreenWidth * 2.5)];
    _imageView.userInteractionEnabled = YES;
    [_contentView addSubview:_imageView];
    
    UITapGestureRecognizer *doubleTapGestureImageView = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(handleDoubleTapImageView:)];
    [doubleTapGestureImageView setNumberOfTapsRequired:2];
    [_imageView addGestureRecognizer:doubleTapGestureImageView];
    
    float minimumScale = self.frame.size.width / _imageView.frame.size.width;
    [_contentView setMinimumZoomScale:minimumScale];
    [_contentView setZoomScale:minimumScale];
    
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

- (void)setImageViewData:(UIImage *)imageData {
    _image = imageData;
    if (imageData == nil) {
        return;
    }
    CGRect rect  = CGRectZero;
    CGFloat w = 0.0f;
    CGFloat h = 0.0f;
    
    if(self.contentView.frame.size.width > self.contentView.frame.size.height) {
        w = self.contentView.frame.size.width;
        h = w*imageData.size.height/imageData.size.width;
        if(h < self.contentView.frame.size.height){
            h = self.contentView.frame.size.height;
            w = h*imageData.size.width/imageData.size.height;
        }
        
    } else {
        
        h = self.contentView.frame.size.height;
        w = h*imageData.size.width/imageData.size.height;
        if(w < self.contentView.frame.size.width){
            w = self.contentView.frame.size.width;
            h = w*imageData.size.height/imageData.size.width;
        }
    }
    rect.size = CGSizeMake(w, h);
    
    CGFloat scale_w = 0; //w / imageData.size.width;
    CGFloat scale_h = 0;//h / imageData.size.height;
    if (w > self.frame.size.width || h > self.frame.size.height) {
        scale_w = w / self.frame.size.width;
        scale_h = h / self.frame.size.height;
        if (scale_w > scale_h) {
            //            scale = 1/scale_w;
        }else{
            //            scale = 1/scale_h;
        }
    }
    
    if (w <= self.frame.size.width || h <= self.frame.size.height) {
        scale_w = w / self.frame.size.width;
        scale_h = h / self.frame.size.height;
        if (scale_w > scale_h) {
            //            scale = scale_h;
        }else{
            //            scale = scale_w;
        }
    }
    @synchronized(self){
        self.imageView.frame = rect;
//        CAShapeLayer *maskLayer = [CAShapeLayer layer];
//        maskLayer.path = [self.realCellArea CGPath];
//        maskLayer.fillColor = [[UIColor redColor] CGColor];
//        self.layer.mask = maskLayer;
        [[self imageView] setImage:_image];
        [[self contentView] setZoomScale:0.2 animated:YES];
        [self setNeedsLayout];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    BOOL contained=[self.realCellArea containsPoint:point];
    if(self.tapDelegate && [self.tapDelegate respondsToSelector:@selector(tapWithEditView:)])
    {
        [self.tapDelegate tapWithEditView:self];
    }
    return contained;
}


#pragma mark - Zoom methods


- (void)handleDoubleTapImageView:(UIGestureRecognizer *)gesture {
    float newScale = _contentView.zoomScale * 1.2;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:_imageView]];
    [_contentView zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    if (scale == 0) {
        scale = 1;
    }
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    [scrollView setZoomScale:scale animated:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    return;
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    return;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    self.imageView.center = touch;
}

#pragma mark - View cycle
- (void)dealloc {
    _contentView  = nil;
    _imageView = nil;
}

@end

@implementation RSMultiImageEditView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initImageView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initImageView];
    }
    return self;
}

- (void)initImageView {
    [super initImageView];
    
    self.glView = [[RSFilterGLView alloc] initWithFrame:self.bounds];
    _glView.frame = CGRectMake(0, 0, MRScreenWidth * 2.5, MRScreenWidth * 2.5);
    
    _glView.userInteractionEnabled = YES;
    
    
//    [_imageView setClipsToBounds:YES];
//    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [[self contentView] addSubview:_glView];
    
    // Add gesture,double tap zoom imageView.
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [_glView addGestureRecognizer:doubleTapGesture];
    

    
    float minimumScale = self.frame.size.width / _glView.frame.size.width;
    [[self contentView] setMinimumZoomScale:minimumScale];
    [[self contentView] setZoomScale:minimumScale];
}



- (void)setImageViewData:(UIImage *)imageData {
//    [super setImageViewData:imageData];
    
    [self setImage:[ImageHelper doUnrotateImage:imageData withAngle:-90]];
    [_glView setFilterImage:[self image]];
    if (imageData == nil) {
        return;
    }
    
    CGRect rect  = CGRectZero;
    CGFloat w = 0.0f;
    CGFloat h = 0.0f;

    if(self.contentView.frame.size.width > self.contentView.frame.size.height) {
        w = self.contentView.frame.size.width;
        h = w*imageData.size.height/imageData.size.width;
        if(h < self.contentView.frame.size.height){
            h = self.contentView.frame.size.height;
            w = h*imageData.size.width/imageData.size.height;
        }
        
    } else {
    
        h = self.contentView.frame.size.height;
        w = h*imageData.size.width/imageData.size.height;
        if(w < self.contentView.frame.size.width){
            w = self.contentView.frame.size.width;
            h = w*imageData.size.height/imageData.size.width;
        }
    }
    rect.size = CGSizeMake(w, h);
    
    CGFloat scale_w = 0; //w / imageData.size.width;
    CGFloat scale_h = 0;//h / imageData.size.height;
    if (w > self.frame.size.width || h > self.frame.size.height) {
        scale_w = w / self.frame.size.width;
        scale_h = h / self.frame.size.height;
        if (scale_w > scale_h) {
//            scale = 1/scale_w;
        }else{
//            scale = 1/scale_h;
        }
    }
    
    if (w <= self.frame.size.width || h <= self.frame.size.height) {
        scale_w = w / self.frame.size.width;
        scale_h = h / self.frame.size.height;
        if (scale_w > scale_h) {
//            scale = scale_h;
        }else{
//            scale = scale_w;
        }
    }
    
    @synchronized(self){
        _glView.frame = rect;
        self.imageView.frame = rect;
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = [self.realCellArea CGPath];
        maskLayer.fillColor = [[UIColor redColor] CGColor];
        maskLayer.frame = _glView.frame;
        self.layer.mask = maskLayer;
        
        [_glView processViewWithImage:[self image] andCamType:0 andBlurImage:nil];
        
        [[self contentView] setZoomScale:0.2 animated:YES];
        
        [self setNeedsLayout];
        
    }
    
}


- (void)handleDoubleTap:(UIGestureRecognizer *)gesture {
    float newScale = [self contentView].zoomScale * 1.2;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:_glView]];
    [self.contentView zoomToRect:zoomRect animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [_glView isHidden] ? [self imageView] : _glView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [scrollView setZoomScale:scale animated:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    return;
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    return;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    self.glView.center = touch;
    self.imageView.center = touch;
}

#pragma mark - View cycle
- (void)dealloc {
    _glView = nil;
}

@end
