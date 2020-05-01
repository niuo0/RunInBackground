//
//  RunInBackground.m
//  libIntegrity
//
//  Created by niu_o0 on 2020/4/24.
//  Copyright © 2020 niu_o0. All rights reserved.
//

#import "RunInBackground.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "blank.h"

@interface RunInBackground ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *audioTimer;

@end

@implementation RunInBackground {
    UIBackgroundTaskIdentifier _task;
    NSData * _blank;
    BOOL _isInBackground;
}

+ (void)load {
    [RunInBackground sharedBg];
}

/// 提供一个单例
+ (instancetype)sharedBg {
    static dispatch_once_t onceToken;
    static RunInBackground * instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[RunInBackground alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        _blank = blank();
        
    }
    return self;
}

- (void)didEnterBackground {
    _isInBackground = YES;
    [self startRunInbackGround];
}

- (void)willEnterForeground {
    _isInBackground = NO;
    [self stopAudioPlay];
}

- (void)audioPlay {
    
    if (self.isVoiceOrVideoCall ||
        !self.isInBackground) {
        [self stopAudioPlay];
        return;
    }
    
    [self setUpAudioSession];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:_blank error:nil];
    
    [self.audioPlayer prepareToPlay];
    
    [self.audioPlayer play];
    
    NSLog(@"audio play");
    
}

- (void)startRunInbackGround {
    
    [self stopAudioPlay];
    
    _task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] endBackgroundTask:self->_task];
            self->_task = UIBackgroundTaskInvalid;
        });
        
    }];
    
    self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(checkTask) userInfo:nil repeats:YES];
    
}

- (void)checkTask {

    [self audioPlay];
    
    NSTimeInterval bt = [UIApplication sharedApplication].backgroundTimeRemaining;
    
    NSLog(@"~~~~~~~~~~~~~~~~~~%.2f~~~~~~~~~~~~~~", bt);
    if (bt < 30.f) {
        
        [[UIApplication sharedApplication] endBackgroundTask:_task];
        _task = UIBackgroundTaskInvalid;
        
        _task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] endBackgroundTask:self->_task];
                self->_task = UIBackgroundTaskInvalid;
            });
            
        }];

    }
}

- (void)stopAudioPlay {
    
    // 关闭定时器即可
    [self.audioTimer invalidate];
    self.audioTimer = nil;
    
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    
    if (_task) {
        [[UIApplication sharedApplication] endBackgroundTask:_task];
        _task = UIBackgroundTaskInvalid;
    }
    
}
- (void)setUpAudioSession {
    // 新建AudioSession会话
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    // 设置后台播放
    NSError *error = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    
    if (error) {
        NSLog(@"Error setCategory AVAudioSession: %@", error);
    }
    
    NSLog(@"%d", audioSession.isOtherAudioPlaying);
    
    NSError *activeSetError = nil;
    // 启动AudioSession，如果一个前台app正在播放音频则可能启动失败
    [audioSession setActive:YES error:&activeSetError];
    if (activeSetError) {
        NSLog(@"Error activating AVAudioSession: %@", activeSetError);
    }
}

- (BOOL)isInBackground {
    return _isInBackground;
}

@end
