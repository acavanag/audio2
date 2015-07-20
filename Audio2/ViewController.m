//
//  ViewController.m
//  Audio2
//
//  Created by Andrew Cavanagh on 7/18/15.
//  Copyright (c) 2015 andrewjmc. All rights reserved.
//

#import "ViewController.h"
#import "AudioEngine.h"
#import "AudioPlayer.h"

@interface ViewController () {
    int bufferCount;
}
@property (nonatomic, strong) AudioEngine *engine;
@property (nonatomic, strong) AudioPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    bufferCount = 0;
    
    _engine = [[AudioEngine alloc] init];
    _player = [[AudioPlayer alloc] initWithAudioDescription:_engine.audioFormat packetSize:1024];
    [_player start];
    
    [_engine tapInput:^(NSData *d, AVAudioFormat *f, UInt32 frameCount) {
        
        [_player scheduleBuffer:(SInt16 *)d.bytes length:(UInt32)d.length];
        
//        NSLog(@"%u", (unsigned int)frameCount);
//        NSLog(@"%lu", (unsigned long)d.length);
//        
//        NSLog(@"%@", d);
        
        //SInt16 *int16ChannelData;
        //[d getBytes:int16ChannelData length:d.length];
        
        //[_player scheduleBuffer:int16ChannelData frameCount:frameCount];
    }];
}

- (AVAudioPCMBuffer *)inspectData:(NSData *)data format:(AVAudioFormat *)format
{
    uint32_t frameCapacity = (uint32_t)data.length / format.streamDescription->mBytesPerFrame;
    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:frameCapacity];
    buffer.frameLength = buffer.frameCapacity;
    [data getBytes:*buffer.int16ChannelData length:data.length];
    return buffer;
}

- (NSString *)nextPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"a%i", bufferCount++]];
    NSLog(@"Writing to: %@", path);
    return path;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
