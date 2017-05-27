//
//  Artist+CoreDataClass.h
//  Liber
//
//  Created by galzu on 27.05.17.
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
