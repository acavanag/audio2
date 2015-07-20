//
//  VOIPEngine.m
//  
//
//  Created by Andrew Cavanagh on 7/20/15.
//
//

#import "VOIPEngine.h"
#import "AudioRecorder.h"
#import "AudioPlayer.h"

@interface VOIPEngine()
@property (nonatomic, strong, nonnull) AudioRecorder *recorder;
@property (nonatomic, strong, nonnull) AudioPlayer *player;
@end

@implementation VOIPEngine

- (instancetype)init {
    if (self = [super init]) {
        _recorder = [[AudioRecorder alloc] init];
        _player = [[AudioPlayer alloc] initWithAudioDescription:_recorder.audioFormat packetSize:1024];
        [self setup];
    }
    return self;
}

- (void)setup {
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:0.02 error:nil];
}

- (void)startRecording {
    [_recorder startRecording];
}

- (void)stopRecording {
    [_recorder stopRecording];
}

- (void)startPlaying {
    [_player startPlaying];
}

- (void)stopPlaying {
    [_player stopPlaying];
}

- (void)tapInput:(AudioInputBlock)block {
    [_recorder tapInput:block];
}

- (void)playBuffer:(NSData *)buffer {
    [_player scheduleBuffer:buffer];
}

@end
