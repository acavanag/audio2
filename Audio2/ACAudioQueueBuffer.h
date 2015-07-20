//
//  ACAudioQueueBuffer.h
//  
//
//  Created by Andrew Cavanagh on 7/19/15.
//
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface ACAudioQueueBuffer : NSObject
- (instancetype)initWithAudioQueue:(AudioQueueRef)audioQueue bufferSize:(UInt32)bufferSize index:(NSInteger)index;
- (void)fillBuffer:(SInt16 *)data length:(UInt32)length;
- (BOOL)equal:(AudioQueueBufferRef)inQueueBuffer;
- (AudioQueueBufferRef)buffer;
- (NSInteger)index;
- (void)free;
@end
