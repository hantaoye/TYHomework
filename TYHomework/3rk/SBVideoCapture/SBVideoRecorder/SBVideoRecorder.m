//
//  SBVideoRecorder.m
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-13.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "SBVideoRecorder.h"
#import "SBCaptureDefine.h"
#import "SBCaptureToolKit.h"
#import <CoreAudio/CoreAudioTypes.h> 
#import "TYDebugLog.h"
#import <CoreImage/CoreImage.h>
#import <UIImage-ResizeMagick/UIImage+ResizeMagick.h>
#import <ImageIO/ImageIO.h>
#import "UIImage+TY.h"
#import "UIImage+Resize.h"

NSString * const RSPhotoMetadataKey = @"RSPhotoMetadataKey";
NSString * const RSPhotoJPEGKey = @"RSPhotoJPEGKey";
NSString * const RSPhotoImageKey = @"RSPhotoImageKey";
NSString * const RSPhotoThumbnailKey = @"RSPhotoThumbnailKey";

@interface SBVideoData: NSObject

@property (assign, nonatomic) CGFloat duration;
@property (strong, nonatomic) NSURL *fileURL;

@end

@implementation SBVideoData

@end

#define COUNT_DUR_TIMER_INTERVAL 0.05

@interface SBVideoRecorder ()
{
     AVCaptureDevice *frontCamera;
     AVCaptureDevice *backCamera;
     AVCaptureDevice *currentCamera;
    BOOL _isVideoReady;
}

@property (strong, nonatomic) NSTimer *countDurTimer;
@property (assign, nonatomic) CGFloat currentVideoDur;
@property (assign ,nonatomic) CGFloat totalVideoDur;

@property (strong, nonatomic) NSMutableArray *videoFileDataArray;

@property (assign, nonatomic) BOOL isFrontCameraSupported;
@property (assign, nonatomic) BOOL isCameraSupported;
@property (assign, nonatomic) BOOL isTorchSupported;
@property (assign, nonatomic) BOOL isTorchOn;
@property (assign, nonatomic) BOOL isUsingFrontCamera;

@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioDeviceInput;

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;

@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;

@property (strong, nonatomic) dispatch_queue_t dataSampleOutputQueue;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@property (strong, nonatomic) AVCaptureAudioDataOutput *audioOutput;

@property (strong, nonatomic) AVAssetWriter *videoWriter;
@property (strong, nonatomic) AVAssetWriterInput *videoWriterInput;
@property (strong, nonatomic) AVAssetWriterInput *audioWriterInput;

@property (assign, nonatomic) NSUInteger nFrame;
@property (assign, nonatomic) CMTime lastSampleTime;
@property (assign, nonatomic, getter=isPaused) BOOL paused;
@end

@implementation SBVideoRecorder

- (instancetype)init {
    if (self = [super init]) {
        [self initalize];
    }
    return self;
}

- (instancetype)initWithFileURL:(NSURL *)currentFileURL {
    self = [super init];
    if (self) {
        _currentFileURL = currentFileURL;
        [self initalize];
    }
    
    return self;
}

- (void)initalize
{
    NSString *filePath = [SBCaptureToolKit getSaveFilePathString];
    if (_cameraMode == RSCameraModePhoto) {
        _currentFileURL = [NSURL fileURLWithPath:[filePath stringByAppendingString:@".jpg"]];
    } else if (_cameraMode == RSCameraModeVideo) {
        _currentFileURL = [NSURL fileURLWithPath:[filePath stringByAppendingString:@".mp4"]];
    }
    
    _dataSampleOutputQueue = dispatch_queue_create("com.RS-inc.videoRecord.sampleQueue", 0);
    _sessionQueue = dispatch_queue_create("com.RS-inc.videoRecord.sessionQueue", DISPATCH_QUEUE_SERIAL);
    [self initCapture];
    self.videoFileDataArray = [[NSMutableArray alloc] init];
    self.totalVideoDur = 0.0f;
}

- (void)startCountDurTimer
{
    self.countDurTimer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DUR_TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)onTimer:(NSTimer *)timer
{
    self.currentVideoDur += COUNT_DUR_TIMER_INTERVAL;
    
    if ([_delegate respondsToSelector:@selector(videoRecorder:didRecordingToOutPutFileAtURL:duration:recordedVideosTotalDur:)]) {
        [_delegate videoRecorder:self didRecordingToOutPutFileAtURL:_currentFileURL duration:_currentVideoDur recordedVideosTotalDur:_totalVideoDur];
    }
    
    if (_totalVideoDur + _currentVideoDur >= MAX_VIDEO_DUR) {
        [self stopCurrentVideoRecording];
    }
}

