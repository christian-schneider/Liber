//
//  LBDownloadItem.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LBDownloadItem : NSObject

@property (nonatomic, strong) NSString* downloadPath;
@property (nonatomic, readwrite) BOOL isDownloading;

@property (nonatomic, strong) id cancelTarget;
@property (nonatomic, assign) SEL cancelSelector;



- (void) updateProgressBytesWritten:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpected:(NSInteger)totalBytesExpected;

- (void) downloadComplete;
- (void) cancelDownload;

@end
