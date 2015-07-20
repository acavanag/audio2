//
//  AudioEngine.m
//  
//
//  Created by Andrew Cavanagh on 7/18/15.
//
//

#import "AudioEngine.h"

AudioStreamBasicDescription ae_kAudioFormat = {
    .mSampleRate       = 44100.00,
    .mFormatID         = kAudioFormatLinearPCM,
    .mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
    .mFramesPerPacket  = 1,
    .mChannelsPerFrame = 1,
    .mBitsPerChannel   = 16,
    .mBytesPerPacket   = 2,
    .mBytesPerFrame    = 2
};

static const int ae_kOutputBus = 0;
static const int ae_kInputBus = 1;

@interface AudioEngine()
{
    OSStatus status;
    AudioUnit audioUnit;
    AudioBufferList *list;
}
@property (nonatomic, copy) AudioInputBlock block;
@end

@implementation AudioEngine

- (instancetype)init {
    if (self = [super init]) {
        self->_audioFormat = [[AVAudioFormat alloc] initWithStreamDescription:&ae_kAudioFormat];
        [self setup];
    }
    return self;
}

#define checkStatus(result,operation) (_checkStatus((result),(operation),strrchr(__FILE__, '/')+1,__LINE__))
static inline BOOL _checkStatus(OSStatus result, const char *operation, const char* file, int line)
{
    if ( result != noErr ) {
        NSLog(@"%d %s %s %d", (int)result, operation, file, line);
        return NO;
    }
    return YES;
}

#pragma mark - Configure AU

- (void)setup
{
    audioUnit = malloc(sizeof(AudioUnit));
    
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    checkStatus(status, "AudioComponentInstanceNew");
    
    UInt32 inputEnabled = 1;
    status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, ae_kInputBus, &inputEnabled, sizeof(inputEnabled));
    checkStatus(status, "AudioUnitSetProperty EnableIO Input");
    
    UInt32 outputEnabled = 1;
    status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, ae_kOutputBus, &outputEnabled, sizeof(outputEnabled));
    checkStatus(status, "AudioUnitSetProperty EnableIO Output");
    
    status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, ae_kInputBus, &ae_kAudioFormat, sizeof(ae_kAudioFormat));
    checkStatus(status, "AudioUnitSetProperty StreamFormat Output");
    status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, ae_kOutputBus, &ae_kAudioFormat, sizeof(ae_kAudioFormat));
    checkStatus(status, "AudioUnitSetProperty StreamFromat Input");
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, ae_kInputBus, &callbackStruct, sizeof(callbackStruct));
    checkStatus(status, "AudioUnitSetProperty InputCallback Global");
    
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, ae_kOutputBus, &callbackStruct, sizeof(callbackStruct));
    checkStatus(status, "AudioUnitSetProperty OutputCallback Global");
    
    status = AudioUnitInitialize(audioUnit);
    checkStatus(status, "AudioUnitInitialize");
}

#pragma mark - Recording Start/Stop

- (void)stopRecording
{
    status = AudioOutputUnitStart(audioUnit);
    checkStatus(status, "AudioOutputUnitStart");
}

- (void)startRecording
{
    status = AudioOutputUnitStop(audioUnit);
    checkStatus(status, "AudioOutputUnitStop");
}

#pragma mark - Recording Callback

static OSStatus recordingCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    AudioEngine *e = (__bridge AudioEngine *)inRefCon;
    
    if (e->list == NULL) {
        UInt32 size = inNumberFrames * ae_kAudioFormat.mBytesPerFrame; //(512 * 2)
        e->list = Buffer_create(size);
    }
    
    AudioBufferList *bufferList = e->list;
    
    e->status = AudioUnitRender(e->audioUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, bufferList);
    checkStatus(e->status, "AudioUnitRender recordingCallback");
    
    
    SInt16 *inputFrames = (SInt16 *)(e->list->mBuffers->mData);
    [e renderBuffer:inputFrames frameCount:inNumberFrames bytesPerFrame:ae_kAudioFormat.mBytesPerFrame];

    return noErr;
}

#pragma mark - Playback Callback

static OSStatus playbackCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    return noErr;
}

#pragma mark - Block handler

- (void)renderBuffer:(SInt16 *)buffer frameCount:(UInt32)frameCount bytesPerFrame:(UInt32)bytesPerFrame
{
    if (self.block) {
        self.block([NSData dataWithBytes:buffer length:frameCount * bytesPerFrame], self->_audioFormat, frameCount);
    }
}

- (void)tapInput:(__nonnull AudioInputBlock)block
{
    self.block = block;
}

#pragma mark - Buffer Management

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

- (void)dealloc
{
    Buffer_destory(list);
}

@end