- (void)stopCountDurTimer
{
    [_countDurTimer invalidate];
    self.countDurTimer = nil;
}

//必须是fileURL
//截取将会是视频的中间部分
//这里假设拍摄出来的视频总是高大于宽的

/*!
 @method mergeAndExportVideosAtFileURLs:
 
 @param fileURLArray
 包含所有视频分段的文件URL数组，必须是[NSURL fileURLWithString:...]得到的
 
 @discussion
 将所有分段视频合成为一段完整视频，并且裁剪为正方形
 */
- (void)mergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray
{
    NSError *error = nil;
    
    CGSize renderSize = CGSizeMake(0, 0);
    
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    CMTime totalDuration = kCMTimeZero;
    
    //先去assetTrack 也为了取renderSize
    NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
    NSMutableArray *assetArray = [[NSMutableArray alloc] init];
    for (NSURL *fileURL in fileURLArray) {
        AVAsset *asset = [AVAsset assetWithURL:fileURL];
        
        if (!asset) {
            continue;
        }
        
        [assetArray addObject:asset];
        
        AVAssetTrack *assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
        [assetTrackArray addObject:assetTrack];
        
        renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
        renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
    }
    
    CGFloat renderW = MIN(renderSize.width, renderSize.height);
    
    for (int i = 0; i < [assetArray count] && i < [assetTrackArray count]; i++) {
        
        AVAsset *asset = assetArray[i];
        AVAssetTrack *assetTrack = assetTrackArray[i];
        
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:[asset tracksWithMediaType:AVMediaTypeAudio][0]
                             atTime:totalDuration
                              error:nil];
        
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:assetTrack
                             atTime:totalDuration
                              error:&error];
        
        //fix orientationissue
        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
        
        CGFloat rate;
        rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
        
        CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0));//向上移动取中部影响
        layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
        
        [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstruciton setOpacity:0.0 atTime:totalDuration];
        
        //data
        [layerInstructionArray addObject:layerInstruciton];
    }
    
    //get save path
    NSURL *mergeFileURL = [NSURL fileURLWithPath:[SBCaptureToolKit getVideoMergeFilePathString]];
    
    //export
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderW);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishMergingVideosToOutPutFileAtURL:)]) {
                [_delegate videoRecorder:self didFinishMergingVideosToOutPutFileAtURL:mergeFileURL];
            }
        });
    }];
}

