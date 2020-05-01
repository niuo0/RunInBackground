//
//  RunInBackground.h
//  libIntegrity
//
//  Created by niu_o0 on 2020/4/24.
//  Copyright © 2020 niu_o0. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RunInBackground : NSObject

@property (nonatomic, assign, readonly) BOOL isInBackground;

@property (nonatomic, assign) BOOL isVoiceOrVideoCall;

+ (instancetype)sharedBg;

// 调用此方法后，程序进入后台也不会死掉
- (void)startRunInbackGround;

// 停止播放音乐
- (void)stopAudioPlay;

@end

NS_ASSUME_NONNULL_END
