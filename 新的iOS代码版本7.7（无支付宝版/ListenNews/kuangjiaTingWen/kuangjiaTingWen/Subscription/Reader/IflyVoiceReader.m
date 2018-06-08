//
//  IflyVoiceReader.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/5/14.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "IflyVoiceReader.h"

#define LimitLength 4000

@interface IflyVoiceReader()<IFlySpeechSynthesizerDelegate>
@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;
@property (strong, nonatomic) NSMutableArray *stringArray;
@property (assign, nonatomic) NSInteger readIndex;
@end
@implementation IflyVoiceReader
- (NSMutableArray *)stringArray
{
    if (_stringArray == nil) {
        _stringArray = [NSMutableArray array];
    }
    return _stringArray;
}
+ (instancetype)iflyVoiceReaderManager
{
    static IflyVoiceReader * reader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reader = [[IflyVoiceReader alloc]init];
    });
    return reader;
}
- (instancetype)init
{
    if (self = [super init]) {
        //获取语音合成单例
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
        //设置协议委托对象
        _iFlySpeechSynthesizer.delegate = self;
        //设置合成参数
        //设置在线工作方式
        [_iFlySpeechSynthesizer setParameter:[IFlySpeechConstant TYPE_CLOUD]
                                      forKey:[IFlySpeechConstant ENGINE_TYPE]];
        //设置语速，取值范围 0~100
        [_iFlySpeechSynthesizer setParameter:[NSString stringWithFormat:@"%d",(int)[CommonCode readFromUserD:@"ifly_read_rate"]]
                                      forKey: [IFlySpeechConstant SPEED]];
        //设置音量，取值范围 0~100
        [_iFlySpeechSynthesizer setParameter:@"50"
                                      forKey: [IFlySpeechConstant VOLUME]];
        //发音人，默认为”xiaoyan”，可以设置的参数列表可参考“合成发音人列表”
        [_iFlySpeechSynthesizer setParameter:[CommonCode readFromUserD:@"ifly_read_voicer"]
                                      forKey: [IFlySpeechConstant VOICE_NAME]];
        //保存合成文件名，如不再需要，设置为nil或者为空表示取消，默认目录位于library/cache下
        [_iFlySpeechSynthesizer setParameter:nil
                                      forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    }
    return self;
}
- (void)setReadRate:(CGFloat)readRate
{
    _readRate = readRate;
    [CommonCode writeToUserD:@(readRate) andKey:@"ifly_read_rate"];
    //设置语速，取值范围 0~100
    [_iFlySpeechSynthesizer setParameter:[NSString stringWithFormat:@"%d",(int)readRate]
                                  forKey: [IFlySpeechConstant SPEED]];
    [self stopReader];
    [self starReaderWithReaderString:self.readString];
}
- (void)setVoicer:(NSString *)voicer
{
    _voicer = voicer;
    [CommonCode writeToUserD:voicer andKey:@"ifly_read_voicer"];
    //设置语速，取值范围 0~100
    [_iFlySpeechSynthesizer setParameter:voicer
                                  forKey: [IFlySpeechConstant VOICE_NAME]];
    [self stopReader];
    [self starReaderWithReaderString:self.readString];
}
- (BOOL)isReading
{
    return _state == IflyVoiceReaderStateIsRead?YES:NO;
}
- (void)starReaderWithReaderString:(NSString *)string
{
    [[VoiceReader voiceReaderManager] stopReader];
    [self stopReader];
    self.readIndex = 0;
    if (string.length>LimitLength) {
        //对文字长度进行处理，每4000字为一段
        int stringLengthCount = (int)string.length/LimitLength;
        [self.stringArray removeAllObjects];
        NSString *subStringLast = [string substringFromIndex:LimitLength * stringLengthCount];
        for (int i = 0; i<stringLengthCount; i++) {
            [self.stringArray addObject:[[string substringWithRange:NSMakeRange(i*LimitLength, LimitLength)] stringByAppendingString:@"嗯嗯嗯"]];
        }
        [self.stringArray addObject:[subStringLast stringByAppendingString:@"嗯嗯嗯"]];
    }else{
        [self.stringArray removeAllObjects];
        [self.stringArray addObject:string];
    }
    //暂停新闻播放器
    if ([ZRT_PlayerManager manager].isPlaying) {
        [[ZRT_PlayerManager manager] pausePlay];
    }
    //停止上一条
    [self stopReader];
    //启动合成会话
    [_iFlySpeechSynthesizer startSpeaking:self.stringArray[_readIndex]];
}
- (void)pauseReader
{
    //暂停朗读
    [_iFlySpeechSynthesizer pauseSpeaking];
}
- (void)continueReader
{
    //暂停新闻播放器
    if ([ZRT_PlayerManager manager].isPlaying) {
        [[ZRT_PlayerManager manager] pausePlay];
    }
    //继续播放
    [_iFlySpeechSynthesizer resumeSpeaking];
}
- (void)stopReader
{
    //停止朗读
    [_iFlySpeechSynthesizer stopSpeaking];
}
#pragma mark - IFlySpeechSynthesizerDelegate协议实现
//合成结束
- (void)onCompleted:(IFlySpeechError *) error
{
    if (error.errorCode != 0 && error.errorCode != 10200 && error.errorCode != 20009) {//10200,20009,10407（appid和SDK不对应）
//        [[XWAlerLoginView alertWithTitle:[NSString stringWithFormat:@"%@:%d",error.errorDesc,error.errorCode]] show];
//        [CommonCode writeToUserD:@(NO) andKey:use_ifly_reader];
    }
}
//播放开始
- (void)onSpeakBegin {
    
    self.readIndex ++;
    
    if (self.readState) {
        self.state = IflyVoiceReaderStateIsRead;
        self.readState(IflyVoiceReaderStateIsRead);
    }
}
- (void)onSpeakPaused {
    
    if (self.readState) {
        self.state = IflyVoiceReaderStatePause;
        self.readState(IflyVoiceReaderStatePause);
    }
}
- (void)onSpeakResumed {
    
    if (self.readState) {
        self.state = IflyVoiceReaderStateIsRead;
        self.readState(IflyVoiceReaderStateIsRead);
    }
}
//合成缓冲进度
- (void) onBufferProgress:(int) progress message:(NSString *)msg {
    
    RTLog(@"合成字符串:%@",msg);
}
//合成播放进度
- (void) onSpeakProgress:(int) progress beginPos:(int)beginPos endPos:(int)endPos {
    RTLog(@"播放进度:%d beginPos:%d---endPos:%d",progress,beginPos,endPos);
    if (progress == 100) {//播放完成，如果有下一段，继续播放
        if (_readIndex >= self.stringArray.count) {
            //播放完成
            if (self.readFinish) {
                self.readFinish();
            }
            //播放状态
            if (self.readState) {
                self.state = IflyVoiceReaderStateStop;
                self.readState(IflyVoiceReaderStateStop);
            }
            return;
        }
        //启动合成会话
        [_iFlySpeechSynthesizer startSpeaking:self.stringArray[_readIndex]];
    }
}
@end
