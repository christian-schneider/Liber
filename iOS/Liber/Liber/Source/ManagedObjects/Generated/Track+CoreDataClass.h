//
//  Track+CoreDataClass.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album, Artist;

NS_ASSUME_NONNULL_BEGIN

@interface Track : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "Track+CoreDataProperties.h"
