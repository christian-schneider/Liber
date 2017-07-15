//
//  LBBoxFolderViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBBoxFolderViewController.h"
#import <objc/runtime.h>
#import "LBDownloadItem.h"
@import BoxContentSDK;


@implementation LBBoxFolderViewController


#pragma mark - View lifecycle

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (!BOXContentClient.defaultClient.user) {
        [BOXContentClient.defaultClient authenticateWithCompletionBlock:^(BOXUser *user, NSError *error) {
            if (error == nil) {
                NSLog(@"Logged in user: %@", user.login);
                [self listRemoteFolder];
            }
            else {
                NSLog(@"Box, error: %@", error.description);
            }
        }];
    }
    
    if ([self.folderPath isEqualToString:BOXAPIFolderIDRoot]) {
        [self setHeaderIcon:[UIImage imageNamed:@"BoxIcon"]];
    }
    else {
        self.title = self.folderDisplayName;
    }
    self.navigationController.hidesBarsOnSwipe = NO;
    
    if (!self.loaded && BOXContentClient.defaultClient.user) {
        [self listRemoteFolder];
    }
}


#pragma mark - Remote api integration

- (void) listRemoteFolder {
    
    [super listRemoteFolder];
    
    BOXContentClient *contentClient = [BOXContentClient defaultClient];
    BOXFolderItemsRequest *folderItemsRequest = [contentClient folderItemsRequestWithID:self.folderPath];
    [folderItemsRequest performRequestWithCompletion:^(NSArray *items, NSError *error) {
        if (error) {
            NSLog(@"Box error: %@", error.localizedDescription);
        }
        else {
            for (id item in items) {
                BOXItem* boxItem = (BOXItem*)item;
                if (boxItem.isFolder) {
                    LBRemoteFolder* remoteFolder = [[LBRemoteFolder alloc] init];
                    remoteFolder.path = boxItem.modelID;
                    remoteFolder.name = boxItem.name;
                    [self.folderEntries addObject:remoteFolder];
                }
                else if (boxItem.isFile) {
                    LBRemoteFile* remoteFile = [[LBRemoteFile alloc] init];
                    remoteFile.path = boxItem.modelID;
                    remoteFile.name = boxItem.name;
                    remoteFile.isPlayableMediaFile = [self.appDelegate.importer isPlayableMediaFileAtPath:boxItem.name];
                    if (remoteFile.isPlayableMediaFile) {
                        [self.fileEntries addObject:remoteFile];
                    }
                }
            }
            [self listFolderCompleted];
            [self sortAndReloadData];
        }
    }];
}


- (void) downloadFileAndImportIntoLibrary:(NSString*)path {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        
        
        BOXFileRequest *fileInfoRequest = [BOXContentClient.defaultClient fileInfoRequestWithID:path];
        [fileInfoRequest performRequestWithCompletion:^(BOXFile *file, NSError *error) {
            if (!error) {
                LBDownloadItem* downloadItem = [[LBDownloadItem alloc] init];
                
                downloadItem.downloadPath = file.name;
                downloadItem.isDownloading = YES;
                
                NSString* tempFileName = [@"import-" stringByAppendingString:self.appDelegate.importer.generateUUID];
                NSString* tempPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:tempFileName]
                                      stringByAppendingPathExtension:file.name.pathExtension]; // !! needs the right file extension for artwork retrieval!!
                NSURL* outputUrl = [NSURL fileURLWithPath:tempPath];
                
                BOXContentClient *contentClient = [BOXContentClient defaultClient];
                NSString *localFilePath = tempPath;
                BOXFileDownloadRequest *boxRequest = [contentClient fileDownloadRequestWithID:path toLocalFilePath:localFilePath];
                [boxRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [downloadItem updateProgressBytesWritten:totalBytesTransferred totalBytesExpected:totalBytesExpectedToTransfer];
                    });
                } completion:^(NSError *error) {
    
                    if (!error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [downloadItem downloadComplete];
                            [self.appDelegate.importer importFileIntoLibraryAtPath:outputUrl.path originalFilename:file.name];
                        });
                    }
                    else {
                        NSLog(@"Box download failed: %@", error.description);
                    }
                    
                }];
                downloadItem.cancelTarget = boxRequest;
                downloadItem.cancelSelector = NSSelectorFromString(@"cancel");
                [self.appDelegate.downloadManager addItemToQueue:downloadItem];
            }
        }];
    });
}


#pragma mark - TableView selection

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {       // folder
        LBRemoteFolder* remoteFolder = [self.folderEntries objectAtIndex:indexPath.row];
        LBBoxFolderViewController *nextVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RemoteFolderViewController"];
        object_setClass(nextVC, [LBBoxFolderViewController class]);
        nextVC.folderPath = remoteFolder.path;
        nextVC.folderDisplayName = remoteFolder.name;
        [self.navigationController showViewController:nextVC sender:self];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}


#pragma mark - Logout Box

- (void) performLogout {
    
    [BOXContentClient logOutAll];
}



@end
