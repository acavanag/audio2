//
//  ACAudioQueue.h
//  
//
//  Created by Andrew Cavanagh on 7/19/15.
//
//

#import <Foundation/Foundation.h>
#import "ACAudioQueueBuffer.h"
#import "NSMutableArray+Queue.h"
@import AVFoundation;

@interface ACAudioQueue : NSObject
- (instancetype)initWithQueue:(AudioQueueRef)audioQueue bufferSize:(UInt32)bufferSize count:(UInt32)count;
- (void)reclaimBufferForBufferRef:(AudioQueueBufferRef)bufferRef;
- (ACAudioQueueBuffer *)nextBuffer;
@end
