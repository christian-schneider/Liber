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
#import "Album+Functions.h"
#import "Artist+Functions.h"
#import "Track+Functions.h"
#import <MagicalRecord/MagicalRecord.h>
#import <TagLibIOS/TagLibIOS.h>


NSString* const LBAlbumArtist_ID    = @"LBAlbumArtist_ID";
NSString* const LBArtist_ID         = @"LBArtist_ID";
NSString* const LBTrackTitle_ID     = @"LBTrackTitle_ID";
NSString* const LBAlbumTitle_ID     = @"LBAlbumTitle_ID";
NSString* const LBTrackIndex_ID     = @"LBTrackIndex_ID";


struct TagLibImage {
    TagLibImage(const TagLib::String &m = TagLib::String(), const TagLib::ByteVector &d = TagLib::ByteVector()) :
    mimeType(m), data(d) {}
    TagLib::String mimeType;
    TagLib::ByteVector data;
};


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


#pragma mark - Importer

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
    double duration         = [self durationOfMediaAtFileURL:fileURL];
    
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
    }
    else {
        targetFolderPath = [safeArtist stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %@", safeArtist, safeAlbumTitle]];
    }
    
    if ([self createFolderInDocumentsDirIfNotExisting:targetFolderPath]) {
        if ([self copyFileAtPath:filePath toDocumentsDirectoryInFolder:targetFolderPath fileName:originalFilename]) {
            [self storeTrackForArtist:artist
                          albumArtist:albumArtist
                           albumTitle:albumTitle
                           trackTitle:trackTitle
                             duration:duration
                              atIndex:trackIndex
                                image:artwork
                             fileName:originalFilename
                           folderPath:targetFolderPath];
            [[NSNotificationCenter defaultCenter] postNotificationName:LBMusicItemAddedToCollection object:nil];
        }
    }
}


