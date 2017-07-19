//
//  LBDropboxFolderViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBDropboxFolderViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "UIViewController+InfoMessage.h"
#import "LBRemoteFolder.h"
#import "LBRemoteFile.h"
#import "AppDelegate.h"
#import "LBDownloadItem.h"
#import <objc/runtime.h>


@implementation LBDropboxFolderViewController

#pragma mark - View Lifecycle

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id observer1 = [NSNotificationCenter.defaultCenter addObserverForName:LBDropboxLoginCancelled object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        self.loginCancelledByUser = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    self.observers = @[observer1];
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.loginCancelledByUser) {
        return;
    }
    
    if (![DBClientsManager authorizedClient]) {
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                       controller:self
                                          openURL:^(NSURL *url) {
                                              [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                                                  [self listRemoteFolder];
                                              }];
                                          }];
    }
    
    if ([self.folderPath isEqualToString:@""]) {
        [self setHeaderIcon:[UIImage imageNamed:@"DropboxIcon"]];
    }
    else {
        self.title = self.folderPath.lastPathComponent.stringByDeletingPathExtension.capitalizedString;
    }
    self.navigationController.hidesBarsOnSwipe = NO;
    
    if (!self.loaded && DBClientsManager.authorizedClient) {
        [self listRemoteFolder];
    }
}


#pragma mark - Dropbox api handling

- (void) listRemoteFolder {
    
    [super listRemoteFolder];
    
    [[DBClientsManager.authorizedClient.filesRoutes listFolder:self.folderPath]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderError *routeError, DBRequestError *networkError) {
         if (response) {
             NSArray<DBFILESMetadata *> *entries = response.entries;
             NSString *cursor = response.cursor;
             BOOL hasMore = [response.hasMore boolValue];
             
             [self handleEntries:entries];
             
             if (hasMore) {
                 [self listFolderContinueWithClient:DBClientsManager.authorizedClient cursor:cursor];
             } else {
                 [self listFolderCompleted];
             }
             [self sortAndReloadData];
         }
         else {
             NSString* message = networkError.userMessage ? networkError.userMessage : networkError.nsError.localizedDescription;
             [self presentInformalAlertWithTitle:@"Network error" andMessage:message];
             NSLog(@"%@\n%@\n", routeError, networkError);
         }
     }];
}


- (void)listFolderContinueWithClient:(DBUserClient *)client cursor:(NSString *)cursor {
    
    [[client.filesRoutes listFolderContinue:cursor]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderContinueError *routeError,
                        DBRequestError *networkError) {
         if (response) {
             NSArray<DBFILESMetadata *> *entries = response.entries;
             NSString *cursor = response.cursor;
             BOOL hasMore = [response.hasMore boolValue];
             
             [self handleEntries:entries];
             
             if (hasMore) {
                 [self listFolderContinueWithClient:client cursor:cursor];
             } else {
                 [self listFolderCompleted];
             }
             [self sortAndReloadData];
         }
         else {
             NSLog(@"%@\n%@\n", routeError, networkError);
         }
     }];
}


- (void) handleEntries:(NSArray<DBFILESMetadata *> *)entries {
    
    for (DBFILESMetadata *entry in entries) {
        if ([entry isKindOfClass:[DBFILESFileMetadata class]]) {
            
            DBFILESFileMetadata *fileMetadata = (DBFILESFileMetadata *)entry;
            //NSLog(@"File data: %@\n", fileMetadata);
            LBRemoteFile* remoteFile = [[LBRemoteFile alloc] init];
            remoteFile.path = fileMetadata.pathLower;
            remoteFile.name = fileMetadata.name;
            remoteFile.isPlayableMediaFile = [self.appDelegate.importer isPlayableMediaFileAtPath:remoteFile.path];
            if (remoteFile.isPlayableMediaFile) {
                [self.fileEntries addObject:remoteFile];
            }
        }
        else if ([entry isKindOfClass:[DBFILESFolderMetadata class]]) {
            
            DBFILESFolderMetadata *folderMetadata = (DBFILESFolderMetadata *)entry;
            //NSLog(@"Folder data: %@\n", folderMetadata);
            LBRemoteFolder* remoteFolder = [[LBRemoteFolder alloc] init];
            remoteFolder.path = folderMetadata.pathLower;
            remoteFolder.name = folderMetadata.name;
            [self.folderEntries addObject:remoteFolder];
        }
    }
}


- (void) downloadFileAndImportIntoLibrary:(NSString*)path {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        LBDownloadItem* downloadItem = [[LBDownloadItem alloc] init];
        downloadItem.downloadPath = path;
        downloadItem.isDownloading = YES;
        
        NSString* tempFileName = [@"import-" stringByAppendingString:self.appDelegate.importer.generateUUID];
        NSString* tempPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:tempFileName]
                              stringByAppendingPathExtension:path.pathExtension];
        NSURL* outputUrl = [NSURL fileURLWithPath:tempPath];
        
        DBDownloadUrlTask* downloadTask = [[[DBClientsManager.authorizedClient.filesRoutes
            downloadUrl:path overwrite:YES destination:outputUrl]
            setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *networkError, NSURL *destination) {
                if (result) {
                    [downloadItem downloadComplete];
                    [self.appDelegate.importer importFileIntoLibraryAtPath:destination.path originalFilename:path.lastPathComponent];
                }
                else {
                    NSLog(@"Error downloading file from dropbox: %@  --  %@", routeError, networkError);
                }
            }] setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
                [downloadItem updateProgressBytesWritten:totalBytesWritten totalBytesExpected:totalBytesExpectedToWrite];
            }];
        
        downloadItem.cancelTarget = downloadTask;
        downloadItem.cancelSelector = NSSelectorFromString(@"cancel");
        [self.appDelegate.downloadManager addItemToQueue:downloadItem];
    });
}


#pragma mark - TableView

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {       // folder
        LBRemoteFolder* remoteFolder = [self.folderEntries objectAtIndex:indexPath.row];
        LBDropboxFolderViewController *nextVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RemoteFolderViewController"];
        object_setClass(nextVC, [LBDropboxFolderViewController class]);
        nextVC.folderPath = remoteFolder.path;
        nextVC.folderDisplayName = remoteFolder.name; 
        [self.navigationController showViewController:nextVC sender:self];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}


#pragma mark - Logout Dropbox

- (void) performLogout {
    
    [DBClientsManager unlinkAndResetClients];
}


@end
