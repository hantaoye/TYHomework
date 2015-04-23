//
//  RSTrackEditPhotoViewController.m
//  FITogether
//
//  Created by closure on 12/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RSTrackEditPhotoViewController.h"
#import "RSMultiImageEditView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "RSEditTagOCViewController.h"
#import "RSFilterGLView.h"
#import "RSFilterEffectButtonScrollView.h"
#import "UIImage+TY.h"
#import "RSProgressHUD.h"
#import "TYDebugLog.h"
#import "TYWriteHelp.h"
#import "TYWirteNoteViewController.h"
#import "TYViewControllerLoader.h"

@interface RSTrackEditPhotoViewController () <ScrollButtonDelegate, RSImageEditViewDelegate>
@property (assign, nonatomic) BOOL initialized;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, strong) UIImage *croppedImage;
@property (weak, nonatomic) IBOutlet UILabel *remindLabel;

@property (weak, nonatomic) IBOutlet RSFilterEffectButtonScrollView *effectsView;
@property (nonatomic, weak) RSMultiImageEditView *currentEditView;
@end

@implementation RSTrackEditPhotoViewController
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (CGSize)sizeScaleWithSize:(CGSize)size scale:(CGFloat)scale
{
    if (scale<=0) {
        scale = 1.0f;
    }
    CGSize retSize = CGSizeZero;
    retSize.width = size.width/scale;
    retSize.height = size.height/scale;
    return  retSize;
}

-(UIImage*)glToUIImage:(RSFilterGLView *)glView {
    UIImage *theimage = [glView filterImage];
    CGFloat imageHeight = theimage.size.width;
    CGFloat imageWidth   = theimage.size.height;
    CGRect  rect = CGRectMake(0, 0, imageWidth, imageHeight);
    RSFilterGLView *theGlview = [[RSFilterGLView alloc] initWithFrame:rect andFilterType:glView.filterType];
    [theGlview setDisplayFramebuffer];
    [theGlview setupTextures];
    theGlview.touchAngle = glView.touchAngle;
    theGlview.touchX = glView.touchX;
    theGlview.touchY = glView.touchY;
    theGlview.touchScale = glView.touchScale;
    theGlview.touchScaleSmall  = glView.touchScaleSmall;
    theGlview.blurType = glView.blurType;
    theGlview.filterType = glView.filterType;
    theGlview.blurMaskAphle = 0.8;
    theGlview.filterImage = theimage;
    UIImage *image = [theGlview glToUIImage];
    theGlview = nil;
    return image;
}

//- (void)logGLView:(RSFilterGLView *)glView {
//    NSLog(@"%@", glView);
//    NSLog(@"[glView theScale] -> %f", [glView theScale]);
//    NSLog(@"[glView touchX] -> %f", [glView touchX]);
//    NSLog(@"[glView touchY] -> %f", [glView touchY]);
//    NSLog(@"[glView touchScale] -> %f", [glView touchScale]);
//    NSLog(@"[glView touchScaleSmall] -> %f", [glView touchScaleSmall]);
//}
//
//- (void)logScrollView:(UIScrollView *)scrollView {
//    NSLog(@"%@", scrollView);
//    NSLog(@"[scrollView contentOffset] -> %@", NSStringFromCGPoint([scrollView contentOffset]));
//    NSLog(@"[scrollView contentInset] -> %@", NSStringFromUIEdgeInsets([scrollView contentInset]));
//    NSLog(@"[scrollView contentScaleFactor] -> %f", ([scrollView contentScaleFactor]));
//    NSLog(@"[scrollView zoomScale] -> %f", ([scrollView zoomScale]));
//    NSLog(@"[scrollView minimumZoomScale] -> %f", ([scrollView minimumZoomScale]));
//    NSLog(@"[scrollView maximumZoomScale] -> %f", ([scrollView maximumZoomScale]));
//}
//
//- (void)logView:(MeituImageEditView *)view {
//    RSFilterGLView *glView = [view glView];
//    [self logGLView:glView];
//    [self logScrollView:[view contentView]];
//    NSLog(@"%@", [view imageView]);
//}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)donePressed {
    [RSProgressHUD show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSArray *subViews = [_contentView subviews];
        NSInteger cnt = [subViews count];
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:cnt];
        for (NSInteger idx = 0; idx < cnt; ++idx) {
            UIView *view = subViews[idx];
            if ([view isKindOfClass:[RSMultiImageEditView class]]) {
                RSMultiImageEditView *editView = (RSMultiImageEditView *)view;
                
                RSFilterGLView *glView = [editView glView];
                UIImage *result = [self glToUIImage:glView];
                [images addObject:result];
                editView.imageView.frame = glView.frame;
                editView.imageView.image = result;
                
                glView.hidden = YES;
            }
        }
        
        _croppedImage = [UIImage captureWithView:_contentView];
        
        for (NSInteger idx = 0; idx < cnt; ++idx) {
            UIView *view = subViews[idx];
            if ([view isKindOfClass:[RSMultiImageEditView class]]) {
                RSMultiImageEditView *editView = (RSMultiImageEditView *)view;
                RSFilterGLView *glView = [editView glView];
                editView.imageView.image = nil;
                glView.hidden = NO;
            }
        }
        [TYWriteHelp shareWriteHelp].image = _croppedImage;
        if ([TYWriteHelp shareWriteHelp].isStartWrite) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                
            }];
        } else {
            [self presentViewController:[[TYViewControllerLoader noteStoryboard] instantiateInitialViewController] animated:YES completion:^{
                
            }];
        }
