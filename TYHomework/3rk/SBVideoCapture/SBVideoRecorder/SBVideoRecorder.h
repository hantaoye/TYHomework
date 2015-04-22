//
//  SBVideoRecorder.h
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-13.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM (NSUInteger, RSCameraMode) {
    RSCameraModeVideo = 0,
    RSCameraModePhoto
};
//typedef NS_ENUM(NSUInteger, RSCameraDevice) {
//    RSCameraDeviceBack = 0,
//    RSCameraDeviceFront
//};


extern NSString * const RSPhotoMetadataKey;
extern NSString * const RSPhotoJPEGKey;
extern NSString * const RSPhotoImageKey;
extern NSString * const RSPhotoThumbnailKey;

@class SBVideoRecorder;
@protocol SBVideoRecorderDelegate <NSObject>

@optional
//recorder开始录制一段视频时
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL;

//recorder完成一段视频的录制时
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error;

//recorder正在录制的过程中
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur;

//recorder删除了某一段视频
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error;

//recorder完成视频的合成
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL ;

/**
 *  recorder捕获图片
 */
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder capturedPhoto:(NSDictionary *)capturedPhoto error:(NSError *)error;
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder capturedImage:(UIImage *)image error:(NSError *)error;
/**
 *  将要改变捕获模式
 */
- (void)videoRecorderCameraModeWillChange:(SBVideoRecorder *)recorder;
- (void)videoRecorderCameraModeDidChange:(SBVideoRecorder *)recorder;
@end

@interface SBVideoRecorder : NSObject <AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

@property (weak, nonatomic) id <SBVideoRecorderDelegate> delegate;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (nonatomic, assign) RSCameraMode cameraMode;
//@property (nonatomic, assign) RSCameraDevice cameraDevice;

- (void)capturePhoto;
- (void)unfreezePreview;

@property (strong, nonatomic, readonly) NSURL *currentFileURL;
@property (nonatomic, assign, readonly, getter=isRecording) BOOL recording;

@property (NS_NONATOMIC_IOSONLY, getter=getTotalVideoDuration, readonly) CGFloat totalVideoDuration;

- (void)stopCurrentVideoRecording;

- (void)startRecordingWithFileURL:(NSURL *)url;

- (void)startRecording;
- (void)cancelRecording;

- (void)deleteLastVideo;//调用delegate
- (void)deleteAllVideo;//不调用delegate

@property (NS_NONATOMIC_IOSONLY, getter=getVideoCount, readonly) NSUInteger videoCount;

- (void)mergeVideoFiles;

@property (NS_NONATOMIC_IOSONLY, getter=isCameraSupported, readonly) BOOL cameraSupported;
@property (NS_NONATOMIC_IOSONLY, getter=isFrontCameraSupported, readonly) BOOL frontCameraSupported;
@property (NS_NONATOMIC_IOSONLY, getter=isTorchSupported, readonly) BOOL torchSupported;

- (void)switchCamera;
- (void)openTorch:(BOOL)open;

- (void)focusInPoint:(CGPoint)touchPoint;

- (void)reset;
@end

@interface UIImage (VideoThumbnail)
- (instancetype)initWithVideoURL:(NSURL *)URL;
@end

