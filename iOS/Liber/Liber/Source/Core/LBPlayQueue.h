//
//  LBPlayQueue.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Track;

@interface LBPlayQueue : NSObject

- (void) addTrack:(Track*)track;
- (void) addTracks:(NSArray<Track*>*)tracks;
- (void) startOrPauseTrack:(Track*)track;
- (void) clearQueue;

- (void) playNextTrack;
- (void) playPreviousTrack;

- (BOOL) hasNextTrack;
- (BOOL) hasPreviousTrack;

@property (nonatomic, strong) Track* currentTrack;
- (Track*) nextTrack;
- (Track*) previuosTrack;

@end
