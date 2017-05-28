//
//  LBPlayQueue.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBPlayQueue.h"
#import "LBFilePlayer.h"
#import "Track+CoreDataClass.h" 


@interface LBPlayQueue()

@property (nonatomic, strong) NSMutableArray<Track*>* queue;
@property (nonatomic, strong) LBFilePlayer* filePlayer;

@end


@implementation LBPlayQueue

- (id) init {
    
    if (self = [super init]) {
        self.queue = [NSMutableArray arrayWithCapacity:10];
        self.filePlayer = [[LBFilePlayer alloc] init]; 
    }
    return self;
}


- (void) clearQueue {
    
    self.currentTrack = nil;
    [self.queue removeAllObjects];
    [self.filePlayer stopPlaying];
}


- (void) startOrPauseTrack:(Track*)track {
    
    if (!self.filePlayer.isPlaying) {
        self.currentTrack = track;
        [self.filePlayer playTrack:track];
        return;
    }
    
    if (self.currentTrack == track) {
        if (self.filePlayer.isPlaying) {
            [self.filePlayer pausePlaying];
        }
        else {
            [self.filePlayer continuePlaying];
        }
    }
}


- (void) playNextTrack {
    
    if (self.nextTrack) {
        [self.filePlayer stopPlaying];
        [self startOrPauseTrack:self.nextTrack];
    }
}


- (void) playPreviousTrack {
    
    if (self.previuosTrack) {
        [self.filePlayer stopPlaying];
        [self startOrPauseTrack:self.previuosTrack];
    }
}


- (void) addTrack:(Track*)track{
    
    [self.queue addObject:track];
}


- (void) addTracks:(NSArray<Track*>*)tracks {
 
    [self.queue addObjectsFromArray:tracks];
}


- (Track*) nextTrack {
    
    if (self.queue.count == 0) return nil;

    NSInteger indexOfCurrentTrack = [self.queue indexOfObject:self.currentTrack];
    NSInteger indexOfNextTrack = indexOfCurrentTrack + 1;
    if (self.queue.count > indexOfNextTrack) {
        return [self.queue objectAtIndex:indexOfNextTrack];
    }
    else {
        return nil;
    }
}


- (Track*) previuosTrack {
    
    if (self.queue.count == 0) return nil;
    
    if (self.currentTrack == self.queue.firstObject) {
        return self.currentTrack;
    }
    
    NSInteger indexOfCurrentTrack = [self.queue indexOfObject:self.currentTrack];
    NSInteger indexOfPreviousTrack = indexOfCurrentTrack - 1;
    if (indexOfPreviousTrack >= 0) {
        return [self.queue objectAtIndex:indexOfPreviousTrack];
    }
    return nil;
}


- (NSArray<Track*>*) allTracks {
    
    return self.queue;
}


- (NSArray<Track*>*) upcomingTracksIncludingPlaying {
    
    if (self.queue.count == 0) return nil;
    
    NSMutableArray* upcoming = [NSMutableArray arrayWithCapacity:self.queue.count];
    NSInteger indexOfCurrentTrack = [self.queue indexOfObject:self.currentTrack];
    for (NSInteger i = indexOfCurrentTrack ; i < self.queue.count ; i++) {
        [upcoming addObject:[self.queue objectAtIndex:i]] ;
    }
    return upcoming;
}


- (NSArray<Track*>*) playedTracks {
    
    if (self.queue.count == 0) return nil;
    
    NSMutableArray* played = [NSMutableArray arrayWithCapacity:self.queue.count];
    NSInteger indexOfCurrentTrack = [self.queue indexOfObject:self.currentTrack];
    for (NSInteger i = 0 ; i < indexOfCurrentTrack ; i++) {
        [played addObject:[self.queue objectAtIndex:i]] ;
    }
    return played;
}


@end
