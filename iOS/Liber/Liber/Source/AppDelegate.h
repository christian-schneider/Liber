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


extern NSString* const LBMusicItemAddedToCollection;
extern NSString* const LBPlayQueuePlayItemChanged;
extern NSString* const LBPlayQueuePlayStatusChanged;
extern NSString* const LBCurrentTrackPlayProgress;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LBImporter* importer;
@property (strong, nonatomic) LBPlayQueue* playQueue;

@end

