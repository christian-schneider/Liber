//
//  LBDownloadItem.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBDownloadItem.h"
#import "AppDelegate.h"


@interface LBDownloadItem()

@property (nonatomic, readwrite) NSInteger totalBytesWritten;
@property (nonatomic, readwrite) NSInteger totalBytesExpected;

@property (nonatomic, weak) AppDelegate* appDelegate;

@end


@implementation LBDownloadItem

- (id) init {
    
    if (self = [super init]) {
        self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    }
    return self;
}


- (void) updateProgressBytesWritten:(NSInteger)bytesWritten totalBytesExpected:(NSInteger)totalBytesExpected {
    
    self.totalBytesWritten = bytesWritten;
    self.totalBytesExpected = totalBytesExpected;
    
    [NSNotificationCenter.defaultCenter postNotificationName:LBDownloadItemDownloadProgress object:self];
}


- (void) downloadComplete {
    
    [self.appDelegate.downloadManager removeItemFromQueue:self];
}


- (void) cancelDownload {
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.cancelTarget performSelector:self.cancelSelector];
    #pragma clang diagnostic pop
    
    [self.appDelegate.downloadManager removeItemFromQueue:self];
}


- (NSString*) description {
    
    return [NSString stringWithFormat:@"LBDownloadItem: %@", self.downloadPath];
}


@end
