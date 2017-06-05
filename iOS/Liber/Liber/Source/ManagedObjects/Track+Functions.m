//
//  Track+Functions.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "Track+Functions.h"
#import "Album+Functions.h"
#import "Artist+Functions.h"
#import "AppDelegate.h"


@implementation Track (Functions)


- (NSString*) fullPath {
    
    NSString* docDirPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
    return [[docDirPath stringByAppendingPathComponent:self.album.path] stringByAppendingPathComponent:self.fileName];
}


- (NSString*) displayTrackTitle {
    
    NSString* displayTrackTitle = @"";
    if (self.album.artist != self.artist) {
        displayTrackTitle = [NSString stringWithFormat:@"%@ - %@", self.artist.name, self.title];
    }
    else {
        displayTrackTitle = self.title;
    }
    return displayTrackTitle;
}


- (UIImage*) artwork {
    
    AppDelegate* appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    UIImage* image = [appDelegate.importer imageForItemAtFileURL:[NSURL fileURLWithPath:self.fullPath]];
    if (!image) {
        image = [UIImage imageWithData:self.album.image];
    }
    return image;
}


@end
