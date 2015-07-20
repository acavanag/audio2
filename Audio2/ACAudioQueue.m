//
//  ACAudioQueue.m
//  
//
//  Created by Andrew Cavanagh on 7/19/15.
//
//

#import "ACAudioQueue.h"

@interface ACAudioQueue()
@property (nonatomic, strong) NSArray *buffers;
@property (atomic, strong) NSMutableArray *availableBuffers;
@end

@implementation ACAudioQueue

- (instancetype)initWithQueue:(AudioQueueRef)audioQueue bufferSize:(UInt32)bufferSize count:(UInt32)count {
    if (self = [super init]) {
        _availableBuffers = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i < count; i++) {
            ACAudioQueueBuffer *buffer = [[ACAudioQueueBuffer alloc] initWithAudioQueue:audioQueue bufferSize:bufferSize index:i];
            [_availableBuffers push:buffer];
        }
        _buffers = [_availableBuffers copy];
    }
    return self;
}

- (ACAudioQueueBuffer *)nextBuffer
{
    if (![self bufferAvailable]) return nil;
    @synchronized(self) {
        return self.buffers[[[self.availableBuffers pop] index]];
    }
}

- (void)reclaimBufferForBufferRef:(AudioQueueBufferRef)bufferRef
{
    @synchronized(self) {
        for (int i = 0; i < _buffers.count; i++) {
            if ([_buffers[i] equal:bufferRef]) {
                [self.availableBuffers push:_buffers[i]];
                break;
            }
        }
    }
}

- (BOOL)bufferAvailable
{
    @synchronized(self) {
        return self.availableBuffers.count > 0;
    }
}

@end
