//
//  LBDownloadItem.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBDownloadItem.h"


@implementation LBDownloadItem

- (void) updateProgressBytesWritten:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpected:(NSInteger)totalBytesExpected {
    
    NSLog(@"LBDownloadItem - download progress %ld %ld %ld", bytesWritten, totalBytesWritten, totalBytesExpected);
}


- (void) downloadComplete {
    
    NSLog(@"LBDownloadItem download complete");
}


- (void) cancelDownload {
    
    NSLog(@"Cancelling donwload: %@", self);
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.cancelTarget performSelector:self.cancelSelector];
    #pragma clang diagnostic pop
}


- (NSString*) description {
    
    return [NSString stringWithFormat:@"LBDownloadItem: %@", self.downloadPath];
}


@end
