//
//  RSVideoAssetCompressor.m
//  FITogether
//
//  Created by closure on 3/9/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "RSVideoAssetCompressor.h"

//#import "NSError+RS.h"
#import "SBCaptureToolKit.h"

#define degreesToRadians(x) (x / 180.0) * M_PI

@interface __RyxVideoAssetCompressorQueueStorage : NSObject {
    
}
@property dispatch_queue_t videoWriterInputReadyQueue, audioWriterInputReadyQueue;
+ (dispatch_queue_t)_videoWriterInputReadyQueue;
+ (dispatch_queue_t)_audioWriterInputReadyQueue;
@end

@implementation __RyxVideoAssetCompressorQueueStorage

+ (instancetype)__storage {
    static dispatch_once_t onceToken;
    static __RyxVideoAssetCompressorQueueStorage *__storage = nil;
    dispatch_once(&onceToken, ^{
        __storage = [[self alloc] init];
    });
    return __storage;
}

- (instancetype)init {
    if (self = [super init]) {
        _videoWriterInputReadyQueue = dispatch_queue_create("com.RS-inc.videoService.videoWriterInputQueue", NULL);
        _audioWriterInputReadyQueue = dispatch_queue_create("com.RS-inc.videoService.audioWriterInputQueue", NULL);
    }
    return self;
}

+ (dispatch_queue_t)_videoWriterInputReadyQueue {
    return [[self __storage] videoWriterInputReadyQueue];
}

+ (dispatch_queue_t)_audioWriterInputReadyQueue {
    return [[self __storage] audioWriterInputReadyQueue];
}

@end

@interface RSVideoAssetCompressorAPLBitRateImpl : NSObject
@property (nonatomic, strong) AVAssetWriter *videoWriter;
- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL action:(void(^)(BOOL finished, NSError *error))action;
@end

@implementation RSVideoAssetCompressorAPLBitRateImpl

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL action:(void(^)(BOOL finished, NSError *error))action {
    //setup video writer
    AVAsset *videoAsset = [[AVURLAsset alloc] initWithURL:inputURL options:nil];
    AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo][0];
    CGSize videoSize = videoTrack.naturalSize;
    NSDictionary *videoWriterCompressionSettings =  @{AVVideoAverageBitRateKey: @1250000};
    NSDictionary *videoWriterSettings = @{AVVideoCodecKey: AVVideoCodecH264, AVVideoCompressionPropertiesKey: videoWriterCompressionSettings, AVVideoWidthKey: [NSNumber numberWithFloat:videoSize.width], AVVideoHeightKey: [NSNumber numberWithFloat:videoSize.height]};
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoWriterSettings];
    videoWriterInput.expectsMediaDataInRealTime = YES;
    videoWriterInput.transform = videoTrack.preferredTransform;
    _videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:nil];
    [_videoWriter addInput:videoWriterInput];
    
    //setup video reader
    NSDictionary *videoReaderSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoReaderSettings];
    AVAssetReader *videoReader = [[AVAssetReader alloc] initWithAsset:videoAsset error:nil];
    [videoReader addOutput:videoReaderOutput];
    
    //setup audio writer
    AVAssetWriterInput* audioWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeAudio
                                            outputSettings:nil];
    audioWriterInput.expectsMediaDataInRealTime = NO;
    [_videoWriter addInput:audioWriterInput];
    
    //setup audio reader
    AVAssetTrack* audioTrack = [videoAsset tracksWithMediaType:AVMediaTypeAudio][0];
    AVAssetReaderOutput *audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
    AVAssetReader *audioReader = [AVAssetReader assetReaderWithAsset:videoAsset error:nil];
    [audioReader addOutput:audioReaderOutput];
    [_videoWriter startWriting];
    
    //start writing from video reader
    [videoReader startReading];
    [_videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    [videoWriterInput requestMediaDataWhenReadyOnQueue:[__RyxVideoAssetCompressorQueueStorage _videoWriterInputReadyQueue] usingBlock: ^{
        while ([videoWriterInput isReadyForMoreMediaData]) {
            CMSampleBufferRef sampleBuffer;
            if ([videoReader status] == AVAssetReaderStatusReading &&
                (sampleBuffer = [videoReaderOutput copyNextSampleBuffer])) {
                [videoWriterInput appendSampleBuffer:sampleBuffer];
                CFRelease(sampleBuffer);
            } else {
                [videoWriterInput markAsFinished];
                if ([videoReader status] == AVAssetReaderStatusCompleted) {
                    //start writing from audio reader
                    [audioReader startReading];
                    [_videoWriter startSessionAtSourceTime:kCMTimeZero];
                    [audioWriterInput requestMediaDataWhenReadyOnQueue:[__RyxVideoAssetCompressorQueueStorage _audioWriterInputReadyQueue] usingBlock:^{
                        while (audioWriterInput.readyForMoreMediaData) {
                            CMSampleBufferRef sampleBuffer;
                            if ([audioReader status] == AVAssetReaderStatusReading &&
                                (sampleBuffer = [audioReaderOutput copyNextSampleBuffer])) {
                                [audioWriterInput appendSampleBuffer:sampleBuffer];
                                CFRelease(sampleBuffer);
                            } else {
                                [audioWriterInput markAsFinished];
                                if ([audioReader status] == AVAssetReaderStatusCompleted) {
                                    [_videoWriter endSessionAtSourceTime:videoAsset.duration];
                                    [_videoWriter finishWritingWithCompletionHandler:^(){
                                        action(YES, nil);
                                        _videoWriter = nil;
                                    }];
                                } else {
                                    [_videoWriter finishWritingWithCompletionHandler:^{
                                        action(NO, [audioReader error]);
                                        _videoWriter = nil;
                                    }];
                                }
                            }
                        }
                    }];
                } else {
                    
                    action(NO, [videoReader error]);
                    _videoWriter = nil;
                    return;
                }
            }
        }
    }];
}

