//
//  LBFilePlayer.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class Track;


@interface LBFilePlayer : NSObject

- (void) playTrack:(Track*)track;
@property (nonatomic, strong) Track* currentTrack;

@property (readonly) BOOL isPlaying;
@property (readonly) BOOL isPaused;
- (void) pausePlaying;
- (void) continuePlaying;
- (Track*) currentTrack;
- (void) stopPlaying;


- (double) currentTrackCurrentPercent;
- (NSString*) currentTrackCurrentTime;
- (NSString*) currentTrackDuration;


/**
 Should be called when the PlayQueue reaches it's end. Sets the AVAudioSession to AVAudioSessionCategoryAmbient which removes the app from the lock screen.
 */
- (void) deactivateAudioSession;


/**
 This sets the playback time of the current track, if there is one.
 Range: 0.0 - 1.0
 
 @param value The target value.
 */
- (void) setTrackCurrentTimeRelative:(float)value;

@end
