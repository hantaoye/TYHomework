//
//  TYAudioTool.m
//  MusicText
//
//  Created by qingyun on 14/11/2.
//  Copyright (c) 2014年 cn.TY. All rights reserved.
//

#import "TYAudioTool.h"
#import <AVFoundation/AVFoundation.h>

#define path(name) ([[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:name])

@implementation TYAudioTool

//装音效的字典
static NSMutableDictionary *_soundDict;
//装音乐的字典
static NSMutableDictionary *_musicDict;
//装录音的字典
static NSMutableDictionary *_recorderDict;

+ (void)initialize
{
    _soundDict = [NSMutableDictionary dictionary];
    _musicDict = [NSMutableDictionary dictionary];
    _recorderDict = [NSMutableDictionary dictionary];
    
    // 设置音频会话类型
    AVAudioSession *session = [AVAudioSession sharedInstance];
    //用这么表示在后台播放时， 只能播放这一个音乐软件
    [session setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [session setActive:YES error:nil];
}

#pragma mark -
#pragma mark 音效
/**
 *  播放音效
 *
 *  @param name 音效名称 或者路径
 */
+ (void)playSound:(NSString *)fileName
{
    if (!fileName) return;
    
    SystemSoundID soundID = [_soundDict[fileName] unsignedIntValue];
    
    //如果字典里没有， 就创建
    if (!soundID) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        if (!url) {
            url = [NSURL fileURLWithPath:fileName];
        }
        
        // 创建音效ID 并放入字典
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) url, &soundID);
        if (!soundID) return;
        
        _soundDict[fileName] = @(soundID);
    }
    //播放
    AudioServicesPlaySystemSound(soundID);
    
}

/**
 *  删除音效
 *
 *  @param name 音效名称
 */
+ (void)disposeSound:(NSString *)fileName
{
    if (!fileName) return;

    SystemSoundID soundID = [_soundDict[fileName] unsignedIntValue];
    if (soundID) {
        // 销毁音效ID
        AudioServicesDisposeSystemSoundID(soundID);
        [_soundDict removeObjectForKey:fileName];        // 从字典中移除
    }
}


#pragma mark -
#pragma mark 音乐
/**
 *  创建音乐
 *
 *  @param fileName 音乐名称 或者音乐路径
 */
+ (AVAudioPlayer *)createMusic:(NSString *)fileName
{
    if (!fileName) return nil;
    
    AVAudioPlayer *audioPlayer = _musicDict[fileName];
    
    //如果字典里没有， 就创建
    if (!audioPlayer) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        if (!url) {
            //如果沙盒没有， 看看是不是本地路径
            url = [NSURL fileURLWithPath:fileName];
        };
        
        // 创建音效ID 并放入字典
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        //如果传入的路径为空， 创建的audioPlayer是nil；
        if (!audioPlayer) return nil;
        
        [audioPlayer prepareToPlay];
        audioPlayer.enableRate = YES;
        _musicDict[fileName] = audioPlayer;
    }
    //返回
    return audioPlayer;
}

/**
 *  播放音乐
 *
 *  @param fileName 音乐名称 或者音乐路径
 */
+ (AVAudioPlayer *)playMusic:(NSString *)fileName
{
    AVAudioPlayer *audioPlayer = [self createMusic:fileName];
        //播放
    if (![audioPlayer isPlaying]) {
        [audioPlayer play];
    }
    return audioPlayer;
}


/**
 *  暂停音乐
 *
 *  @param fileName 音乐名称 或者音乐路径
 */
+ (void)pauseMusic
{
    AVAudioPlayer *audioPlayer = [self currentPlayingMusic];
    if (audioPlayer) {
        [audioPlayer pause];
    }
}

+ (void)pauseMusic:(NSString *)fileName
{
    if (!fileName) return;
    
    AVAudioPlayer *audioPlayer = _musicDict[fileName];
    
    //如果字典里没有，
    if (!audioPlayer) return;
    
    [audioPlayer pause];
}

/**
 *  停止音乐
 *
 *  @param fileName 音乐名称 或者音乐路径
 */
+ (void)stopMusic
{
    for (NSString *fileName in _musicDict) {
        AVAudioPlayer *audioPlayer = _musicDict[fileName];
      if ([audioPlayer isPlaying]) {
          [audioPlayer stop];
          [_musicDict removeObjectForKey:fileName];
          return;
        }
    }
}

