//
//  Artist+CoreDataProperties.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "Artist+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Artist (CoreDataProperties)

+ (NSFetchRequest<Artist *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Album *> *albums;
@property (nullable, nonatomic, retain) NSSet<Track *> *tracks;

@end

@interface Artist (CoreDataGeneratedAccessors)

- (void)addAlbumsObject:(Album *)value;
- (void)removeAlbumsObject:(Album *)value;
- (void)addAlbums:(NSSet<Album *> *)values;
- (void)removeAlbums:(NSSet<Album *> *)values;

- (void)addTracksObject:(Track *)value;
- (void)removeTracksObject:(Track *)value;
- (void)addTracks:(NSSet<Track *> *)values;
- (void)removeTracks:(NSSet<Track *> *)values;

@end

NS_ASSUME_NONNULL_END