- (AVCaptureDevice *)getCameraDevice:(BOOL)isFront
{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionBack) {
            backCamera = camera;
        } else {
            frontCamera = camera;
        }
    }
    
    if (isFront) {
        return frontCamera;
    }
    
    return backCamera;
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = _previewLayer.bounds.size;
    
    AVCaptureVideoPreviewLayer *videopreviewLayer = self.previewLayer;//需要按照项目实际情况修改
    
    if([[videopreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        
        for(AVCaptureInputPort *port in [self.videoDeviceInput ports]) {//需要按照项目实际情况修改，必须是正在使用的videoInput
            if([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if([[videopreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspect]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if(point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if(point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if([[videopreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                    
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    //    NSLog(@"focus point: %f %f", point.x, point.y);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [_videoDeviceInput device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            if ([device isFocusPointOfInterestSupported]) {
                [device setFocusPointOfInterest:point];
            }
            
            if ([device isFocusModeSupported:focusMode]) {
                [device setFocusMode:focusMode];
            }
            
            if ([device isExposurePointOfInterestSupported]) {
                [device setExposurePointOfInterest:point];
            }
            
            if ([device isExposureModeSupported:exposureMode]) {
                [device setExposureMode:exposureMode];
            }
            
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        } else {
            [TYDebugLog errorFormat:@"对焦错误:%@", error];
        }
    });
}


#pragma mark - Method
- (void)focusInPoint:(CGPoint)touchPoint
{
    CGPoint devicePoint = [self convertToPointOfInterestFromViewCoordinates:touchPoint];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}



- (void)openTorch:(BOOL)open
{
    self.isTorchOn = open;
    if (!_isTorchSupported) {
        return;
    }
    
    AVCaptureTorchMode torchMode;
    if (open) {
        torchMode = AVCaptureTorchModeOn;
    } else {
        torchMode = AVCaptureTorchModeOff;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device lockForConfiguration:nil];
        [device setTorchMode:torchMode];
        [device unlockForConfiguration];
    });
}

- (void)switchCamera
{
    if (!_isFrontCameraSupported || !_isCameraSupported || !_videoDeviceInput) {
        return;
    }
    
    if (_isTorchOn) {
        [self openTorch:NO];
    }
    
    [_captureSession beginConfiguration];
    
    [_captureSession removeInput:_videoDeviceInput];
    
    self.isUsingFrontCamera = !_isUsingFrontCamera;
    AVCaptureDevice *device = [self getCameraDevice:_isUsingFrontCamera];
    
    [device lockForConfiguration:nil];
    if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [device unlockForConfiguration];
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [_captureSession addInput:_videoDeviceInput];
    [_captureSession commitConfiguration];
}

- (BOOL)isTorchSupported
{
    return _isTorchSupported;
}

- (BOOL)isFrontCameraSupported
{
    return _isFrontCameraSupported;
}

- (BOOL)isCameraSupported
{
    return _isFrontCameraSupported;
}

- (void)mergeVideoFiles
{
    NSMutableArray *fileURLArray = [[NSMutableArray alloc] init];
    for (SBVideoData *data in _videoFileDataArray) {
        [fileURLArray addObject:data.fileURL];
    }
    
    [self mergeAndExportVideosAtFileURLs:fileURLArray];
}

//总时长
- (CGFloat)getTotalVideoDuration
{
    return _totalVideoDur;
}

//现在录了多少视频
- (NSUInteger)getVideoCount
{
    return [_videoFileDataArray count];
}

- (void)startRecordingWithFileURL:(NSURL *)url {
    if (_totalVideoDur >= MAX_VIDEO_DUR) {
        NSLog(@"视频总长达到最大");
        return;
    }
    if (url) {
        _currentFileURL = url;
        [self _setupVideoWriter];
    }
    [self startRecording];
}

- (void)startRecording
{
    if (_totalVideoDur >= MAX_VIDEO_DUR) {
        [TYDebugLog debug:(@"视频总长达到最大")];
        return;
    }
    
    if (![_captureSession isRunning]) {
        [_captureSession startRunning];
    }
    
    self.currentVideoDur = 0.0f;
    [self startCountDurTimer];
    _recording = YES;
    _nFrame = 0;
    
    if ([_delegate respondsToSelector:@selector(videoRecorder:didStartRecordingToOutPutFileAtURL:)]) {
        [_delegate videoRecorder:self didStartRecordingToOutPutFileAtURL:_currentFileURL];
    }
    
    _paused = NO;
}

- (void)cancelRecording {
    [TYDebugLog debugFormat:@"%s", __func__];
    [self stopCountDurTimer];
    _paused = YES;
    [_captureSession beginConfiguration];
    dispatch_sync(_dataSampleOutputQueue, ^{
        [_videoWriter cancelWriting];
        [self _setupVideoWriter];
    });
    [_captureSession commitConfiguration];
}

- (void)stopCurrentVideoRecording
{
    if (!_recording) {
        return;
    }
    [TYDebugLog debugFormat:@"%s", __func__];
    [self stopCountDurTimer];
    _paused = YES;
    _recording = NO;
    @try {
        if ([_videoWriter status] > 0) {
            [_videoWriterInput markAsFinished];
            [_videoWriter endSessionAtSourceTime:_lastSampleTime];
            [_videoWriter finishWritingWithCompletionHandler:^{
//                [_captureSession stopRunning];
                self.totalVideoDur += _currentVideoDur;
                [TYDebugLog debugFormat:@"本段视频长度: %f", _currentVideoDur];
                [TYDebugLog debugFormat:@"现在的视频总长度: %f", _totalVideoDur];
                
                SBVideoData *data = [[SBVideoData alloc] init];
                data.duration = _currentVideoDur;
                data.fileURL = _currentFileURL;
                
                [_videoFileDataArray addObject:data];
                
                __block NSError *error = nil;
                NSDictionary *inputAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:@([_currentFileURL fileSystemRepresentation]) error:&error];
                if (inputAttributes) {
                    [TYDebugLog debugFormat:@"file size %lld KB", [inputAttributes fileSize] / 1024];
                } else {
                    [TYDebugLog errorFormat:@"%@", error.localizedDescription];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishRecordingToOutPutFileAtURL:duration:totalDur:error:)]) {
                        [_delegate videoRecorder:self didFinishRecordingToOutPutFileAtURL:_currentFileURL duration:_currentVideoDur totalDur:_totalVideoDur error:nil];
                    }
                });
            }];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }
}

//不调用delegate
- (void)deleteAllVideo
{
    for (SBVideoData *data in _videoFileDataArray) {
        NSURL *videoFileURL = data.fileURL;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *filePath = [[videoFileURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:filePath]) {
                NSError *error = nil;
                [fileManager removeItemAtPath:filePath error:&error];
                
                if (error) {
                    [TYDebugLog errorFormat:@"deleteAllVideo删除视频文件出错:%@", error];
                }
            }
        });
    }
}

