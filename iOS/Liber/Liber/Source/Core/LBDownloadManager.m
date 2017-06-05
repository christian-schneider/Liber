//
//  LBDownloadManager.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBDownloadManager.h"
#import "LBDownloadItem.h"


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
    
    return self.downloadQueue;
}


- (void) addItemToQueue:(LBDownloadItem*)item {
    
    [_downloadQueue addObject:item];
}


- (void) removeItemFromQueue:(LBDownloadItem*)item {
    
    if ([_downloadQueue containsObject:item]) {
        [_downloadQueue removeObject:item];
    }
}




@end
