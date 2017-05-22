//
//  LBImporter.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LBImporter : NSObject

- (BOOL) isPlayableMediaFile:(NSString*)path;
- (NSDictionary *)id3TagsForURL:(NSURL *)resourceUrl;
- (UIImage*) imageForItemAtFileURL:(NSURL*)url;

@end
