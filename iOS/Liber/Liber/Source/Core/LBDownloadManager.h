//
//  LBDownloadManager.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LBDownloadItem;


@interface LBDownloadManager : NSObject

- (NSSet*) downloadQueue;

- (void) addItemToQueue:(LBDownloadItem*)item;
- (void) removeItemFromQueue:(LBDownloadItem*)item;

@end