@end

@implementation RSVideoAssetCompressor

+ (void)_exportVideo:(AVAsset *)asset outputPath:(NSString *)outputPath action:(void(^)(BOOL finished, NSError *error))action {
    AVAsset *anAsset = asset;
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                               initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
        // Implementation continues.
        
        NSURL *furl = [NSURL fileURLWithPath:outputPath];
        [[NSFileManager defaultManager] removeItemAtURL:furl error:nil];
        exportSession.outputURL = furl;
        exportSession.outputFileType = AVFileTypeMPEG4;
        //        CMTime start = CMTimeMakeWithSeconds(0, anAsset.duration.timescale);
        //        CMTime duration = CMTimeMakeWithSeconds(CMTimeGetSeconds(anAsset.duration), anAsset.duration.timescale);
        //        CMTimeRange range = CMTimeRangeMake(kCMTimeZero, anAsset.duration);
        //        exportSession.timeRange = range;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            BOOL finished = NO;
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@<%ld>", [[exportSession error] localizedDescription], (unsigned long)[[exportSession error] code]);
                    //                    dispatch_async(dispatch_get_main_queue(), ^{
                    //                        [RSProgressHUD dismiss];
                    //                    });
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    //                    dispatch_async(dispatch_get_main_queue(), ^{
                    //                        [RSProgressHUD dismiss];
                    //                    });
                    break;
                default:
                    finished = YES;
                    NSLog(@"NONE");
                    //                    dispatch_async(dispatch_get_main_queue(), ^{
                    //                        [RSProgressHUD showSuccessWithStatus:@"Success"];
                    //                    });
                    break;
            }
            action(finished, [exportSession error]);
        }];
    }
}

+ (void)compressVideoAsset:(AVURLAsset *)asset outputPath:(NSString *)outputPath action:(void (^)(AVURLAsset *avAsset, NSError *error))action {
    NSString *compressOutputFilePath = outputPath ?: [SBCaptureToolKit getVideoCompressedFilePathString];
    [[RSVideoAssetCompressorAPLBitRateImpl new] convertVideoToLowQuailtyWithInputURL:[asset URL] outputURL:[NSURL fileURLWithPath:compressOutputFilePath] action:^(BOOL finished, NSError *error) {
        if (finished && error == nil) {
            return action([[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:compressOutputFilePath] options:nil], error);
        }
        return action(nil, error);
    }];
}

+ (void)compressVideoAsset:(ALAsset *)asset inLibrary:(ALAssetsLibrary *)library action:(void (^)(AVURLAsset *avAsset, NSError *error))action {
    [self exportALAsset:asset inLibrary:library action:^(AVURLAsset *avAsset, NSError *error) {
        if (error) {
            return action(avAsset, error);
        }
        [self compressVideoAsset:avAsset outputPath:nil action:action];
    }];
}