//会调用delegate
- (void)deleteLastVideo
{
    if ([_videoFileDataArray count] == 0) {
        return;
    }
    
    SBVideoData *data = (SBVideoData *)[_videoFileDataArray lastObject];
    
    NSURL *videoFileURL = data.fileURL;
    CGFloat videoDuration = data.duration;
    
    [_videoFileDataArray removeLastObject];
    _totalVideoDur -= videoDuration;
    
    //delete
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [[videoFileURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:filePath error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //delegate
                if ([_delegate respondsToSelector:@selector(videoRecorder:didRemoveVideoFileAtURL:totalDur:error:)]) {
                    [_delegate videoRecorder:self didRemoveVideoFileAtURL:videoFileURL totalDur:_totalVideoDur error:error];
                }
            });
        }
    });
}

#pragma mark - AVCaptureFileOutputRecordignDelegate
- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler {
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    __block NSError *error = nil;
    NSDictionary *inputAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:@([inputURL fileSystemRepresentation]) error:&error];
    if (inputAttributes) {
        NSLog(@"start compressed %lld", [inputAttributes fileSize]);
    } else {
        NSLog(@"%@", error);
    }
    
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^ {
        NSDictionary *outputAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:@([outputURL fileSystemRepresentation]) error:&error];
        if (outputAttributes) {
            NSLog(@"start compressed %lld", [outputAttributes fileSize]);
        } else {
            NSLog(@"%@", error);
        }
        handler(exportSession);
    }];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    _currentFileURL = fileURL;
    
    self.currentVideoDur = 0.0f;
    [self startCountDurTimer];
    
    if ([_delegate respondsToSelector:@selector(videoRecorder:didStartRecordingToOutPutFileAtURL:)]) {
        [_delegate videoRecorder:self didStartRecordingToOutPutFileAtURL:fileURL];
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    _paused = YES;
    self.totalVideoDur += _currentVideoDur;
    NSLog(@"本段视频长度: %f", _currentVideoDur);
    NSLog(@"现在的视频总长度: %f", _totalVideoDur);
    
    if (!error) {
        SBVideoData *data = [[SBVideoData alloc] init];
        data.duration = _currentVideoDur;
        data.fileURL = outputFileURL;
        
        [_videoFileDataArray addObject:data];
    }
    NSURL *compressedOutputURL = [NSURL fileURLWithPath:[SBCaptureToolKit getVideoCompressedFilePathString]];
    [self convertVideoToLowQuailtyWithInputURL:outputFileURL outputURL:compressedOutputURL handler:^(AVAssetExportSession *session) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishRecordingToOutPutFileAtURL:duration:totalDur:error:)]) {
                [_delegate videoRecorder:self didFinishRecordingToOutPutFileAtURL:compressedOutputURL duration:_currentVideoDur totalDur:_totalVideoDur error:error];
            }
        });
    }];
}

- (void)_setupVideoWriter{
//    CMVideoDimensions videoDimensions;
//    if (sampleBuffer == nil) {
//        videoDimensions.width = 320;
//        videoDimensions.height = 320;
//    } else {
//        CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
//        CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
//        videoDimensions = dimensions;
//        int32_t min = MIN(dimensions.width, dimensions.height);
//        videoDimensions.width = min;
//        videoDimensions.height = min;
//    }
    NSDictionary* settings = @{AVVideoCodecKey: AVVideoCodecH264,
                               AVVideoCompressionPropertiesKey: @{AVVideoAverageBitRateKey: @(480000) ,
                                                                  AVVideoProfileLevelKey: AVVideoProfileLevelH264Main31,
                                                                  AVVideoMaxKeyFrameIntervalKey: @(30)},
                               AVVideoWidthKey: @(320),
                               AVVideoHeightKey: @(320),
                               AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill};
    
    _videoWriter = [[AVAssetWriter alloc] initWithURL:_currentFileURL fileType:AVFileTypeMPEG4 error:nil];
    NSParameterAssert(_videoWriter);
    _videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
    [_videoWriterInput setExpectsMediaDataInRealTime:YES];
    [_videoWriter addInput:_videoWriterInput];
    
    // Add the audio input
    AudioChannelLayout acl = {0};
    
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    
    
    NSDictionary* audioOutputSettings = nil;
    audioOutputSettings = @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                            AVNumberOfChannelsKey: @1,
                            AVSampleRateKey: @44100.0f,
                            AVEncoderBitRateKey: @64000,
                            AVChannelLayoutKey: [ NSData dataWithBytes: &acl length: sizeof( acl ) ]};
    
    _audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings: audioOutputSettings];
    
    _audioWriterInput.expectsMediaDataInRealTime = YES;
    [_videoWriter addInput:_audioWriterInput];
}