//        [self performSegueWithIdentifier:@"segueForEditTag" sender:self];
        [RSProgressHUD dismiss];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueForEditTag"]) {
        RSEditTagOCViewController *editTagVC = segue.destinationViewController;
        editTagVC.editImage = _croppedImage;
    }
}

- (void)dealloc {
    [EAGLContext setCurrentContext:nil];
    if (_deleteAfterDone) {
        for (ALAsset *asset in _assets) {
            [asset setImageData:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    [TYDebugLog error:[error localizedDescription]];
                } else {
                    [TYDebugLog debug:@"remove asset success"];
                }
            }];
        }
    }
}

- (void)tapWithEditView:(RSMultiImageEditView *)sender {
    if (_currentEditView != sender) {
        _currentEditView = sender;
        RSFilterGLView *glView = _currentEditView.glView;
        UIImage *image = [_currentEditView image];
        [glView setDisplayFramebuffer];
        [glView setFilterImage:image];
        [glView processViewWithImage:image andCamType:0 andBlurImage:nil];
    }
    //    [_currentEditView.imageView swapBuffers];
    //    [_currentEditView.imageView processViewWithImage:[_currentEditView image] andCamType:0 andBlurImage:nil];
    //    NSInteger type = _currentEditView.imageView.filterType;
}

- (void)filterChangedWith:(int)filterType {
    if (_currentEditView.glView.filterType == filterType) {
        return;
    }
    RSFilterGLView *glView = _currentEditView.glView;
    UIImage *image = [_currentEditView image];
    glView.filterType = filterType;
    [glView setFilterImage:image];
    [glView processViewWithImage:image andCamType:0 andBlurImage:nil];
}

- (CGRect)rectScaleWithRect:(CGRect)rect scale:(CGFloat)scale
{
    if (scale<=0) {
        scale = 1.0f;
    }
    CGRect retRect = CGRectZero;
    retRect.origin.x = rect.origin.x/scale;
    retRect.origin.y = rect.origin.y/scale;
    retRect.size.width = rect.size.width/scale;
    retRect.size.height = rect.size.height/scale;
    return  retRect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.assets.count == 1) {
        self.remindLabel.text = @"你可以双指缩放边距和使用滤镜";
    } else if (self.assets.count == 2) {
        self.remindLabel.text = @"你可以分别对两张图片缩放、添加滤镜";
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [RSProgressHUD showWithMaskType:RSProgressHUDMaskTypeGradient];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view layoutIfNeeded];
    [self setupData];
//    [TalkingData beginTrack:[self class]];
    [RSProgressHUD dismiss];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [TalkingData endTrack:[self class]];
    [RSProgressHUD dismiss];
}

- (void)setupData {
    NSString *picCountFlag = @"";
    NSInteger cnt = [[self assets] count];
    switch (cnt) {
        case 1:
            picCountFlag = @"one";
            break;
        case 2:
            picCountFlag = @"two";
            break;
        case 3:
            picCountFlag = @"three";
            break;
        case 4:
            picCountFlag = @"four";
            break;
        case 5:
            picCountFlag = @"five";
            break;
        default:
            break;
    }
    NSString *styleName = [NSString stringWithFormat:@"number_%@_style_%d.plist",picCountFlag, 5];
    NSDictionary *styleDict = [NSDictionary dictionaryWithContentsOfFile:
                               [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:styleName]];
    
    [self selectBorderWithDict:styleDict];
    
}

