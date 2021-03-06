//
//  AppDelegate.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "AppDelegate.h"
#import "LBMusicCollectionViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import <BoxContentSDK/BOXContentSDK.h>


NSString* const LBMusicItemAddedToCollection    = @"LBMusicItemAddedToCollection";
NSString* const LBPlayQueuePlayItemChanged      = @"LBPlayQueuePlayItemChanged";
NSString* const LBPlayQueuePlayStatusChanged    = @"LBPlayQueuePlayStatusChanged";
NSString* const LBPlayQueueFinishedPlaying      = @"LBPlayQueueFinishedPlaying";
NSString* const LBCurrentTrackPlayProgress      = @"LBCurrentTrackPlayProgress";
NSString* const LBCurrentTrackStatusChanged     = @"LBCurrentTrackStatusChanged";
NSString* const LBAlbumDeleted                  = @"LBAlbumDeleted";
NSString* const LBAddedDownloadItemToQueue      = @"LBAddedDownloadItemToQueue";
NSString* const LBRemovedDownloadItemFromQueue  = @"LBRemovedDownloadItemFromQueue";
NSString* const LBDownloadItemDownloadProgress  = @"LBDownloadItemDownloadProgress";
NSString* const LBTrackEditEnded                = @"LBTrackEditEnded";
NSString* const LBArtistEditEnded               = @"LBArtistEditEnded";
NSString* const LBAlbumEditEnded                = @"LBAlbumEditEnded";
NSString* const LBDropboxLoginCancelled         = @"LBDropboxLoginCancelled";
NSString* const LBCollectionShowAlbum           = @"LBCollectionShowAlbum";


@implementation AppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [DBClientsManager setupWithAppKey:@"keq5g8vwa0wwb1q"];
    [BOXContentClient setClientID:@"fydajs9irctec0s34ur0mgc41qyc63ch" clientSecret:@"pNzlQ7BPdxzn2LXRalQMjRAq4B77tlJv"];
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    self.importer = [[LBImporter alloc] init];
    self.playQueue = [[LBPlayQueue alloc] init];
    self.downloadManager = [[LBDownloadManager alloc] init];
    self.documentsManager = [[LBDocumentManager alloc] init];
    
    if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        [UINavigationBar appearance].tintColor = [UIColor blackColor];
    }
    
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont systemFontOfSize:16.0] forKey:UITextAttributeFont];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    
    return YES;
}


- (void) applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void) applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void) applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void) applicationDidBecomeActive:(UIApplication *)application {
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void) applicationWillTerminate:(UIApplication *)application {
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}


- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
    if (authResult != nil) {
        if ([authResult isSuccess]) {
            NSLog(@"Success! User is logged into Dropbox.");
            [[DBOAuthManager sharedOAuthManager] storeAccessToken:authResult.accessToken];
        } else if ([authResult isCancel]) {
            NSLog(@"Authorization flow was manually canceled by user!");
            [NSNotificationCenter.defaultCenter postNotificationName:LBDropboxLoginCancelled object:nil];
        } else if ([authResult isError]) {
            NSLog(@"Error: %@", authResult);
        }
    }
    return NO;
}

@end