- (void)initCapture
{
    //session---------------------------------
    _paused = YES;
    self.captureSession = [[AVCaptureSession alloc] init];
    
  //decice
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionFront) {
            frontCamera = camera;
        } else {
            backCamera = camera;
        }
    }
    
    if (!backCamera) {
        self.isCameraSupported = NO;
        return;
    } else {
        self.isCameraSupported = YES;
        
        if ([backCamera hasTorch]) {
            self.isTorchSupported = YES;
        } else {
            self.isTorchSupported = NO;
        }
    }
    
    if (!frontCamera) {
        self.isFrontCameraSupported = NO;
    } else {
        self.isFrontCameraSupported = YES;
    }
    
    [backCamera lockForConfiguration:nil];
    if ([backCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    
    [backCamera unlockForConfiguration];
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
    
    [_captureSession addInput:_videoDeviceInput];
    
    _audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
    
    _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    _imageOutput = [[AVCaptureStillImageOutput alloc] init];
    [_imageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:nil];
    
//    [self _setupVideoWriter];
    //preview layer------------------
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:nil];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self _setupVideoWriter];
    [_captureSession commitConfiguration];
    [self _setupSession];
}

/**
 *  重新设置session 改变mode
 */
- (void)_setupSession {
    if (!_captureSession) {
        [TYDebugLog debug:@"error, no session running to setup"];
        return;
    }
//    BOOL shouldSwitchMode = (currentCamera == nil) || (_cameraMode != RSCameraModePhoto) ||
//    (_cameraMode != RSCameraModeVideo);
    
    [_captureSession beginConfiguration];
        
    [_captureSession removeOutput:_audioOutput];
    [_captureSession removeOutput:_imageOutput];
    [_captureSession removeOutput:_videoOutput];
    [_captureSession removeInput:_audioDeviceInput];

  
    currentCamera = self.videoDeviceInput.device;

    //output
    switch (_cameraMode) {
        case RSCameraModeVideo:
        {
            [_captureSession addInput:_audioDeviceInput];
            
            if ([_captureSession canAddOutput:_videoOutput]) {
                [_captureSession addOutput:_videoOutput];
                [_captureSession addOutput:_audioOutput];
                
                [_videoOutput setSampleBufferDelegate:self queue:_dataSampleOutputQueue];
                [_audioOutput setSampleBufferDelegate:self queue:_dataSampleOutputQueue];
                [_videoOutput setAlwaysDiscardsLateVideoFrames:YES];
            }
        }
            break;
        case RSCameraModePhoto:
        {
            if ([_captureSession canAddOutput:_imageOutput]) {
                [_captureSession addOutput:_imageOutput];
            }
            
        }
            break;
        default:
            break;
    }
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _videoOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    if ([videoConnection isVideoOrientationSupported]) {
        videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    //preset
    if (_cameraMode == RSCameraModeVideo) {
        _captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    } else {
        _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        // setup photo settings
        NSDictionary *photoSettings = @{
                                        AVVideoCodecKey : AVVideoCodecJPEG,
                                        AVVideoWidthKey: @(320),
                                        AVVideoHeightKey: @(320),
                                        AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill
                                        };
        [_imageOutput setOutputSettings:photoSettings];
        
        // setup photo device configuration
        NSError *error = nil;
        if ([currentCamera lockForConfiguration:&error]) {
            
            if ([currentCamera isLowLightBoostSupported])
                [currentCamera setAutomaticallyEnablesLowLightBoostWhenAvailable:YES];
            
            [currentCamera unlockForConfiguration];
            
        } else if (error) {
            NSLog(@"error locking device for photo device configuration %@", error.localizedDescription);
        }
    }
    _previewLayer.session = _captureSession;
    [self unfreezePreview];
    [_captureSession commitConfiguration];
    if (![_captureSession isRunning]) {
        [_captureSession startRunning];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"capturingStillImage"]) {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        if (isCapturingStillImage) {
            [self freezePreview];
        }
    }
}

- (void)freezePreview
{
    if (_previewLayer)
        _previewLayer.connection.enabled = NO;
}

- (void)unfreezePreview
{
    if (_previewLayer)
        _previewLayer.connection.enabled = YES;
}

- (void)dealloc {
    [_imageOutput removeObserver:self forKeyPath:@"capturingStillImage"];
    _imageOutput = nil;
}

