//
//  Album+CoreDataProperties.m
//  Liber
//
//  Created by galzu on 26.05.17.
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "Album+CoreDataProperties.h"

@implementation Album (CoreDataProperties)

+ (NSFetchRequest<Album *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Album"];
}

@dynamic image;
@dynamic path;
@dynamic title;
@dynamic artist;
@dynamic tracks;
@dynamic albumArtist;

@end
