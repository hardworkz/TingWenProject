//
//  IflyVoiceReader.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/5/14.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IflyVoiceReaderState) {
    IflyVoiceReaderStateIsRead = 0,//正在朗读
    IflyVoiceReaderStatePause,//暂停朗读
    IflyVoiceReaderStateStop,//停止朗读
};
@interface IflyVoiceReader : NSObject
+ (instancetype)iflyVoiceReaderManager;
@property (assign, nonatomic) BOOL isReading;
@property (assign, nonatomic) CGFloat readRate;
@property (strong, nonatomic) NSString *readString;
@property (strong, nonatomic) NSString *voicer;
@property (assign, nonatomic) IflyVoiceReaderState state;
@property (copy, nonatomic) void (^readFinish)();
@property (copy, nonatomic) void (^readState)(IflyVoiceReaderState state);

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
