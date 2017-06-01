//
//  Track+Functions.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "Track+CoreDataClass.h"


@interface Track (Functions)


/**
 The full file path for this track up to the root of the device.

 @return Full path string.
 */
- (NSString*) fullPath;


/**
 When the album artist is different from the track artist, which can happen in case
 of a compilation, the actual tracks artist name get prepended to the track title.

 @return Either just 'track title' or 'artist name - track title' string.
 */
- (NSString*) displayTrackTitle;

@end
