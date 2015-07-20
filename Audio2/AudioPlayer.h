//
//  AudioPlayer.h
//  
//
//  Created by Andrew Cavanagh on 7/19/15.
//
//

#import <Foundation/Foundation.h>
@import AVFoundation;

typedef void(^BufferBlock)(AudioQueueBufferRef buffer, AudioStreamBasicDescription audioFormat);

@interface AudioPlayer : NSObject
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, copy) BufferBlock bufferBlock;

- (instancetype)initWithAudioDescription:(AVAudioFormat *)description packetSize:(UInt32)size;
- (void)scheduleBuffer:(NSData *)buffer;
- (void)startPlaying;
- (void)stopPlaying;
@end
