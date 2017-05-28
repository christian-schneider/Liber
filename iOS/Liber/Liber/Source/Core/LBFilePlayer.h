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

@property (readonly) BOOL isPlaying;
@property (readonly) BOOL isPaused;
- (void) pausePlaying;
- (void) continuePlaying;
- (Track*) currentTrack;
- (void) stopPlaying;

@end
