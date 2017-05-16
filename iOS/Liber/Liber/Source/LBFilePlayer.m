//
//  LBFilePlayer.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBFilePlayer.h"
@import MediaPlayer;
@import AVFoundation;


@interface LBFilePlayer() <AVAudioPlayerDelegate>

@end


@implementation LBFilePlayer


- (void) play:(NSString*)path {
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:0 error:nil];
    [[AVAudioSession sharedInstance] setActive:YES withOptions:0 error:nil];

    [self.player setDelegate: self];
    [self.player prepareToPlay];
    BOOL playing = [self.player play];
    NSLog(@"trying to play %@ %d", path, playing);
}


- (void) play:(NSString*)path artist:(NSString*)artist title:(NSString*)title image:(UIImage*)image {
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:0 error:nil];
    [[AVAudioSession sharedInstance] setActive:YES withOptions:0 error:nil];
    
    [self.player setDelegate: self];
    [self.player prepareToPlay];
    BOOL playing = [self.player play];
    NSLog(@"trying to play %@ %d", path, playing);
    
    MPMediaItemArtwork* artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(10.0, 10.0) requestHandler:^UIImage * _Nonnull(CGSize size) {
        return image;
    }] ;
    
    // this info shows up in the locked screen and control center
    MPNowPlayingInfoCenter* mpic = [MPNowPlayingInfoCenter defaultCenter];
    mpic.nowPlayingInfo = @{
        MPMediaItemPropertyArtist: artist,
        MPMediaItemPropertyTitle: title,
        MPMediaItemPropertyPlaybackDuration: [NSString stringWithFormat:@"%f", self.player.duration],
        MPNowPlayingInfoPropertyElapsedPlaybackTime: @0,
        MPNowPlayingInfoPropertyPlaybackRate: @1,
        MPMediaItemPropertyArtwork: artwork
    };
}


- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)success {
    
    NSLog(@"audio finished %d", success);
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient withOptions:0 error:nil];
    [[AVAudioSession sharedInstance] setActive: YES withOptions:0 error:nil];
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
    BOOL playing = [player play];
    NSLog(@"tried to play; success? %d", playing);
}


@end