#pragma mark - AVCaptureSession

- (BOOL)_canSessionCaptureWithOutput:(AVCaptureOutput *)captureOutput
{
    BOOL sessionContainsOutput = [[_captureSession outputs] containsObject:captureOutput];
    BOOL outputHasConnection = ([captureOutput connectionWithMediaType:AVMediaTypeVideo] != nil);
    return (sessionContainsOutput && outputHasConnection);
}

- (UIImageOrientation)_imageOrientationFromExifOrientation:(NSInteger)exifOrientation
{
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    
    switch (exifOrientation) {
        case 2:
            imageOrientation = UIImageOrientationUpMirrored;
            break;
        case 3:
            imageOrientation = UIImageOrientationDown;
            break;
        case 4:
            imageOrientation = UIImageOrientationDownMirrored;
            break;
        case 5:
            imageOrientation = UIImageOrientationLeftMirrored;
            break;
        case 6:
            imageOrientation = UIImageOrientationRight;
            break;
        case 7:
            imageOrientation = UIImageOrientationRightMirrored;
            break;
        case 8:
            imageOrientation = UIImageOrientationLeft;
            break;
        case 1:
        default:
            // UIImageOrientationUp;
            break;
    }
    
    return imageOrientation;
}

#pragma mark -
#pragma mark photo
- (UIImage *)_uiimageFromJPEGData:(NSData *)jpegData
{
    CGImageRef jpegCGImage = NULL;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)jpegData);
    
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    
    if (provider) {
        CGImageSourceRef imageSource = CGImageSourceCreateWithDataProvider(provider, NULL);
        if (imageSource) {
            if (CGImageSourceGetCount(imageSource) > 0) {
                jpegCGImage = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
                
                // extract the cgImage properties
                CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
                if (properties) {
                    // set orientation
                    CFNumberRef orientationProperty = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
                    if (orientationProperty) {
                        NSInteger exifOrientation = 1;
                        CFNumberGetValue(orientationProperty, kCFNumberIntType, &exifOrientation);
                        imageOrientation = [self _imageOrientationFromExifOrientation:exifOrientation];
                    }
                    
                    CFRelease(properties);
                }
                
            }
            CFRelease(imageSource);
        }
        CGDataProviderRelease(provider);
    }
    
    UIImage *image = nil;
    if (jpegCGImage) {
        size_t width = CGImageGetWidth(jpegCGImage);
        size_t height = CGImageGetHeight(jpegCGImage);
        size_t WH = MIN(width, height);
        size_t moreLength;
        CGImageRef cgImage = NULL;
        if (height >= width) {
            moreLength = (height - width) / 2;
            cgImage = CGImageCreateWithImageInRect(jpegCGImage, CGRectMake(0, moreLength, WH, WH));
        } else {
            moreLength = (width - height) / 2;
            cgImage = CGImageCreateWithImageInRect(jpegCGImage, CGRectMake(moreLength, 0, WH, WH));
        }
        
        image = [[UIImage alloc] initWithCGImage:cgImage scale:1.0 orientation:imageOrientation];
        CGImageRelease(jpegCGImage);
        CGImageRelease(cgImage);
    }
    return image;
}

- (UIImage *)_thumbnailJPEGData:(NSData *)jpegData
{
    CGImageRef thumbnailCGImage = NULL;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)jpegData);
    
    if (provider) {
        CGImageSourceRef imageSource = CGImageSourceCreateWithDataProvider(provider, NULL);
        if (imageSource) {
            if (CGImageSourceGetCount(imageSource) > 0) {
                NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithCapacity:3];
                options[(id)kCGImageSourceCreateThumbnailFromImageAlways] = @(YES);
                options[(id)kCGImageSourceThumbnailMaxPixelSize] = @(160.0f);
                options[(id)kCGImageSourceCreateThumbnailWithTransform] = @(YES);
                thumbnailCGImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
            }
            CFRelease(imageSource);
        }
        CGDataProviderRelease(provider);
    }
    
    UIImage *thumbnail = nil;
    if (thumbnailCGImage) {
        size_t width = CGImageGetWidth(thumbnailCGImage);
        size_t height = CGImageGetHeight(thumbnailCGImage);
        size_t WH = MIN(width, height);
        size_t moreLength;
        CGImageRef cgImage = NULL;
        if (height >= width) {
            moreLength = (height - width) / 2;
            cgImage = CGImageCreateWithImageInRect(thumbnailCGImage, CGRectMake(0, moreLength, WH, WH));
        } else {
            moreLength = (width - height) / 2;
            cgImage = CGImageCreateWithImageInRect(thumbnailCGImage, CGRectMake(moreLength, 0, WH, WH));
        }

        thumbnail = [[UIImage alloc] initWithCGImage:thumbnailCGImage];
        CGImageRelease(thumbnailCGImage);
        CGImageRelease(cgImage);
    }
    return thumbnail;
}

