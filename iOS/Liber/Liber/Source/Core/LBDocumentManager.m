//
//  LBDocumentManager.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBDocumentManager.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Album+Functions.h"
#import "Artist+Functions.h"


@implementation LBDocumentManager


- (Album*) albumForTitle:(NSString*)albumTitle andArtistName:(NSString*)artistName {
    
    Artist* artist = [Artist MR_findFirstByAttribute:@"name" withValue:artistName];
    if (!artist) {
        artist = [Artist MR_createEntity];
        artist.name = artistName;
    }
    
    Album* album = [Album MR_findFirstByAttribute:@"title" withValue:albumTitle];
    if (!album || album.artist != artist) {
        album = [Album MR_createEntity];
        album.artist = artist;
        album.title = albumTitle;
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return album;
}


- (void) moveTrack:(Track*)track toAlbum:(Album*)album {
    
    // TODO: continue here
}

@end