+ (void)exportALAsset:(ALAsset *)asset inLibrary:(ALAssetsLibrary *)library action:(void (^)(AVURLAsset * avAsset, NSError *error))action {
    if (nil == asset || nil == library) {
        action(nil, [NSError errorWithDomain:@"error" code:1 userInfo:nil]);
        return;
    }
    ALAssetsLibraryAssetForURLResultBlock result = ^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        long long size = [rep size];
        uint8_t *buf = malloc(size);
        NSError *error = nil;
        [rep getBytes:buf fromOffset:0 length:size error:&error];
        if (error) {
            free(buf);
            return action(nil, error);
        }
        NSData *data = [[NSData alloc] initWithBytesNoCopy:buf length:size freeWhenDone:YES];
        NSString *outputFilePath = [SBCaptureToolKit getSaveFullFilePathString];
        BOOL success = [data writeToFile:outputFilePath atomically:YES];
        if (!success) {
            return action(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil]);
        }
        action([AVURLAsset assetWithURL:[NSURL fileURLWithPath:outputFilePath]], error);
    };
    
    ALAssetsLibraryAccessFailureBlock failure = ^(NSError *error) {
        action(nil, error);
    };
    
    [library assetForURL:[[asset defaultRepresentation] url] resultBlock:result failureBlock:failure];
    return;
}

+ (void)editAVAsset:(AVURLAsset *)asset outputPath:(NSString *)outputPath timeRange:(CMTimeRange)timeRange croppedRect:(CGRect)rect action:(void (^)(AVURLAsset * avAsset, NSError *error))action {
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    [self applyCropToVideoWithAsset:asset cropRect:rect timeRange:timeRange exportToURL:outputURL existingExportSession:nil completion:^(BOOL success, NSError *error, NSURL *videoUrl) {
        action(videoUrl ? [AVURLAsset assetWithURL:videoUrl] : nil, error);
    }];
}

+ (UIImageOrientation)getVideoOrientationFromAsset:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIImageOrientationLeft; //return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIImageOrientationRight; //return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIImageOrientationDown; //return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIImageOrientationUp;  //return UIInterfaceOrientationPortrait;
}

// apply the crop to passed video asset (set outputUrl to avoid the saving on disk ). Return the exporter session object
+ (AVAssetExportSession*)applyCropToVideoWithAsset:(AVURLAsset*)asset cropRect:(CGRect)cropRect timeRange:(CMTimeRange)cropTimeRange exportToURL:(NSURL*)outputUrl existingExportSession:(AVAssetExportSession*)exporter completion:(void(^)(BOOL success, NSError* error, NSURL* videoUrl))completion {
    //create an avassetrack with our asset
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //create a video composition and preset some settings
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, [clipVideoTrack nominalFrameRate]);
    
    CGFloat cropOffX = cropRect.origin.x;
    CGFloat cropOffY = cropRect.origin.y;
    CGFloat cropWidth = cropRect.size.width;
    CGFloat cropHeight = cropRect.size.height;

    CGSize ns = [clipVideoTrack naturalSize];
    CGSize rs = ns;
    CGFloat scale = 1.0;
    
    if (ns.width < ns.height) {
        rs.height = ns.width / cropWidth * cropHeight;
        scale = ns.width / cropWidth;
    } else {
        rs.width = ns.height / cropHeight * cropWidth;
        scale = ns.height / cropHeight;
    }
    
    cropOffX *= scale;
    cropOffY *= scale;
    
    videoComposition.renderSize = rs;
    
    //create a video instruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = cropTimeRange;
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    UIImageOrientation videoOrientation = [self getVideoOrientationFromAsset:asset];
    
    CGAffineTransform t1 = CGAffineTransformIdentity;
    CGAffineTransform t2 = CGAffineTransformIdentity;
    
    CGSize size = rs;
    
    switch (videoOrientation) {
        case UIImageOrientationUp:
            t1 = CGAffineTransformMakeTranslation(size.height - cropOffX, 0 - cropOffY );
            t2 = CGAffineTransformRotate(t1, M_PI_2 );
            break;
        case UIImageOrientationDown:
            t1 = CGAffineTransformMakeTranslation(0 - cropOffX, size.width - cropOffY ); // not fixed width is the real height in upside down
            t2 = CGAffineTransformRotate(t1, - M_PI_2 );
            break;
        case UIImageOrientationRight:
            t1 = CGAffineTransformMakeTranslation(0 - cropOffX, 0 - cropOffY );
            t2 = CGAffineTransformRotate(t1, 0 );
            break;
        case UIImageOrientationLeft:
            t1 = CGAffineTransformMakeTranslation(size.width - cropOffX, size.height - cropOffY );
            t2 = CGAffineTransformRotate(t1, M_PI  );
            break;
        default:
            NSLog(@"no supported orientation has been found in this video");
            break;
    }
    
    CGAffineTransform finalTransform = t2;
    [transformer setTransform:finalTransform atTime:cropTimeRange.start];
    
    //add the transformer layer instructions, then add to video composition
    instruction.layerInstructions = @[transformer];
    videoComposition.instructions = @[instruction];
    
    //Remove any prevouis videos at that path
    [[NSFileManager defaultManager]  removeItemAtURL:outputUrl error:nil];
    
    if (!exporter){
        exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
        [exporter setShouldOptimizeForNetworkUse:YES];
    }
    
    // assign all instruction for the video processing (in this case the transformation for cropping the video
    exporter.videoComposition = videoComposition;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.timeRange = cropTimeRange;
    
    if (outputUrl){
        
        exporter.outputURL = outputUrl;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exporter status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"crop Export failed: %@", [[exporter error] localizedDescription]);
                    if (completion){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(NO,[exporter error],nil);
                        });
                        return;
                    }
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"crop Export canceled");
                    if (completion){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(NO,nil,nil);
                        });
                        return;
                    }
                    break;
                default:
                    break;
            }
            
            if (completion){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES,nil,outputUrl);
                });
            }
            
        }];
    }
    
    return exporter;
}

