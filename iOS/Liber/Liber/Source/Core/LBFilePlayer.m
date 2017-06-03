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
#import "NSString+Functions.h"
@import MediaPlayer;
@import AVFoundation;


@interface LBFilePlayer() <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, weak) AppDelegate* appDelegate;

@property (readwrite) BOOL isPlaying;

@property (nonatomic, strong) NSString* playingArtist;
@property (nonatomic, strong) NSString* playingTitle;
@property (nonatomic, strong) UIImage* playingImage;

@property (nonatomic, strong) NSDictionary* nowPlayingInfo;

@property (nonatomic, strong) NSTimer* progressTimer;

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
    
    if (!track) return;
    
    self.currentTrack = track;
    UIImage* image = [self.appDelegate.importer imageForItemAtFileURL:[NSURL fileURLWithPath:track.fullPath]];
    if (!image) {
        image = [UIImage imageWithData:track.album.image];
    }
    NSString* displayArtistName = [NSString stringWithFormat:@"%@ - %@", track.album.artist.name, track.album.title];
    [self play:track.fullPath artist:displayArtistName trackTitle:track.displayTrackTitle image:image];
    [self.player prepareToPlay];
    [self.player play];
    [self startProgressTimer];
    // this ugly workaround is only need for when the user enters a new album and before pressing on the big
    // play button has scrubbed on the slider. really only in this case, this call is relevant to quickly update the position
    // it is not optimal, but it is in relation with the reloading of the table view in AlbumVC causing problems with
    // the adaptive square album art image table cell height when directly using [self.tableView reloadData].
    // for further inspection see the workaround in addObserverForName:LBCurrentTrackStatusChanged in AlbumVC
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self postProgressNotification];
    });
}


- (void) pausePlaying {

    [self stopProgressTimer];
    [self.player pause];
    self.isPlaying = NO;
    [self postNotificationCurrentTrackStatusChanged];
}


- (void) continuePlaying {
    
    [self.player play];
    self.isPlaying = YES;
    [self startProgressTimer];
    [self postNotificationCurrentTrackStatusChanged];
}


- (void) stopPlaying {
    
    [self stopProgressTimer];
    [self.player stop];
    self.isPlaying = NO;
    self.playingArtist = @"";
    self.playingTitle = @"";
    self.playingImage = nil;
    [self postNotificationCurrentTrackStatusChanged];
}


- (void) postNotificationCurrentTrackStatusChanged {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LBCurrentTrackStatusChanged object:nil];
}


- (void) deactivateAudioSession {
    
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient withOptions:0 error:nil];
}


- (Track*) currentTrack {
    
    return self.currentTrack;
}


- (BOOL) isPaused {
    
    return self.currentTrack && !self.isPlaying ;
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
        MPNowPlayingInfoPropertyElapsedPlaybackTime: [NSString stringWithFormat:@"%f", self.player.currentTime],
        MPNowPlayingInfoPropertyPlaybackRate: @1,
        MPMediaItemPropertyArtwork: artwork
    };
    
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = self.nowPlayingInfo;
}


- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)success {
    
    [self stopPlaying];
    [self stopProgressTimer];
    if (self.appDelegate.playQueue.nextTrack) {
        [self.appDelegate.playQueue playNextTrack];
    }
    else {
        self.currentTrack = nil;
        [self deactivateAudioSession];
        [[NSNotificationCenter defaultCenter] postNotificationName:LBPlayQueueFinishedPlaying object:nil];
    }
}


- (void) audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    
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
}


- (void) nextTrack {
    [self.appDelegate.playQueue playNextTrack];
}


- (void) previousTrack {
    [self.appDelegate.playQueue playPreviousTrack];
}


- (void) startProgressTimer {
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self postProgressNotification];
    }];
}


- (void) stopProgressTimer {
    
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}


- (void) postProgressNotification {
    
    NSDictionary* timeProgressDict = @{
        @"currentTime"      : self.currentTrackCurrentTime,
        @"duration"         : self.currentTrackDuration,
        @"currentPercent"   : [NSNumber numberWithDouble:self.currentTrackCurrentPercent]
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:LBCurrentTrackPlayProgress object:timeProgressDict];
}


- (double) currentTrackCurrentPercent {
    
    return self.player.currentTime / self.player.duration ;
}


- (NSString*) currentTrackCurrentTime {
    
    return [NSString formatTime:self.player.currentTime];
}


- (NSString*) currentTrackDuration {
    
    return [NSString formatTime:self.player.duration] ;
}


- (void) setCurrentTrackCurrentTimeRelative:(float)value {
    
    if (self.isPlaying) [self stopProgressTimer];
    self.player.currentTime = value * self.player.duration;
    if (self.isPlaying) [self startProgressTimer];
    
    NSMutableDictionary* newPlayingInfo = self.nowPlayingInfo.mutableCopy;    
    [newPlayingInfo setObject:[NSString stringWithFormat:@"%f", self.player.currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    self.nowPlayingInfo = newPlayingInfo;
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = self.nowPlayingInfo;
}


@end
