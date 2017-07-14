//
//  Artist+Functions.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "Artist+Functions.h"
#import <MagicalRecord/MagicalRecord.h>


@implementation Artist (Functions)

- (NSArray*) allArtistNames {
    
    NSMutableSet* allArtistNames = [[NSMutableSet alloc] init];
    NSArray* allArtists = [Artist MR_findAll];
    NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortNameDescriptor];
    allArtists = [allArtists sortedArrayUsingDescriptors:sortDescriptors];
    for (Artist* artist in allArtists) {
        [allArtistNames addObject:artist.name];
    }
    return allArtistNames.allObjects;
}


- (NSArray*) albumsSorted {
    
    NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = @[sortNameDescriptor];
    return [self.albums sortedArrayUsingDescriptors:sortDescriptors];
}

@end
