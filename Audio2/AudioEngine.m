//
//  AudioEngine.m
//  
//
//  Created by Andrew Cavanagh on 7/18/15.
//
//

#define kOutputBus 0
#define kInputBus 1

#import "AudioEngine.h"

OSStatus status;
AudioUnit audioUnit;
AudioBufferList *list;
AudioStreamBasicDescription stream;

@interface AudioEngine()
@property (nonatomic, copy) AudioInputBlock block;
@property (nonatomic, strong) AVAudioFormat *format;
@end

@implementation AudioEngine

void checkStatus(OSStatus status)
{
    if (status != noErr) {
        NSLog(@"FUCK FUCK FUCK");
    }
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    audioUnit = malloc(sizeof(AudioUnit));
    
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get audio units
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    checkStatus(status);
    
    // Enable IO for recording
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    // Enable IO for playback
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    // Describe format
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate			= 44100.00;
    audioFormat.mFormatID			= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket	= 1;
    audioFormat.mChannelsPerFrame	= 1;
    audioFormat.mBitsPerChannel		= 16;
    audioFormat.mBytesPerPacket		= 2;
    audioFormat.mBytesPerFrame		= 2;
    
    stream = audioFormat;
    self.format = [[AVAudioFormat alloc] initWithStreamDescription:&stream];
    _audioFormat = _format;
    
    // Apply format
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    
    // Set input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status);
    
    // Set output callback
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status);
    
    status = AudioUnitInitialize(audioUnit);
    checkStatus(status);
    
    OSStatus status = AudioOutputUnitStart(audioUnit);
    checkStatus(status);
}

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    
    NSLog(@"RECORDING!!!");
    // TODO: Use inRefCon to access our interface object to do stuff
    // Then, use inNumberFrames to figure out how much data is available, and make
    // that much space available in buffers in an AudioBufferList.
    
    if (list == NULL) {
        UInt32 size = inNumberFrames * stream.mBytesPerFrame; //(512 * 2)
        list = Buffer_create(size);
    }
    
    AudioBufferList *bufferList = list; // <- Fill this up with buffers (you will want to malloc it, as it's a dynamic-length list)
    
    // Then:
    // Obtain recorded samples
    
    OSStatus status;
    
    status = AudioUnitRender(audioUnit,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             bufferList);
    checkStatus(status);
    
    AudioEngine *e = (__bridge AudioEngine *)inRefCon;
    SInt16 *inputFrames = (SInt16 *)(list->mBuffers->mData);
    [e renderBuffer:inputFrames frameCount:inNumberFrames bytesPerFrame:stream.mBytesPerFrame];
    // Now, we have the samples we just read sitting in buffers in bufferList
    //DoStuffWithTheRecordedAudio(bufferList);
    return noErr;
}

static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    
    NSLog(@"PLAYBACK!!!");
    
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
    return noErr;
}

- (void)renderBuffer:(SInt16 *)buffer frameCount:(UInt32)frameCount bytesPerFrame:(UInt32)bytesPerFrame
{
//    for (int i = 0; i < frameCount; i++) {
//        NSLog(@"%hd", buffer[i]);
//    }
    
    
    
    if (self.block) {
        NSData *d = [NSData dataWithBytes:buffer length:frameCount * bytesPerFrame];
        NSLog(@"Rendered: %lu bytes.", (unsigned long)d.length);
        self.block(d, _format, frameCount);
    }
}

AudioBufferList* Buffer_create(UInt32 bufferSize)
{
    AudioBuffer buffer;
    buffer.mNumberChannels = 1;
    buffer.mDataByteSize = bufferSize;
    buffer.mData = malloc(bufferSize);
    
    AudioBufferList *bufferList = malloc(sizeof(AudioBufferList));
    bufferList->mNumberBuffers = 1;
    bufferList->mBuffers[0] = buffer;
    
    return bufferList;
}

void Buffer_destory(AudioBufferList* bufferList)
{
    free(bufferList->mBuffers[0].mData);
    free(bufferList);
}

- (void)tapInput:(__nonnull AudioInputBlock)block
{
    self.block = block;
}

- (void)dealloc
{
    Buffer_destory(list);
}

@end
