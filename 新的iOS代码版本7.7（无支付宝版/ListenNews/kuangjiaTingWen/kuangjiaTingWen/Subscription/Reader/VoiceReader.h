//
//  VoiceReader.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/4/12.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VoiceReaderState) {
    VoiceReaderStateIsRead = 0,//正在朗读
    VoiceReaderStatePause,//暂停朗读
    VoiceReaderStateStop,//停止朗读
};
@interface VoiceReader : NSObject
+ (instancetype)voiceReaderManager;
@property (assign, nonatomic) BOOL isReading;
@property (assign, nonatomic) BOOL isPause;
@property (assign, nonatomic) CGFloat readRate;
@property (strong, nonatomic) NSString *readString;
@property (copy, nonatomic) void (^readFinish)();
@property (copy, nonatomic) void (^readState)(VoiceReaderState state);
/**
 开始阅读并设置阅读内容
 */
- (void)starReaderWithReaderString:(NSString *)string;
/**
 暂停阅读
 */
- (void)pauseReader;
/**
 继续阅读
 */
- (void)continueReader;
/**
 停止阅读
 */
- (void)stopReader;

@end
