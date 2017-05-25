//
//  Artist+CoreDataClass.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album, Track;

NS_ASSUME_NONNULL_BEGIN

@interface Artist : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "Artist+CoreDataProperties.h"
