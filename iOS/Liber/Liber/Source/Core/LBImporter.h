//
//  LBImporter.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class Album;

@interface LBImporter : NSObject

- (void) importFileIntoLibraryAtPath:(NSString*)filePath originalFilename:(NSString*)originalFilename;

- (BOOL) isPlayableMediaFileAtPath:(NSString*)path;
- (NSDictionary *)id3TagsForURL:(NSURL *)resourceUrl;
- (UIImage*) imageForItemAtFileURL:(NSURL*)url;
- (double) durationOfMediaAtFileURL:(NSURL*)url;

- (NSString *) sanitizeFileNameString:(NSString *)fileName;
- (void) cleanupTempDirectory;
- (NSString*) generateUUID;

- (NSString *)applicationDocumentsDirectoryPath;

- (void) deleteAlbum:(Album*)album;

@end