- (void)selectBorderWithDict:(NSDictionary *)styleDict {
    if (styleDict) {
        CGSize superSize = CGSizeFromString(styleDict[@"SuperViewInfo"][@"size"]);
        superSize = [self sizeScaleWithSize:superSize scale:2.0f];
        
        NSArray *subViewArray = styleDict[@"SubViewArray"];
        for (NSInteger idx = 0; idx < [subViewArray count]; ++idx) {
            CGRect rect = CGRectZero;
            UIBezierPath *path = nil;
            UIImage *image = nil;
            ALAsset *asset = (self.assets)[idx];
            image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            NSDictionary *subDict = subViewArray[idx];
            if(subDict[@"frame"])
            {
                rect = CGRectFromString(subDict[@"frame"]);
                rect = [self rectScaleWithRect:rect scale:2.0f];
                rect.origin.x = rect.origin.x * _contentView.frame.size.width/superSize.width;
                rect.origin.y = rect.origin.y * _contentView.frame.size.height/superSize.height;
                rect.size.width = rect.size.width * _contentView.frame.size.width/superSize.width;
                rect.size.height = rect.size.height * _contentView.frame.size.height/superSize.height;
            }
            rect = [self rectWithArray:subDict[@"pointArray"] andSuperSize:superSize];
            
            
            [self drawWithDict:subDict path:path superSize:superSize rect:rect idx:idx image:image];
            
            //[self addImageViewWithFrame:rect idx:idx path:path image:image];
        }
    }
}

- (void)drawWithDict:(NSDictionary *)subDict path:(UIBezierPath *)path superSize:(CGSize)superSize rect:(CGRect)rect idx:(NSInteger)idx image:(UIImage *)image {
    if (subDict[@"pointArray"]) {
        NSArray *pointArray = subDict[@"pointArray"];
        path = [UIBezierPath bezierPath];
        if (pointArray.count > 2) {//当点的数量大于2个的时候
            //生成点的坐标
            for(int i = 0; i < [pointArray count]; i++)
            {
                NSString *pointString = pointArray[i];
                if (pointString) {
                    CGPoint point = CGPointFromString(pointString);
                    point = [self pointScaleWithPoint:point scale:2.0f];
                    point.x = (point.x)*_contentView.frame.size.width/superSize.width -rect.origin.x;
                    point.y = (point.y)*_contentView.frame.size.height/superSize.height -rect.origin.y;
                    if (i == 0) {
                        [path moveToPoint:point];
                    }else{
                        [path addLineToPoint:point];
                    }
                }
            }
        }else{
            //当点的左边不能形成一个面的时候  至少三个点的时候 就是一个正规的矩形
            //点的坐标就是rect的四个角
            [path moveToPoint:CGPointMake(0, 0)];
            [path addLineToPoint:CGPointMake(rect.size.width, 0)];
            [path addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
            [path addLineToPoint:CGPointMake(0, rect.size.height)];
        }
        [path closePath];
    }
    return [self addImageViewWithFrame:rect idx:idx path:path image:image];
}

- (void)addImageViewWithFrame:(CGRect)rect idx:(NSInteger)idx path:(UIBezierPath *)path image:(UIImage *)image {
    RSMultiImageEditView *imageView = [[RSMultiImageEditView alloc] initWithFrame:rect];
    if (!_currentEditView) {
        _currentEditView = imageView;
    }
    [imageView setClipsToBounds:YES];
    [imageView setBackgroundColor:[UIColor grayColor]];
    imageView.tag = idx;
    [path setLineWidth:1];
    imageView.realCellArea = path;
    imageView.tapDelegate = self;
    [imageView setImageViewData:image];
    //回调或者说是通知主线程刷新，
    [[self contentView] addSubview:imageView];
    imageView = nil;
    
}

- (CGPoint)pointScaleWithPoint:(CGPoint)point scale:(CGFloat)scale
{
    if (scale <= 0) {
        scale = 1.0f;
    }
    CGPoint retPointt = CGPointZero;
    retPointt.x = point.x/scale;
    retPointt.y = point.y/scale;
    return retPointt;
}

- (CGRect)rectWithArray:(NSArray *)array andSuperSize:(CGSize)superSize
{
    CGRect rect = CGRectZero;
    CGFloat minX = INT_MAX;
    CGFloat maxX = 0;
    CGFloat minY = INT_MAX;
    CGFloat maxY = 0;
    for (int i = 0; i < [array count]; i++) {
        NSString *pointString = array[i];
        CGPoint point = CGPointFromString(pointString);
        if (point.x <= minX) {
            minX = point.x;
        }
        if (point.x >= maxX) {
            maxX = point.x;
        }
        if (point.y <= minY) {
            minY = point.y;
        }
        if (point.y >= maxY) {
            maxY = point.y;
        }
        rect = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    }
    rect = [self rectScaleWithRect:rect scale:2.0f];
    rect.origin.x = rect.origin.x * _contentView.frame.size.width/superSize.width;
    rect.origin.y = rect.origin.y * _contentView.frame.size.height/superSize.height;
    rect.size.width = rect.size.width * _contentView.frame.size.width/superSize.width;
    rect.size.height = rect.size.height * _contentView.frame.size.height/superSize.height;
    return rect;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