- (void)capturePhoto
{
    if (![self _canSessionCaptureWithOutput:_imageOutput] || _cameraMode != RSCameraModePhoto) {
        NSLog(@"session is not setup properly for capture");
        return;
    }
    
    AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (!imageDataSampleBuffer) {
            [TYDebugLog debug:@"failed to obtain image data sample buffer"];
            return;
        }

        if (error) {
            if ([_delegate respondsToSelector:@selector(videoRecorder:capturedPhoto:error:)]) {
                [_delegate videoRecorder:self capturedImage:nil error:error];
            }
            return;
        }
//        CFDictionaryRef exifAttachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        
        CGFloat squareLength = [[UIScreen mainScreen] applicationFrame].size.width;
        CGFloat headHeight = _previewLayer.bounds.size.height - squareLength;//_previewLayer的frame是(0, 44, 320, 320 + 44)
        CGSize size = CGSizeMake(squareLength * 2, squareLength * 2);
        
        UIImage *scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:size interpolationQuality:kCGInterpolationHigh];
        
        CGRect cropFrame = CGRectMake((scaledImage.size.width - size.width) / 2, (scaledImage.size.height - size.height) / 2 + headHeight, size.width, size.height);
        UIImage *croppedImage = [scaledImage croppedImage:cropFrame];
        
        
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation != UIDeviceOrientationPortrait) {
            
            CGFloat degree = 0;
            if (orientation == UIDeviceOrientationPortraitUpsideDown) {
                degree = 180;// M_PI;
            } else if (orientation == UIDeviceOrientationLandscapeLeft) {
                degree = -90;// -M_PI_2;
            } else if (orientation == UIDeviceOrientationLandscapeRight) {
                degree = 90;// M_PI_2;
            }
            croppedImage = [croppedImage rotatedByDegrees:degree];
        }
        
        if (croppedImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(videoRecorder:capturedImage:error:)]) {
                    [_delegate videoRecorder:self capturedImage:croppedImage error:error];
                }
            });
        }
//        // add any attachments to propagate
//        NSDictionary *tiffDict = @{ (NSString *)kCGImagePropertyTIFFSoftware : @"FITogether",
//                                    (NSString *)kCGImagePropertyTIFFDateTime : [SBCaptureToolKit getImageDateString:[NSDate date]] };
//        CMSetAttachment(imageDataSampleBuffer, kCGImagePropertyTIFFDictionary, (__bridge CFTypeRef)(tiffDict), kCMAttachmentMode_ShouldPropagate);
//        
//        NSMutableDictionary *photoDict = [[NSMutableDictionary alloc] init];
//        NSDictionary *metadata = nil;
//        
//        // add photo metadata (ie EXIF: Aperture, Brightness, Exposure, FocalLength, etc)
//        metadata = (__bridge NSDictionary *)CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
//        if (metadata) {
//            photoDict[RSPhotoMetadataKey] = metadata;
//            CFRelease((__bridge CFTypeRef)(metadata));
//        } else {
//            [TYDebugLog debug:@"failed to generate metadata for photo"];
//        }
//        
//        // add JPEG, UIImage, thumbnail
//        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//#if 0
//        if (jpegData) {
//            // add JPEG
//            photoDict[RSPhotoJPEGKey] = jpegData;
//            
//            // add image
//            UIImage *image = [self _uiimageFromJPEGData:jpegData];
//            if (image) {
//                photoDict[RSPhotoImageKey] = image;
//            } else {
//                [TYDebugLog debug:@"failed to create image from JPEG"];
//                error = [NSError errorWithDomain:@"RS-inc.errorDomain" code:104 userInfo:nil];
//            }
//            
//        // add thumbnail
//            UIImage *thumbnail = [self _thumbnailJPEGData:jpegData];
//            if (thumbnail) {
//                    photoDict[RSPhotoThumbnailKey] = thumbnail;
//            }
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([_delegate respondsToSelector:@selector(videoRecorder:capturedPhoto:error:)]) {
//                [_delegate videoRecorder:self capturedPhoto:photoDict error:error];
//            }
//        });
//#else 
//        if (jpegData) {
//            // add JPEG
////            photoDict[RSPhotoJPEGKey] = jpegData;
//            
//            // add image
//            UIImage *image = [self _uiimageFromJPEGData:jpegData];
//
//            if (image) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if ([_delegate respondsToSelector:@selector(videoRecorder:capturedImage:error:)]) {
//                        [_delegate videoRecorder:self capturedImage:image error:error];
//                    }
//                });
//            }
//        }
//#endif
//        // run a post shot focus
//        [self performSelector:@selector(_adjustFocusExposureAndWhiteBalance) withObject:nil afterDelay:0.5f];
    }];
}