- (void) storeTrackForArtist:(NSString*)artistName
                 albumArtist:(NSString*)albumArtist
                  albumTitle:(NSString*)albumTitle
                  trackTitle:(NSString*)trackTitle
                    duration:(double)duration
                     atIndex:(NSNumber*)index
                       image:(UIImage*)image
                    fileName:(NSString*)fileName
                  folderPath:(NSString*)folderPath {
    
    NSLog(@"trying to add the following item for artistName: %@ -- albumArtist: %@ -- albumTitle: %@ -- trackTitle: %@ -- duration: %f -- index: %@ -- fileName: %@", artistName, albumArtist, albumTitle, trackTitle, duration, index, fileName);
    
    
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
    if (!album || (!albumArtistEntity && album.artist != artist)) {
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
    track.duration = duration;
    
    // relationships
    
    track.album = album;
    track.artist = artist;
    
    album.artist = albumArtistEntity ? albumArtistEntity : artist ;
    [album addArtistsObject:artist];
    if (albumArtistEntity) [album addArtistsObject:albumArtistEntity];
    [album addTracksObject:track];
    
    [artist addAlbumsObject:album];
    if (albumArtist) {
        [albumArtistEntity addAlbumsObject:album];
    }
    [artist addTracksObject:track];
    
    //NSLog(@" now adding this album: %@ for Artist: %@", album.title, album.artist.name);
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}


#pragma mark - Metadata Tags

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


- (void) writeTagsToFile:(NSString*)filePath
              albumTitle:(NSString*)albumTitle
             albumArtist:(NSString*)albumArtist
                  artist:(NSString*)artist
              trackTitle:(NSString*)trackTitle
             trackNumber:(NSInteger)trackNumber
                  artwor:(UIImage*)artwork {
    
    TagLib::FileRef taggableFileRef(filePath.UTF8String);
    taggableFileRef.tag()->setArtist(artist.UTF8String);
    taggableFileRef.tag()->setAlbum(albumTitle.UTF8String);
    taggableFileRef.tag()->setTitle(trackTitle.UTF8String);
    taggableFileRef.tag()->setTrack((uint)trackNumber);
    taggableFileRef.save();
    
    if (albumArtist && albumArtist.length > 0) {
        [self setBandTagWitValue:albumArtist forFileAtPath:filePath];
    }
    
    if (artwork) {
        TagLibImage image;
        image.mimeType = "image/jpeg";
        NSData* imageData = UIImageJPEGRepresentation(artwork, 1.0);
        image.data = TagLib::ByteVector((const char *)[imageData bytes], (uint)imageData.length);
        TagLib::MPEG::File file(filePath.UTF8String);
        TagLib::ID3v2::Tag *tag = file.ID3v2Tag(true);
        [self taglibSetImage:image forTag:tag];
        file.save();
    }
}


- (void) setBandTagWitValue:(NSString*)band forFileAtPath:(NSString*)filePath {
    
    TagLib::MPEG::File file(filePath.UTF8String);
    TagLib::ByteVector handle = "TPE2";
    TagLib::String value = band.UTF8String;
    TagLib::ID3v2::Tag *tag = file.ID3v2Tag(true);
    
    if(!tag->frameList(handle).isEmpty()) {
        tag->frameList(handle).front()->setText(value);
    }
    else {
        TagLib::ID3v2::TextIdentificationFrame *frame =
        new TagLib::ID3v2::TextIdentificationFrame(handle, TagLib::String::UTF8);
        tag->addFrame(frame);
        frame->setText(value);
    }
    file.save();
}


- (void) taglibSetImage:(TagLibImage&)image forTag:(TagLib::ID3v2::Tag*)tag {
    
    TagLib::ID3v2::FrameList frames = tag->frameList("APIC");
    TagLib::ID3v2::AttachedPictureFrame *frame = 0;
    
    if(frames.isEmpty()) {
        frame = new TagLib::ID3v2::AttachedPictureFrame;
        tag->addFrame(frame);
    }
    else {
        frame = static_cast<TagLib::ID3v2::AttachedPictureFrame *>(frames.front());
    }
    
    frame->setPicture(image.data);
    frame->setMimeType(image.mimeType);
}


#pragma mark - Various Utility Functions

- (UIImage*) imageForItemAtFileURL:(NSURL*)url {
    
    if (!url) return nil;
    
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


- (NSString *) sanitizeFileNameString:(NSString *)filename {
    
    if (!filename) return nil;
    
    NSMutableCharacterSet *nullCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"\0"];
    filename = filename = [[filename componentsSeparatedByCharactersInSet:nullCharacterSet] componentsJoinedByString:@"" ];
    filename = [filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    filename = [[filename componentsSeparatedByCharactersInSet:[NSCharacterSet illegalCharacterSet]] componentsJoinedByString:@"" ];
    filename = [[filename componentsSeparatedByCharactersInSet:[NSCharacterSet symbolCharacterSet]] componentsJoinedByString:@"" ];
    return filename;
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


- (double) durationOfMediaAtFileURL:(NSURL*)url {
    
    double duration = 0.0;
    NSError* error;
    AVAudioPlayer* avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (!error) duration = avAudioPlayer.duration;
    return duration;
}


- (BOOL) copyFileAtPath:(NSString*)filePath toDocumentsDirectoryInFolder:(NSString*)folderPath fileName:(NSString*)fileName {
    
    NSString* targetPath = [[self.applicationDocumentsDirectoryPath stringByAppendingPathComponent:folderPath] stringByAppendingPathComponent:fileName];
    NSError* error;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager moveItemAtPath:filePath toPath:targetPath error:&error];
    if (error) {
        NSLog(@"error moving file: %@ ---- %@", fileName, error.localizedDescription);
        NSLog(@"filepath: %@", filePath);
        NSLog(@"targetPath: %@", targetPath);
        return NO;
    }
    return YES;
}


- (BOOL) createFolderInDocumentsDirIfNotExisting:(NSString*)folderPath {
    
    NSString* fullPath = [self.applicationDocumentsDirectoryPath stringByAppendingPathComponent:folderPath];
    
    BOOL isDirectory;
    if ([NSFileManager.defaultManager fileExistsAtPath:folderPath isDirectory:&isDirectory]) return YES && isDirectory;
    
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:fullPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
        return NO;
    }
    return YES;
}


- (BOOL) isPlayableMediaFileAtPath:(NSString*)path {
    
    // atm, limit to files which usually have or can have embedded image data
    NSArray* supportedMediaExtensions = @[
                                          @"mp3",
                                          @"mp4",
                                          @"m4a"
                                          
                                          // below are all the supported audio formats file endings by iOS
                                          // the current duration method should work on all of these
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


#pragma mark - Album Removal

- (void) deleteAlbum:(Album*)album {
    
    NSString* fullAlbumPath = [self.applicationDocumentsDirectoryPath stringByAppendingPathComponent:album.path];
    
    if (self.appDelegate.playQueue.currentTrack.album == album) {
        [self.appDelegate.playQueue clearQueue];
    }
    
    NSMutableSet* trackAndAlbumArtists = [NSMutableSet setWithCapacity:1];
    
    for (Track* track in album.tracks) {
        [self deleteTrackFile:track.fullPath];
        if (track.artist) {
            [trackAndAlbumArtists addObject:track.artist];
        }
        [track MR_deleteEntity];
    }
    
    [trackAndAlbumArtists addObject:album.artist];
    [album MR_deleteEntity];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    for (Artist* artist in trackAndAlbumArtists) {
        if (artist.albums.count == 0) {
            [artist MR_deleteEntity];
        }
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:LBAlbumDeleted object:nil];
    
    [self deleteDirectoryIfEmpty:fullAlbumPath];
    [self deleteDirectoryIfEmpty:fullAlbumPath.stringByDeletingLastPathComponent];
}


#pragma mark - File System Operations

- (void) deleteDirectoryIfEmpty:(NSString*)path {
    
    NSError* error = nil;
    NSArray *folderContents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:&error];
    if (folderContents && !error) {
        if (folderContents.count == 0) {
            error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
    }
    if (error) {
        NSLog(@"Error removing directory: %@ -- %@", path.lastPathComponent, error.description);
    }
}


- (void) deleteTrackFile:(NSString*)path {
    
    BOOL isDir;
    if ([NSFileManager.defaultManager fileExistsAtPath:path isDirectory:&isDir]) {
        if (!isDir) {
            NSError* error = nil;
            [NSFileManager.defaultManager removeItemAtPath:path error:&error];
            if (error) {
                NSLog(@"Error removing file: %@ -- %@", path.lastPathComponent, error.description);
            }
        }
    }
}

@end

