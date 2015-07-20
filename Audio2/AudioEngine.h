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
@property (nonatomic, strong, readonly) AVAudioFormat *audioFormat;
@end