#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }
    if (_paused) {
        return;
    }
    
    _lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    if((self.nFrame == 0) && (_videoWriter.status != AVAssetWriterStatusWriting)) {
        @try {
            if ([_videoWriter startWriting]) {
                NSLog(@"start writing data");
                [_videoWriter startSessionAtSourceTime:_lastSampleTime];
                self.nFrame = 1;
            } else {
                NSLog(@"start writing data failed with error -> %@", [_videoWriter error]);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"videoWriter startWriting err!");
        }
        @finally {
        }
    }
    if(captureOutput == _videoOutput) {
        if( _videoWriter.status > AVAssetWriterStatusWriting ) {
            if( _videoWriter.status == AVAssetWriterStatusFailed ) {
                NSLog(@"Error（%ld）: %@", (unsigned long)self.nFrame, _videoWriter.error);
            }
            return;
        }
        
        if( ![_videoWriterInput appendSampleBuffer:sampleBuffer] )
            NSLog(@"Unable to write to video input,status = %ld,frame = %ld", (unsigned long)_videoWriter.status, (unsigned long)self.nFrame);
        self.nFrame++;
    } else if (captureOutput == _audioOutput) {
        if( _videoWriter.status > AVAssetWriterStatusWriting ) {
            NSLog(@"Warning: writer status is %ld", (unsigned long)_videoWriter.status);
            if( _videoWriter.status == AVAssetWriterStatusFailed )
                NSLog(@"Error: %@", _videoWriter.error);
            return;
        }
        if( ![_audioWriterInput appendSampleBuffer:sampleBuffer] ) {
            NSLog(@"Unable to write to audio input");
        } else {
            NSLog(@"add data to audio input");
        }
    }
}

- (void)reset {
//    _paused = YES;
//    _nFrame = 0;
//    [_videoWriter cancelWriting];
//    [_captureSession stopRunning];
//    _captureSession = nil;
//    [self initalize];
//    return;
}

- (void)setCameraMode:(RSCameraMode)cameraMode {
    if (_cameraMode == cameraMode) {
        return;
    }
    [self _setCameraMode:cameraMode];
}

- (void)_setCameraMode:(RSCameraMode)cameraMode {
    BOOL changeMode = (_cameraMode != cameraMode);
    
    if (!changeMode) {
        return;
    }
    
//    if (changeDevice && [_delegate respondsToSelector:@selector(visionCameraDeviceWillChange:)]) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//        [_delegate performSelector:@selector(visionCameraDeviceWillChange:) withObject:self];
//#pragma clang diagnostic pop
//    }
    if (changeMode && [_delegate respondsToSelector:@selector(videoRecorderCameraModeWillChange:)]) {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_delegate performSelector:@selector(videoRecorderCameraModeWillChange:) withObject:self];
    }
    _cameraMode = cameraMode;
    
    void (^didChangeBlock)() = ^{
        
//        if (changeDevice && [_delegate respondsToSelector:@selector(visionCameraDeviceDidChange:)]) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//            [_delegate performSelector:@selector(visionCameraDeviceDidChange:) withObject:self];
//#pragma clang diagnostic pop
//        }
        if (changeMode && [_delegate respondsToSelector:@selector(videoRecorderCameraModeDidChange:)]) {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_delegate performSelector:@selector(videoRecorderCameraModeDidChange:) withObject:self];
        }
    };
    
    // since there is no session in progress, set and bail
    if (!_captureSession) {
        didChangeBlock();
        return;
    }
    [self _enqueueBlockOnCaptureSessionQueue:^{
        // camera is already setup, no need to call _setupCamera
        [self _setupSession];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            didChangeBlock();
        });
    }];
}

- (void)_enqueueBlockOnCaptureSessionQueue:(void(^)())block {
    dispatch_async(_sessionQueue, ^{
        block();
    });
}

@end

@implementation UIImage (VideoThumbnail)

- (instancetype)initWithVideoURL:(NSURL *)URL {
    AVAsset *asset = [AVAsset assetWithURL:URL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time = CMTimeMake(0, 30);
    NSError *error = nil;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
    if (error) {
        NSLog(@"video image generator error -> %@", error);
    }
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    return thumbnail;
}

@end