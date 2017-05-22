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


@implementation LBImporter

- (BOOL) isPlayableMediaFile:(NSString*)path {

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

@end