+ (void)stopMusic:(NSString *)fileName
{
    if (!fileName) return;
    
    AVAudioPlayer *audioPlayer = _musicDict[fileName];
    
    //如果字典里没有，
    if (!audioPlayer) return;
    //停止
    [audioPlayer stop];
    
    [_musicDict removeObjectForKey:fileName];

}

/**
 *  返回正在播放音乐
 *
 *  @param return 正在播放的音乐对象
 */
+ (AVAudioPlayer *)currentPlayingMusic
{
    __block AVAudioPlayer *audioPlayer = nil;
    [_musicDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       AVAudioPlayer *player = obj;
        if (player.isPlaying) {
            audioPlayer = player;
            *stop = YES;
        }
    }];
    return audioPlayer;
}


#pragma mark -
#pragma mark 录音
/**
 *  创建录音对象
 *
 *  @param path路径（保存位置）
 *  @param fileName路径（保存位置在document下）
 */
+ (AVAudioRecorder *)createRecorderWithFileName:(NSString *)fileName
{
    if (!fileName) return nil;
    
    AVAudioRecorder *recorder = _recorderDict[fileName];
    
    if (!recorder) {
        
        NSURL *url = [NSURL fileURLWithPath:path(fileName)];
        NSLog(@"%@", url);
        //setting是固定格式，不用在意
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        // 音频格式
        NSNumber *formatObject = [NSNumber numberWithInt:kAudioFormatAppleIMA4];
        setting[AVFormatIDKey] = formatObject;
        // 音频通道数
        [setting setObject:@(2) forKey:AVNumberOfChannelsKey];//1表示单声道，2是立体声
        // 线性音频的位深度
        setting[AVLinearPCMBitDepthKey] = @(16);//采样位
        // 音频采样率
        setting[AVSampleRateKey] = @(16000.0);
        setting[AVEncoderAudioQualityKey] = @(AVAudioQualityHigh);
        
        NSError *error = nil;
        AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
        // 允许测量分贝
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            recorder.meteringEnabled = YES;
            //缓冲
            [recorder prepareToRecord];
            _recorderDict[fileName] = recorder;
        }
    }
    return recorder;
}

/**
 *  开始录音
 *
 *  @param fileName路径（保存位置在document下）
 */
+ (AVAudioRecorder *)startRecorder:(NSString *)fileName
{
    AVAudioRecorder *recorder = [self createRecorderWithFileName:fileName];
    //播放
    if (![recorder isRecording]) {
        [recorder record];
    }
    return recorder;
}

/**
 *  暂停录音
 *
 *  @param fileName路径（保存位置在document下）
 */
+ (void)pauseRecorder
{
    AVAudioRecorder *recorder = [self currentRecordering];
    if (recorder) {
        [recorder pause];
    }
}

+ (void)pauseRecorder:(NSString *)fileName
{
    if (!fileName) return;
    
    AVAudioRecorder *recorder = _recorderDict[fileName];
    if (recorder.isRecording) {
        [recorder pause];
    }
}

/**
 *  停止录音
 *
 *  @param name 录音名称
 */
+ (void)stopRecorder
{
    for (NSString *fileName in _recorderDict) {
        AVAudioRecorder *recorder = _recorderDict[fileName];

        if ([recorder isRecording]) {
            [recorder stop];
            [_recorderDict removeObjectForKey:fileName];
            return;
        }
    }
}

+ (void)stopRecorder:(NSString *)fileName
{
    if (!fileName) return;
    
    AVAudioRecorder *recorder = _recorderDict[fileName];
    
    //如果字典里没有，
    if (!recorder) return;
    //停止
    [recorder stop];
    [_recorderDict removeObjectForKey:fileName];
}

/**
 *  播放录音
 *
 *  @param fileName路径（保存位置在document下）
 */
+ (void)playRecorder:(NSString *)fileName
{
    [self playMusic:path(fileName)];
}

/**
 *  返回正在录音对象
 *
 *  @param return 正在录音的对象
 */
+ (AVAudioRecorder *)currentRecordering
{
    for (NSString *fileName in _recorderDict) {
        AVAudioRecorder *recorder = _recorderDict[fileName];
        if ([recorder isRecording]) {
            return recorder;
        }
    }
    return nil;
}

/**
 *  删除录音文件
 *
 *  @param fileName 录音文件名称
 */
+ (void)deleteRecording:(NSString *)fileName
{
    if (!fileName) return;
    
    AVAudioRecorder *recorder = _recorderDict[fileName];
 
    if (recorder) {
        [recorder stop];
        [recorder deleteRecording];
        [_recorderDict removeObjectForKey:fileName];
    }
}

    

@end
