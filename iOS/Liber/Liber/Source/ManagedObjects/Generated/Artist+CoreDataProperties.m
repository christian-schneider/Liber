//
//  Artist+CoreDataProperties.m
//  Liber
//
//  Created by galzu on 27.05.17.
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "Artist+CoreDataProperties.h"

@implementation Artist (CoreDataProperties)

+ (NSFetchRequest<Artist *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Artist"];
}

@dynamic name;
@dynamic albums;
@dynamic tracks;

@end