+ (void)crop {
    
    //load our movie Asset
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"OriginalVideo" ofType:@"mov"]]];
    
    //create an avassetrack with our asset
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //create a video composition and preset some settings
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    //here we are setting its render size to its height x height (Square)
    videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height);
    
    //create a video instruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30));
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    //Here we shift the viewing square up to the TOP of the video so we only see the top
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0 );
    
    //Use this code if you want the viewing square to be in the middle of the video
    //CGAffineTransform t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) /2 );
    
    //Make sure the square is portrait
    CGAffineTransform t2 = CGAffineTransformRotate(t1, M_PI_2);
    
    CGAffineTransform finalTransform = t2;
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    //add the transformer layer instructions, then add to video composition
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    //Create an Export Path to store the cropped video
    NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *exportPath = [documentsPath stringByAppendingFormat:@"/CroppedVideo.mp4"];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    //Remove any prevouis videos at that path
    [[NSFileManager defaultManager] removeItemAtURL:exportUrl error:nil];
    
    //Export
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    exporter.videoComposition = videoComposition;
    exporter.outputURL = exportUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             //Call when finished
             [self exportDidFinish:exporter];
         });
     }];
}


+ (void)exportDidFinish:(AVAssetExportSession*)session {
    //Play the New Cropped video
    NSURL *outputURL = session.outputURL;
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:outputURL options:nil];
    AVPlayerItem * newPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
//    self.mPlayer = [AVPlayer playerWithPlayerItem:newPlayerItem];
//    [mPlayer addObserver:self forKeyPath:@"status" options:0 context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
}

@end

static inline CGFloat RadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
};

@implementation AVAsset (VideoOrientation)
@dynamic videoOrientation;

- (LBVideoOrientation)videoOrientation
{
    NSArray *videoTracks = [self tracksWithMediaType:AVMediaTypeVideo];
    if ([videoTracks count] == 0) {
        return LBVideoOrientationNotFound;
    }
    
    AVAssetTrack* videoTrack    = videoTracks[0];
    CGAffineTransform txf       = [videoTrack preferredTransform];
    CGFloat videoAngleInDegree  = RadiansToDegrees(atan2(txf.b, txf.a));
    
    LBVideoOrientation orientation = 0;
    switch ((int)videoAngleInDegree) {
        case 0:
            orientation = LBVideoOrientationRight;
            break;
        case 90:
            orientation = LBVideoOrientationUp;
            break;
        case 180:
            orientation = LBVideoOrientationLeft;
            break;
        case -90:
            orientation	= LBVideoOrientationDown;
            break;
        default:
            orientation = LBVideoOrientationNotFound;
            break;
    }
    
    return orientation;
}

@end
