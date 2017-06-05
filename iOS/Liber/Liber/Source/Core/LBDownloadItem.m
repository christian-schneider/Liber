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

@end
