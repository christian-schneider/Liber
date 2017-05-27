//
//  Album+Functions.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "Album+Functions.h"


@implementation Album (Functions)

- (NSArray*) ordereTracks {
    
    NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = @[sortNameDescriptor];
    return [self.tracks sortedArrayUsingDescriptors:sortDescriptors];
}


@end
