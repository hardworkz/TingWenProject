//
//  VoiceReader.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/4/12.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "VoiceReader.h"
#import <AVFoundation/AVSpeechSynthesis.h>

@interface VoiceReader()<AVSpeechSynthesizerDelegate>
{
    AVSpeechSynthesizer *_avSpeaker;
}
@property (strong, nonatomic) AVSpeechUtterance *utterance;
@end
@implementation VoiceReader
+ (instancetype)voiceReaderManager
{
    static VoiceReader * reader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reader = [[VoiceReader alloc]init];
    });
    return reader;
}
- (instancetype)init
{
    if (self == [super init]) {
        //初始化语音合成器
        _avSpeaker = [[AVSpeechSynthesizer alloc] init];
        _avSpeaker.delegate = self;
        
        //播放器状态改变
        RegisterNotify(SONGPLAYSTATUSCHANGE, @selector(playStatusChange:))

    }
    return self;
}
- (BOOL)isReading
{
    return _avSpeaker.isSpeaking;
}
- (BOOL)isPause
{
    return _avSpeaker.isPaused;
}
- (void)setReadRate:(CGFloat)readRate
{
    _readRate = readRate;
    [CommonCode writeToUserD:@([VoiceReader voiceReaderManager].readRate) andKey:@"read_rate"];
    _utterance.rate = readRate;
    [self stopReader];
    [self starReaderWithReaderString:self.readString];
}
#pragma mark -通知- 播放状态改变
- (void)playStatusChange:(NSNotification *)note
{
    switch ([ZRT_PlayerManager manager].status) {
        case ZRTPlayStatusPlay:
            //暂停新闻播放器
            if ([ZRT_PlayerManager manager].isPlaying) {
                [[ZRT_PlayerManager manager] pausePlay];
            }
            break;
        case ZRTPlayStatusPause:
            break;
        case ZRTPlayStatusStop:
            break;
        default:
            break;
    }
}
- (void)starReaderWithReaderString:(NSString *)string
{
    [[IflyVoiceReader iflyVoiceReaderManager] stopReader];
    if (_avSpeaker.isPaused) {
        [self continueReader];
    }else{
        [self stopReader];
        _avSpeaker = [[AVSpeechSynthesizer alloc] init];
        _avSpeaker.delegate = self;
        //初始化要说出的内容
        _utterance = [[AVSpeechUtterance alloc] initWithString:string];
        //设置语速,语速介于AVSpeechUtteranceMaximumSpeechRate和AVSpeechUtteranceMinimumSpeechRate之间
//        RTLog(@"%f",AVSpeechUtteranceMaximumSpeechRate);
//        RTLog(@"%f",AVSpeechUtteranceMinimumSpeechRate);
//        RTLog(@"%f",AVSpeechUtteranceDefaultSpeechRate);
        
        _utterance.rate = [[CommonCode readFromUserD:@"read_rate"] floatValue];
        
        //设置音高,[0.5 - 2] 默认 = 1
        //AVSpeechUtteranceMaximumSpeechRate
        //AVSpeechUtteranceMinimumSpeechRate
        //AVSpeechUtteranceDefaultSpeechRate
        _utterance.pitchMultiplier = 1;
        
        //设置音量,[0-1] 默认 = 1
        _utterance.volume = 1;
        
        //读一段前的停顿时间
        _utterance.preUtteranceDelay = 1;
        //读完一段后的停顿时间
        _utterance.postUtteranceDelay = 1;
        
        //设置声音,是AVSpeechSynthesisVoice对象
        //AVSpeechSynthesisVoice定义了一系列的声音, 主要是不同的语言和地区.
        //voiceWithLanguage: 根据制定的语言, 获得一个声音.
        //speechVoices: 获得当前设备支持的声音
        //currentLanguageCode: 获得当前声音的语言字符串, 比如”ZH-cn”
        //language: 获得当前的语言
        //通过特定的语言获得声音
        AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
        //通过voicce标示获得声音
        //AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithIdentifier:AVSpeechSynthesisVoiceIdentifierAlex];
        _utterance.voice = voice;
        //暂停新闻播放器
        if ([ZRT_PlayerManager manager].isPlaying) {
            [[ZRT_PlayerManager manager] pausePlay];
        }
        //停止上一条
        [self stopReader];
        //开始朗读
        [_avSpeaker speakUtterance:_utterance];
    }
}
- (void)pauseReader
{
    //暂停朗读
    //AVSpeechBoundaryImmediate 立即停止
    //AVSpeechBoundaryWord    当前词结束后停止
    [_avSpeaker pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}
- (void)continueReader
{
    //暂停新闻播放器
    if ([ZRT_PlayerManager manager].isPlaying) {
        [[ZRT_PlayerManager manager] pausePlay];
    }
    //继续播放
    [_avSpeaker continueSpeaking];
}
- (void)stopReader
{
    //AVSpeechBoundaryImmediate 立即停止
    //AVSpeechBoundaryWord    当前词结束后停止
    [_avSpeaker stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}
#pragma mark - AVSpeechSynthesizerDelegate
//已经开始
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
    if (self.readState) {
        self.readState(VoiceReaderStateIsRead);
    }
}
//已经说完
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    
    RTLog(@"read finish");
    if (self.readFinish) {
        self.readFinish();
    }
    if (self.readState) {
        self.readState(VoiceReaderStateStop);
    }
    //如果朗读要循环朗读，可以在这里再次调用朗读方法
    //[_avSpeaker speakUtterance:utterance];
}
//已经暂停
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance{
    if (self.readState) {
        self.readState(VoiceReaderStatePause);
    }
}
//已经继续说话
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance{
    
    if (self.readState) {
        self.readState(VoiceReaderStateIsRead);
    }
}
//已经取消说话
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{
    if (self.readState) {
        self.readState(VoiceReaderStateStop);
    }
}
//将要说某段话
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance{
    
}
@end
