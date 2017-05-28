//
//  Track+Functions.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "Track+Functions.h"
#import "Album+Functions.h"


@implementation Track (Functions)


- (NSString*) fullPath {
    
    NSString* docDirPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
    return [[docDirPath stringByAppendingPathComponent:self.album.path] stringByAppendingPathComponent:self.fileName];
}


@end
