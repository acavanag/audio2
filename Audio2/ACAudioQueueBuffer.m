//
//  ACAudioQueueBuffer.m
//  
//
//  Created by Andrew Cavanagh on 7/19/15.
//
//

#import "ACAudioQueueBuffer.h"

@interface ACAudioQueueBuffer()
{
    NSInteger _index;
}
@property (nonatomic, assign) UInt32 bufferSize;
@property (nonatomic, assign) AudioQueueBufferRef audioQueueBuffer;
@property (nonatomic, assign) AudioQueueRef *audioQueue;
@end

@implementation ACAudioQueueBuffer

- (instancetype)initWithAudioQueue:(AudioQueueRef)audioQueue bufferSize:(UInt32)bufferSize index:(NSInteger)index
{
    if (self = [super init]) {
        _index = index;
        _bufferSize = bufferSize;
        _audioQueue = &audioQueue;
        AudioQueueAllocateBuffer(audioQueue, _bufferSize, &_audioQueueBuffer);
    }
    return self;
}

- (void)fillBuffer:(SInt16 *)data length:(UInt32)length
{
    memcpy(_audioQueueBuffer->mAudioData, data, length);
    _audioQueueBuffer->mAudioDataByteSize = length;
}

- (void)free
{
    if (_audioQueue != NULL) {
        AudioQueueFreeBuffer(*_audioQueue, _audioQueueBuffer);
    }
}

- (NSInteger)index
{
    return _index;
}

- (BOOL)equal:(AudioQueueBufferRef)inQueueBuffer
{
    return (inQueueBuffer == _audioQueueBuffer);
}

- (AudioQueueBufferRef)buffer
{
    return _audioQueueBuffer;
}

@end
