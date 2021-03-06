//
//  Album+Functions.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "Album+Functions.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Track+Functions.h"


@implementation Album (Functions)

- (NSArray*) orderedTracks {
    
    NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = @[sortNameDescriptor];
    return [self.tracks sortedArrayUsingDescriptors:sortDescriptors];
}


- (NSArray*) allAlbumTitles {
    
    NSMutableSet* allAlbumTitles = [[NSMutableSet alloc] init];
    NSArray* allAlbums = [Album MR_findAll];
    NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = @[sortNameDescriptor];
    allAlbums = [allAlbums sortedArrayUsingDescriptors:sortDescriptors];
    for (Album* album in allAlbums) {
        [allAlbumTitles addObject:album.title];
    }
    return allAlbumTitles.allObjects;
}


- (UIImage*) artwork {
    
    if (self.image) {
        return [UIImage imageWithData:self.image];
    }
    else {
        return [UIImage imageNamed:@"NoCover"];
    }
}


- (NSInteger) indexOfTrack:(Track*)track {
    
    return [self.orderedTracks indexOfObject:track];
}

@end
