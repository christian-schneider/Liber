//
//  Album+CoreDataProperties.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "Album+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Album (CoreDataProperties)

+ (NSFetchRequest<Album *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, copy) NSString *path;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, retain) Artist *artist;
@property (nullable, nonatomic, retain) NSSet<Track *> *tracks;

@end

@interface Album (CoreDataGeneratedAccessors)

- (void)addTracksObject:(Track *)value;
- (void)removeTracksObject:(Track *)value;
- (void)addTracks:(NSSet<Track *> *)values;
- (void)removeTracks:(NSSet<Track *> *)values;

@end

NS_ASSUME_NONNULL_END
