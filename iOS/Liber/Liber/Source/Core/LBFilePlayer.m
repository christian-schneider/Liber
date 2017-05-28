//
//  LBFilePlayer.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBFilePlayer.h"
#import "LBImporter.h"
#import "AppDelegate.h"
#import "Track+Functions.h"
#import "Album+Functions.h"
#import "Artist+Functions.h"
@import MediaPlayer;
@import AVFoundation;


@interface LBFilePlayer() <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, weak) AppDelegate* appDelegate;

@property (nonatomic, strong) Track* currentTrack;
@property (readwrite) BOOL isPlaying;
@property (readwrite) BOOL isPaused;

@property (nonatomic, strong) NSString* playingArtist;
@property (nonatomic, strong) NSString* playingTitle;
@property (nonatomic, strong) UIImage* playingImage;

@property (nonatomic, strong) NSDictionary* nowPlayingInfo;

@end


@implementation LBFilePlayer

- (id) init {
    if (self = [super init]) {
        self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
        
        MPRemoteCommandCenter *remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
        [[remoteCommandCenter nextTrackCommand] addTarget:self action:@selector(nextTrack)];
        [[remoteCommandCenter previousTrackCommand] addTarget:self action:@selector(previousTrack)];
        [[remoteCommandCenter playCommand] addTarget:self action:@selector(continuePlaying)];
        [[remoteCommandCenter pauseCommand] addTarget:self action:@selector(pausePlaying)];
    }
    return self;
}


- (void) playTrack:(Track*)track {
    
    self.currentTrack = track;
    UIImage* image = [self.appDelegate.importer imageForItemAtFileURL:[NSURL fileURLWithPath:track.fullPath]];
    if (!image) {
        image = [UIImage imageWithData:track.album.image];
    }
    [self play:track.fullPath artist:track.artist.name trackTitle:track.title image:image];
    [self.player prepareToPlay];
    [self.player play];
}


- (void) pausePlaying {

    [self.player pause];
    self.isPlaying = NO;
    [self updateRemoteControls];
}


- (void) continuePlaying {
    
    [self.player play];
    self.isPlaying = YES;
    [self updateRemoteControls];
}


- (void) stopPlaying {
    
    [self.player stop];
    //[[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient withOptions:0 error:nil];
    self.isPlaying = NO;
    self.playingArtist = @"";
    self.playingTitle = @"";
    self.playingImage = nil;
}


- (Track*) currentTrack {
    
    return self.currentTrack;
}


- (void) play:(NSString*)path artist:(NSString*)artist trackTitle:(NSString*)trackTitle image:(UIImage*)image {
    
    if (nil == path) return;
    
    self.playingArtist = artist ? artist : @"";
    self.playingTitle = trackTitle ? trackTitle : path.lastPathComponent;
    self.playingImage = image;
    
    NSError* error;
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    if (error) NSLog(@"AVAudioPlayer init: %@", error.description);
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:0 error:&error];
    if (error) NSLog(@"AVAudioPlayer setCategory: %@", error.description);
    [[AVAudioSession sharedInstance] setActive:YES withOptions:0 error:&error];
    if (error) NSLog(@"AVAudioPlayer setActive: %@", error.description);
    
    [self.player setDelegate:self];
    [self.player prepareToPlay];
    self.isPlaying = [self.player play];
    
    // locked screen and control center:
    
    // this tries to be clever: if the method gets sent in a valid image, it is used
    // else it tries to get it directly from the file
    // if the app ends up only supporting mp3's then this image parameter might well be removed

    MPMediaItemArtwork* artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(10.0, 10.0) requestHandler:^UIImage * _Nonnull(CGSize size) {
        self.playingImage = self.playingImage ? self.playingImage : [self.appDelegate.importer imageForItemAtFileURL:[NSURL fileURLWithPath:path]] ;
        return self.playingImage;
    }] ;
    
    self.nowPlayingInfo = @{
        MPMediaItemPropertyArtist: self.playingArtist,
        MPMediaItemPropertyTitle: self.playingTitle,
        MPMediaItemPropertyPlaybackDuration: [NSString stringWithFormat:@"%f", self.player.duration],
        MPNowPlayingInfoPropertyElapsedPlaybackTime: @0,
        MPNowPlayingInfoPropertyPlaybackRate: @1,
        MPMediaItemPropertyArtwork: artwork
    };
    
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = self.nowPlayingInfo;
}


- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)success {
    
    [self stopPlaying];
    [self.appDelegate.playQueue playNextTrack];
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
    [self.appDelegate.playQueue playNextTrack];
}


- (void) previousTrack {
    [self.appDelegate.playQueue playPreviousTrack];
}



- (void) updateRemoteControls {
    
    if (self.player) {
        
        MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
        NSMutableDictionary *displayInfo = [NSMutableDictionary dictionaryWithDictionary: self.nowPlayingInfo];
        
        float playbackRate = self.isPlaying ? 1.0f : 0.0f;
        [displayInfo setObject:[NSNumber numberWithFloat:playbackRate] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        
        infoCenter.nowPlayingInfo = displayInfo;
    }
    else {
        self.nowPlayingInfo = @{};
    }
}


@end
