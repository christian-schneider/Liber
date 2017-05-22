//
//  LBFilePlayer.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBFilePlayer.h"
@import MediaPlayer;
@import AVFoundation;
#import "AppDelegate.h"


@interface LBFilePlayer() <AVAudioPlayerDelegate>

@property (nonatomic, weak) AppDelegate* appDelegate;

@property (readwrite) BOOL isPlaying;

@end


@implementation LBFilePlayer

- (id) init {
    if (self = [super init]) {
        self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
        
        MPRemoteCommandCenter *remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
        [[remoteCommandCenter nextTrackCommand] addTarget:self action:@selector(nextTrack)];
        [[remoteCommandCenter previousTrackCommand] addTarget:self action:@selector(previousTrack)];
        [[remoteCommandCenter playCommand] addTarget:self action:@selector(play)];
        [[remoteCommandCenter pauseCommand] addTarget:self action:@selector(pause)];
    }
    return self;
}


- (void) play:(NSString*)path artist:(NSString*)artist trackTitle:(NSString*)trackTitle image:(UIImage*)image {
    
    self.playingArtist = artist ? artist : @"Unknow Artist";
    self.playingTitle = trackTitle ? trackTitle : @"Unknown Title";
    self.playingImage = image;
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:0 error:nil];
    [[AVAudioSession sharedInstance] setActive:YES withOptions:0 error:nil];
    
    [self.player setDelegate:self];
    [self.player prepareToPlay];
    self.isPlaying = [self.player play];
    
    // locked screen and control center:
    
    // this tries to be clever: if the method gets sent in a valid image, it is used
    // else it tries to get it directly from the file

    MPMediaItemArtwork* artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(10.0, 10.0) requestHandler:^UIImage * _Nonnull(CGSize size) {
        self.playingImage = self.playingImage ? self.playingImage : [self.appDelegate.importer imageForItemAtFileURL:[NSURL fileURLWithPath:path]] ;
        return self.playingImage;
    }] ;
    
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{
        MPMediaItemPropertyArtist: self.playingArtist,
        MPMediaItemPropertyTitle: self.playingTitle,
        MPMediaItemPropertyPlaybackDuration: [NSString stringWithFormat:@"%f", self.player.duration],
        MPNowPlayingInfoPropertyElapsedPlaybackTime: @0,
        MPNowPlayingInfoPropertyPlaybackRate: @1,
        MPMediaItemPropertyArtwork: artwork
    };
}


- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)success {
    
    // TODO:
    // check the play queue, if there is another file in the queue, call play and return
    
    NSLog(@"audio finished %d", success);
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient withOptions:0 error:nil];
    self.isPlaying = NO;
    self.playingArtist = @"";
    self.playingTitle = @"";
    self.playingImage = nil;
}


- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    
    NSLog(@"audio player interrupted at %f", self.player.currentTime);
}

-(void) audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)options {
    
    NSLog(@"audio player interruption ended with options %lu", (unsigned long)options);
    if (options & AVAudioSessionInterruptionOptionShouldResume) {
        NSLog(@"should resume");
        // should always try to resume
    }
    [player prepareToPlay];
    self.isPlaying = [player play];
    NSLog(@"tried to play; success? %d", self.isPlaying);
}


- (void) nextTrack {
    NSLog(@"next track");
}


- (void) previousTrack {
    NSLog(@"previous track");
    [self.player setCurrentTime:0];
}


- (void) play {
    [self.player play];
}


- (void) pause {
    [self.player pause];
}


@end
