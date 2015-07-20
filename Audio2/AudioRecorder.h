//
//  AudioEngine.h
//  
//
//  Created by Andrew Cavanagh on 7/18/15.
//
//

#import <Foundation/Foundation.h>
#import "VOIPEngine.h"
@import AVFoundation;

@interface AudioRecorder : NSObject
- (void)tapInput:(__nonnull AudioInputBlock)block;
- (void)stopRecording;
- (void)startRecording;
@property (nonatomic, strong, readonly, nonnull) AVAudioFormat *audioFormat;
@property (nonatomic, assign, readonly) int bufferSize;
@end
