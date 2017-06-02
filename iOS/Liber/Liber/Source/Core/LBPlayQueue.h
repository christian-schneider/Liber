//
//  LBPlayQueue.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Track, Album;


@interface LBPlayQueue : NSObject


- (void) playAlbum:(Album*)album trackAtIndex:(NSInteger)index; 

- (void) addTrack:(Track*)track;
- (void) addTracks:(NSArray<Track*>*)tracks;
- (void) startOrPauseTrack:(Track*)track;
- (void) clearQueue;

- (void) playNextTrack;
- (void) playPreviousTrack;

@property (nonatomic, strong) Track* currentTrack;
- (Track*) nextTrack;
- (Track*) previuosTrack;

- (BOOL) isPlaying;
- (double) currentTrackCurrentPercent;
- (NSString*) currentTrackCurrentTime;
- (NSString*) currentTrackDuration;


/**
 This sets the playback time of the current track, if there is one. 
 Range: 0.0 - 1.0

 @param value The target value.
 */
- (void) setTrackCurrentTimeRelative:(float)value;

@end
