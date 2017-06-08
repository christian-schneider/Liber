//
//  LBDownloadItemTableViewCell.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBDownloadItemTableViewCell.h"
#import "LBDownloadItem.h"


@implementation LBDownloadItemTableViewCell

- (IBAction) cancelDownload:(UIButton*)sender {
    
    [self.downloadItem cancelDownload];
}


- (void) updateProgressBar {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = (double)self.downloadItem.totalBytesWritten / self.downloadItem.totalBytesExpected;
    });
}

@end
