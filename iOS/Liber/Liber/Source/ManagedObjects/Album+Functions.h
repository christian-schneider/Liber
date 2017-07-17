//
//  Album+Functions.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "Album+CoreDataClass.h"
#import <UIKit/UIKit.h>
@class Track;

@interface Album (Functions)

- (NSArray*) orderedTracks;

- (NSArray*) allAlbumTitles;

- (UIImage*) artwork;

- (NSInteger) indexOfTrack:(Track*)track;

@end
