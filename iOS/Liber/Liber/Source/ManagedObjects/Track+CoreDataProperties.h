//
//  Track+CoreDataProperties.h
//  Liber
//
//  Created by galzu on 25.05.17.
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "Track+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Track (CoreDataProperties)

+ (NSFetchRequest<Track *> *)fetchRequest;

@property (nonatomic) float duration;
@property (nullable, nonatomic, copy) NSString *fileName;
@property (nonatomic) int16_t index;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, retain) Album *album;
@property (nullable, nonatomic, retain) Artist *artist;

@end

NS_ASSUME_NONNULL_END
