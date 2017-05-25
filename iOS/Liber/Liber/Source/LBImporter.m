//
//  LBImporter.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBImporter.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface LBImporter()

@property (nonatomic, weak) AppDelegate* appDelegate;

@end


@implementation LBImporter


- (id) init {
    
    if (self = [super init]) {
        self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    }
    return self;
}


- (void) importFileIntoLibraryAtPath:(NSString*)filePath originalFilename:(NSString*)originalFilename {
    
    // find artist name, track title, album name, and image (all optional) from file
    
    NSURL* fileURL = [NSURL fileURLWithPath:filePath];

    NSDictionary* id3Tags = [self.appDelegate.importer id3TagsForURL:fileURL];

    NSString* artist = [id3Tags objectForKey:@"artist"];
    NSString* trackTitle = [id3Tags objectForKey:@"title"];
    NSString* albumTitle = [id3Tags objectForKey:@"album"];
    
    if (!artist && !albumTitle) {
        
    }
    
    UIImage* artwork = [self imageForItemAtFileURL:fileURL];
    
    
    // copy to folder with appropriate path - in case none of the above move to 'Files' folder
    // find or create album and artist
    // check for track duplicate
    // create track entry in db
    
    NSLog(@"import this file: %@", filePath);
    
    NSLog(@"--- original filename: %@", originalFilename);
}



- (BOOL) isPlayableMediaFileAtPath:(NSString*)path {

    NSArray* supportedMediaExtensions = @[
        @"mp3",
        @"mp4",
        @"m4a"
        
        // below are all the supported audio formats file endings by iOS
        // atm, limit to files which usually have embedded image data
                                          
        /*
        @"aac",
        @"adts",
        @"ac3",
        @"aif",
        @"aiff",
        @"aifc",
        @"caf",
        @"mp3",
        @"mp4",
        @"m4a",
        @"snd",
        @"au",
        @"sd2",
        @"wav"
        */
    ];
    NSString* extension = path.pathExtension.lowercaseString;
    return [supportedMediaExtensions containsObject:extension];
}

- (NSDictionary *)id3TagsForURL:(NSURL *)resourceUrl {
    
    AudioFileID fileID;
    OSStatus result = AudioFileOpenURL((__bridge CFURLRef)resourceUrl, kAudioFileReadPermission, 0, &fileID);
    
    if (result != noErr) {
        NSLog(@"Error reading tags: %i", (int)result);
        return nil;
    }
    
    CFDictionaryRef piDict = nil;
    UInt32 piDataSize = sizeof(piDict);
    
    result = AudioFileGetProperty(fileID, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict);
    if (result != noErr)
        NSLog(@"Error reading tags. AudioFileGetProperty failed");
    
    AudioFileClose(fileID);
    
    NSDictionary *tagsDictionary = [NSDictionary dictionaryWithDictionary:(__bridge NSDictionary*)piDict];
    CFRelease(piDict);
    
    return tagsDictionary;
}


- (UIImage*) imageForItemAtFileURL:(NSURL*)url {
    
    if (!url.isFileURL) {
        url = [NSURL fileURLWithPath:url.absoluteString];
    }

    AVURLAsset *avURLAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    for (NSString *format in [avURLAsset availableMetadataFormats]) {
        for (AVMetadataItem *metadataItem in [avURLAsset metadataForFormat:format]) {
            if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                return [UIImage imageWithData:(NSData*)metadataItem.value];
            }
        }
    }
    return nil;
}


- (NSString *) sanitizeFileNameString:(NSString *)fileName {
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    return [[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}




- (void) cleanupTempDirectory {
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    NSArray* cacheFiles = [fileManager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:&error];
    if (error) NSLog(@"cleanupTempDirectory: %@", error.localizedDescription);
    for(NSString * file in cacheFiles) {
        if ([file.lastPathComponent hasPrefix:@"current"] || [file.lastPathComponent hasPrefix:@"import"]) {
            error = nil;
            NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:file];
            NSLog(@"filePath to remove = %@", filePath);
            BOOL removed = [fileManager removeItemAtPath:filePath error:&error];
            if (!removed) NSLog(@"Not removed: %@", filePath);
            if(error) NSLog(@"cleanupTempDirectory: %@", [error description]);
        }
        
    }
}


- (NSString*) generateUUID {
    
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

@end
