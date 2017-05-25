//
//  Track+CoreDataProperties.m
//  Liber
//
//  Created by galzu on 25.05.17.
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "Track+CoreDataProperties.h"

@implementation Track (CoreDataProperties)

+ (NSFetchRequest<Track *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Track"];
}

@dynamic duration;
@dynamic fileName;
@dynamic index;
@dynamic title;
@dynamic album;
@dynamic artist;

@end
