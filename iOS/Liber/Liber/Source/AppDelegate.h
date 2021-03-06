//
//  AppDelegate.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LBImporter.h"
#import "LBPlayQueue.h"
#import "LBDownloadManager.h"
#import "LBDocumentManager.h"


extern NSString* const LBMusicItemAddedToCollection;
extern NSString* const LBPlayQueuePlayItemChanged;
extern NSString* const LBPlayQueuePlayStatusChanged;
extern NSString* const LBPlayQueueFinishedPlaying;
extern NSString* const LBCurrentTrackPlayProgress;
extern NSString* const LBCurrentTrackStatusChanged;
extern NSString* const LBAlbumDeleted;
extern NSString* const LBAddedDownloadItemToQueue;
extern NSString* const LBRemovedDownloadItemFromQueue;
extern NSString* const LBDownloadItemDownloadProgress;
extern NSString* const LBTrackEditEnded;
extern NSString* const LBArtistEditEnded;
extern NSString* const LBAlbumEditEnded;
extern NSString* const LBDropboxLoginCancelled;
extern NSString* const LBCollectionShowAlbum;


@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) LBPlayQueue* playQueue;
@property (nonatomic, strong) LBImporter* importer;
@property (nonatomic, strong) LBDownloadManager* downloadManager;
@property (nonatomic, strong) LBDocumentManager* documentsManager;


@end

