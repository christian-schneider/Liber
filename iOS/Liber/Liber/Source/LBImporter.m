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
#import "Album+CoreDataClass.h"
#import "Artist+CoreDataClass.h"
#import "Track+CoreDataClass.h"
#import <MagicalRecord/MagicalRecord.h>


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
    // copy to folder with appropriate path - in case none of the above move to respective 'Unknown' folders
    // find or create album and artist
    // check for track duplicate
    // create track entry in db
    
    NSURL* fileURL          = [NSURL fileURLWithPath:filePath];
    NSDictionary* id3Tags   = [self.appDelegate.importer id3TagsForURL:fileURL];
    
    NSString* albumArtist   = [id3Tags objectForKey:@"TPE2"];
    NSString* artist        = [id3Tags objectForKey:@"TPE1"];
    NSString* trackTitle    = [id3Tags objectForKey:@"TIT2"];
    NSString* albumTitle    = [id3Tags objectForKey:@"TALB"];
    NSNumber* trackIndex    = [id3Tags objectForKey:@"TRCK"];
    UIImage* artwork        = [self imageForItemAtFileURL:fileURL];         // set breakpoint here to inspect the tags returned by a specific file
    
    // albumArtist can be nil
    if (!artist)        artist = NSLocalizedString(@"Unknow Artist", nil);
    if (!albumTitle)    albumTitle = NSLocalizedString(@"Unknown Album", nil);
    if (!trackTitle)    trackTitle = originalFilename.lastPathComponent.stringByDeletingPathExtension;
    
    NSString* safeArtist        = [self sanitizeFileNameString:artist];
    NSString* safeAlbumArtist   = [self sanitizeFileNameString:albumArtist];
    NSString* safeAlbumTitle    = [self sanitizeFileNameString:albumTitle];
    NSString* targetFolderPath = nil;
    if (albumArtist && albumArtist.length > 0) {
        targetFolderPath = [safeAlbumArtist stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %@", safeAlbumArtist, safeAlbumTitle]];
    } else {
        targetFolderPath = [safeArtist stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %@", safeArtist, safeAlbumTitle]];
    }
    
    [self createFolderInDocumentsDirIfNotExisting:targetFolderPath];
    [self copyFileAtPath:filePath toDocumentsDirectoryInFolder:targetFolderPath fileName:originalFilename];
    [self storeTrackForArtist:artist
                  albumArtist:albumArtist
                   albumTitle:albumTitle
                   trackTitle:trackTitle
                      atIndex:trackIndex
                        image:artwork
                     fileName:originalFilename
                   folderPath:targetFolderPath];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LBMusicItemAddedToCollection object:nil];
}


- (void) storeTrackForArtist:(NSString*)artistName
                 albumArtist:(NSString*)albumArtist
                  albumTitle:(NSString*)albumTitle
                  trackTitle:(NSString*)trackTitle
                     atIndex:(NSNumber*)index
                       image:(UIImage*)image
                    fileName:(NSString*)fileName
                  folderPath:(NSString*)folderPath {
    
    Artist* albumArtistEntity = [Artist MR_findFirstByAttribute:@"name" withValue:albumArtist];
    if (albumArtist && !albumArtistEntity) {
        albumArtistEntity = [Artist MR_createEntity];
        albumArtistEntity.name = albumArtist;
    }
    
    Artist* artist = [Artist MR_findFirstByAttribute:@"name" withValue:artistName];
    if (!artist) {
        artist = [Artist MR_createEntity];
    }
    artist.name = artistName;
    
    Album* album = [Album MR_findFirstByAttribute:@"title" withValue:albumTitle];
    if (!album) {
        album = [Album MR_createEntity];
    }
    album.title = albumTitle;
    album.path = folderPath;
    if (image) {
        NSData* imageData = UIImageJPEGRepresentation(image, 100.f);
        album.image = imageData;
    }
    
    Track* track = [Track MR_findFirstByAttribute:@"title" withValue:trackTitle];
    if (!track) {
        track = [Track MR_createEntity];
    }
    track.title = trackTitle;
    track.fileName = fileName;
    if (index) {
        track.index = index.integerValue;
    }
    
    // relationships
    
    track.album = album;
    track.artist = artist;
    
    album.artist = albumArtistEntity ? albumArtistEntity : artist ;
    [album addTracksObject:track];
    
    [artist addAlbumsObject:album];
    [artist addTracksObject:track];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}


- (void) copyFileAtPath:(NSString*)filePath toDocumentsDirectoryInFolder:(NSString*)folderPath fileName:(NSString*)fileName {
    
    NSString* targetPath = [[self.applicationDocumentsDirectoryPath stringByAppendingPathComponent:folderPath] stringByAppendingPathComponent:fileName];
    NSError* error;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager moveItemAtPath:filePath toPath:targetPath error:&error];
    if (error) {
        NSLog(@"error moving file: %@", error.localizedDescription);
    }
}


- (void) createFolderInDocumentsDirIfNotExisting:(NSString*)folderPath {
    
    NSString* fullPath = [self.applicationDocumentsDirectoryPath stringByAppendingPathComponent:folderPath];
    
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:fullPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
    }
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
        return nil;
    }
    
    //read raw ID3Tag size
    UInt32 id3DataSize = 0;
    char *rawID3Tag = NULL;
    result = AudioFileGetPropertyInfo(fileID, kAudioFilePropertyID3Tag, &id3DataSize, NULL);
    if (result != noErr) {
        AudioFileClose(fileID);
        return nil;
    }
    
    rawID3Tag = (char *)malloc(id3DataSize);
    
    //read raw ID3Tag
    result = AudioFileGetProperty(fileID, kAudioFilePropertyID3Tag, &id3DataSize, rawID3Tag);
    if (result != noErr) {
        free(rawID3Tag);
        AudioFileClose(fileID);
        return nil;
    }
    
    CFDictionaryRef piDict = nil;
    UInt32 piDataSize = sizeof(piDict);
    
    //this key returns some other dictionary, which works also in iPod library
    result = AudioFormatGetProperty(kAudioFormatProperty_ID3TagToDictionary, id3DataSize, rawID3Tag, &piDataSize, &piDict);
    if (result != noErr) {
        return nil;
    }
    
    free(rawID3Tag);
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
    
    if (!fileName) return nil;
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


- (NSString *)applicationDocumentsDirectoryPath {
    
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
}

@end
