//
//  ViewController.m
//  Audio2
//
//  Created by Andrew Cavanagh on 7/18/15.
//  Copyright (c) 2015 andrewjmc. All rights reserved.
//

#import "ViewController.h"
#import "VOIPEngine.h"
@import AVFoundation;

@interface ViewController ()
@property (nonatomic, strong, nonnull) VOIPEngine *engine;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.engine = [[VOIPEngine alloc] init];
    [self.engine startRecording];
    [self.engine startPlaying];
    
    [self.engine tapInput:^(NSData *buffer) {
        
        NSLog(@"wat");
        
        [self.engine playBuffer:buffer];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
