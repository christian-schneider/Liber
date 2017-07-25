//
//  LBDocumentManager.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Album, Track, Artist;


@interface LBDocumentManager : NSObject



/**
 Finds the specific album if it already is in the local DB, else it 
 creates it.

 @param title The title of the album to fetch.
 @param artistName The artist name for the album.
 @return A valid album object, stored in the DB with a valid artist.
 */
- (Album*) albumForTitle:(NSString*)title andArtistName:(NSString*)artistName;



/**
 This moves one track from whatever place to the specified album. It also moves
 the file in the documents directory to the new place and writes the new tags. 
 If the album has a valid image and the track has none, the image is written to 
 the files id3 tags as well.
 
 This should not have any adverse side effects if the original album of the track 
 is the same as the one specified to move to. 

 @param track The track to move.
 @param album The album where the track is moved to.
 */
- (void) moveTrack:(Track*)track toAlbum:(Album*)album;

@end
