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

@property (nonatomic, strong) Track* currentTrack;
- (Track*) nextTrack;
- (Track*) previuosTrack;

- (NSArray<Track*>*) allTracks;
- (NSArray<Track*>*) upcomingTracksIncludingPlaying;
- (NSArray<Track*>*) playedTracks;


@end
