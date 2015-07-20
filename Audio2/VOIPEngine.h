//
//  VOIPEngine.h
//  
//
//  Created by Andrew Cavanagh on 7/20/15.
//
//

#import <Foundation/Foundation.h>

typedef void(^AudioInputBlock)(NSData * __nonnull buffer);

@interface VOIPEngine : NSObject

- (void)startRecording;
- (void)stopRecording;
- (void)startPlaying;
- (void)stopPlaying;
- (void)tapInput:(AudioInputBlock __nonnull)block;
- (void)playBuffer:(NSData * __nonnull)buffer;

@end
