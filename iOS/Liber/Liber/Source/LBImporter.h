//
//  LBImporter.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBImporter : NSObject

- (BOOL) isPlayableMediaFile:(NSString*)path;
- (NSDictionary *)id3TagsForURL:(NSURL *)resourceUrl;

@end
