//
//  Xzb_CountDownButton.m
//  xzb
//
//  Created by 张荣廷 on 16/9/8.
//  Copyright © 2016年 xuwk. All rights reserved.
//

#import "Xzb_CountDownButton.h"

@interface Xzb_CountDownButton ()
@property (nonatomic , strong) NSTimer *timer;
@end
@implementation Xzb_CountDownButton
- (void)attAction
{
    _index = 60;
    //启动定时器
    NSTimer *testTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(timeAction:)
                                                        userInfo:nil
                                                         repeats:YES];
    [testTimer fire];//
    [[NSRunLoop currentRunLoop] addTimer:testTimer forMode:NSDefaultRunLoopMode];
    self.timer = testTimer;
}
//每隔1秒 调用一次
- (void)timeAction:(NSTimer *)timer
{
    _index--;
//    NSLog(@"_index = %ld",(long)_index);
    NSString *again_str = [NSString stringWithFormat:@"获取中(%ld)",(long)_index];
    [self setTitle:again_str forState:UIControlStateNormal];
    self.enabled = NO;
    if (_index <= 0) {
        //invalidate  终止定时器
        [self setTitle:@"重发验证码" forState:UIControlStateNormal];
        self.enabled = YES;
        [timer invalidate];
        timer = nil;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setTitle:[NSString stringWithFormat:@"获取中(%ld)",(long)_index] forState:UIControlStateNormal];
        });
        
    }
}
- (void)starWithGCD
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); // 每秒执行一次
    
    NSTimeInterval seconds = 60.f;
    NSDate *endTime = [NSDate dateWithTimeIntervalSinceNow:seconds]; // 最后期限
    
    dispatch_source_set_event_handler(_timer, ^{
        int interval = [endTime timeIntervalSinceNow];
        if (interval > 0) { // 更新倒计时
            NSString *timeStr = [NSString stringWithFormat:@"%d秒后重发", interval];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.enabled = NO;
                [self setTitle:timeStr forState:UIControlStateNormal];
            });
        } else { // 倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.enabled = YES;
                [self setTitle:@"发送验证码" forState:UIControlStateNormal];
            });
        }
    });
    dispatch_resume(_timer);
}
@end
