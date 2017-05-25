//
//  Album+CoreDataClass.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist, Track;

NS_ASSUME_NONNULL_BEGIN

@interface Album : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "Album+CoreDataProperties.h"
