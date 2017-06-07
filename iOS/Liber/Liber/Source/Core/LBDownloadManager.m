//
//  LBDownloadManager.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBDownloadManager.h"
#import "LBDownloadItem.h"
#import "AppDelegate.h"


@interface LBDownloadManager()

@property (nonatomic, strong) NSMutableArray<LBDownloadItem*>* downloadQueue;

@end


@implementation LBDownloadManager


- (id) init {
    
    if (self = [super init]) {
        self.downloadQueue = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}


- (NSArray*) downloadQueue {
    
    return _downloadQueue;
}


- (void) addItemToQueue:(LBDownloadItem*)item {
    
    if (!item) return;
    [_downloadQueue addObject:item];
    [[NSNotificationCenter defaultCenter] postNotificationName:LBAddedDownloadItemToQueue object:nil];
}


- (void) removeItemFromQueue:(LBDownloadItem*)item {
    
    if ([_downloadQueue containsObject:item]) {
        [_downloadQueue removeObject:item];
        [[NSNotificationCenter defaultCenter] postNotificationName:LBRemovedDownloadItemFromQueue object:nil];
    }
}




@end
