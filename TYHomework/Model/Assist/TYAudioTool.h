//
//  TYAudioTool.h
//  MusicText
//
//  Created by qingyun on 14/11/2.
//  Copyright (c) 2014年 cn.TY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>



@interface TYAudioTool : NSObject

#pragma mark - 
#pragma mark 音效
/**
 *  播放音效
 *
 *  @param name 音效名称 或者路径
 */
+ (void)playSound:(NSString *)fileName;

/**
 *  删除音效
 *
 *  @param name 音效名称 或者路径
 */
+ (void)disposeSound:(NSString *)fileName;


#pragma mark -
#pragma mark 音乐
/**
 *  创建音乐
 *
 *  @param fileName 音乐名称 或者音乐路径
 *  @param return 创建的音乐对象
 */
+ (AVAudioPlayer *)createMusic:(NSString *)fileName;

/**
 *  播放音乐
 *
 *  @param fileName 音乐名称 或者音乐路径
 */
+ (AVAudioPlayer *)playMusic:(NSString *)fileName;

/**
 *  暂停音乐
 *
 *  @param fileName 音乐名称 或者音乐路径
 */
+ (void)pauseMusic;
+ (void)pauseMusic:(NSString *)fileName;

/**
 *  停止音乐
 *
 *  @param fileName 音乐名称 或者音乐路径
 */
+ (void)stopMusic;
+ (void)stopMusic:(NSString *)fileName;

/**
 *  返回正在播放音乐
 *
 *  @param return 正在播放的音乐对象
 */
+ (AVAudioPlayer *)currentPlayingMusic;


#pragma mark -
#pragma mark 录音
/**
 *  创建录音对象
 *
 *  @param fileName路径（保存位置在document下）
 *  @param return 录音对象
        caf 格式
 */
+ (AVAudioRecorder *)createRecorderWithFileName:(NSString *)fileName;

/**
 *  开始录音
 *
 *  @param fileName路径（保存位置在document下）
 */
+ (AVAudioRecorder *)startRecorder:(NSString *)fileName;

/**
 *  暂停录音
 *
 *  @param fileName路径（保存位置在document下）
 */
+ (void)pauseRecorder;
+ (void)pauseRecorder:(NSString *)fileName;

/**
 *  停止录音
 *
 *  @param name  录音文件名称
 */
+ (void)stopRecorder;
+ (void)stopRecorder:(NSString *)fileName;

/**
 *  返回正在录音对象
 *
 *  @param return 正在录音的对象
 */
+ (AVAudioRecorder *)currentRecordering;

/**
 *  播放录音
 *
 *  @param fileName路径（保存位置在document下）
 */
+ (void)playRecorder:(NSString *)fileName;

/**
 *  删除录音文件
 *
 *  @param fileName 录音文件名称
 */
+ (void)deleteRecording:(NSString *)fileName;
@end
