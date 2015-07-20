//
//  AudioEngine.h
//  
//
//  Created by Andrew Cavanagh on 7/18/15.
//
//

#import <Foundation/Foundation.h>
@import AVFoundation;

typedef void(^AudioInputBlock)(NSData * __nonnull buffer, AVAudioFormat * __nonnull format, UInt32 frameCount);

@interface AudioEngine : NSObject
- (void)tapInput:(__nonnull AudioInputBlock)block;
- (void)stopRecording;
- (void)startRecording;
@property (nonatomic, strong, readonly, nonnull) AVAudioFormat *audioFormat;
@end
