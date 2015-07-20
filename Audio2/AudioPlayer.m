//
//  AudioPlayer.m
//  
//
//  Created by Andrew Cavanagh on 7/19/15.
//
//

#import "AudioPlayer.h"
#import "ACAudioQueue.h"

@interface AudioPlayer()
{
    AudioQueueRef _playQueue;
    UInt32 _packetsPerBuffer;
    UInt32 _bytesPerBuffer;
}
@property (nonatomic, strong) ACAudioQueue *bufferQueue;
@property (nonatomic, assign) AudioStreamBasicDescription audioFormat;
@end

@implementation AudioPlayer

- (instancetype)initWithAudioDescription:(AVAudioFormat *)description packetSize:(UInt32)size
{
    if (self = [super init]) {
        _playQueue = NULL;
        _isPlaying = NO;
        _audioFormat = *description.streamDescription;
        _packetsPerBuffer = size;
        _bytesPerBuffer = _packetsPerBuffer * _audioFormat.mBytesPerPacket;
        [self setup];
    }
    return self;
}

- (void)setup
{
    if (_playQueue == NULL) {
        AudioQueueNewOutput(&_audioFormat, PlayCallback, (__bridge void *)self, NULL, kCFRunLoopCommonModes, 0, &_playQueue);
        _bufferQueue = [[ACAudioQueue alloc] initWithQueue:_playQueue bufferSize:_packetsPerBuffer count:3];
    }
}

- (void)startPlaying
{
    if (_isPlaying == NO) {
        AudioQueueStart(_playQueue, NULL);
        _isPlaying = YES;
    }
}

- (void)stopPlaying
{
    if (_isPlaying == YES) {
        AudioQueueStop(_playQueue, TRUE);
        _isPlaying = NO;
    }
}

#pragma mark - Playback Queue

static void PlayCallback(void *inUserData, AudioQueueRef inAudioQueue, AudioQueueBufferRef inBuffer)
{
    AudioPlayer *player = (__bridge AudioPlayer *)inUserData;
    [player.bufferQueue reclaimBufferForBufferRef:inBuffer];
}

- (void)scheduleBuffer:(NSData *)buffer
{
    if (_isPlaying) {
        ACAudioQueueBuffer *bufferObj = [_bufferQueue nextBuffer];
        [bufferObj fillBuffer:(SInt16 *)buffer.bytes length:(UInt32)buffer.length];
        AudioQueueEnqueueBuffer(_playQueue, [bufferObj buffer], 0, NULL);
    }
}

@end
