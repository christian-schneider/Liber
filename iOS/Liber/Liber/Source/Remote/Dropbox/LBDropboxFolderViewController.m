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
#import "LBImporter.h"
#import "LBDownloadItem.h"
#import "LBDownloadManager.h"


@interface LBDropboxFolderViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) DBUserClient* dropboxClient;
@property (nonatomic, weak) AppDelegate* appDelegate ;

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSMutableArray<LBRemoteFolder*>* folderEntries;
@property (nonatomic, strong) NSMutableArray<LBRemoteFile*>* fileEntries;

- (IBAction) showImportActionController;

@property (readwrite) BOOL loaded;
@property (readwrite) BOOL loginCancelledByUser;

@property (nonatomic, strong) NSArray* observers;

@end


@implementation LBDropboxFolderViewController


#pragma mark - View Lifecycle

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refreshControl;
    
    self.dropboxClient = [DBClientsManager authorizedClient];
    self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    
    self.folderEntries = [NSMutableArray arrayWithCapacity:10];
    self.fileEntries = [NSMutableArray arrayWithCapacity:10];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
}


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
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DropboxIcon"]];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewTapped:)]];
        self.navigationItem.titleView = imageView;
    }
    else {
        self.title = self.folderPath.lastPathComponent.stringByDeletingPathExtension.capitalizedString;
    }
    self.navigationController.hidesBarsOnSwipe = NO;
    
    if (!self.loaded && [DBClientsManager authorizedClient]) {
        // if the user logs out, then logs in again self.dropboxClient can be nil!!
        // if this is the case, assign the new instance
        self.dropboxClient = [DBClientsManager authorizedClient];
        [self listRemoteFolder];
    }
}


- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    for (id observer in self.observers) {
        [NSNotificationCenter.defaultCenter removeObserver:observer];
    }
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


- (void) refresh:(UIRefreshControl*)refreshControl {
    
    [self.folderEntries removeAllObjects];
    [self.fileEntries removeAllObjects];
    [self.tableView reloadData];
    [self listRemoteFolder];
}


#pragma mark - Dropbox Listing

- (void) listRemoteFolder {
    
    [self.tableView.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - self.tableView.refreshControl.frame.size.height) animated:YES];
    
    [[self.dropboxClient.filesRoutes listFolder:self.folderPath]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderError *routeError, DBRequestError *networkError) {
         if (response) {
             NSArray<DBFILESMetadata *> *entries = response.entries;
             NSString *cursor = response.cursor;
             BOOL hasMore = [response.hasMore boolValue];
             
             [self handleEntries:entries];
             
             if (hasMore) {
                 [self listFolderContinueWithClient:self.dropboxClient cursor:cursor];
             } else {
                 [self listFolderCompleted];
             }
             [self sortAndReloadData];
         } else {
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
         } else {
             NSLog(@"%@\n%@\n", routeError, networkError);
         }
     }];
}


- (void) listFolderCompleted {
    
    self.loaded = YES;
    [self.tableView.refreshControl endRefreshing];
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
        } else if ([entry isKindOfClass:[DBFILESFolderMetadata class]]) {
            
            DBFILESFolderMetadata *folderMetadata = (DBFILESFolderMetadata *)entry;
            //NSLog(@"Folder data: %@\n", folderMetadata);
            LBRemoteFolder* remoteFolder = [[LBRemoteFolder alloc] init];
            remoteFolder.path = folderMetadata.pathLower;
            remoteFolder.name = folderMetadata.name;
            [self.folderEntries addObject:remoteFolder];
            
        } else if ([entry isKindOfClass:[DBFILESDeletedMetadata class]]) {
            
            DBFILESDeletedMetadata *deletedMetadata = (DBFILESDeletedMetadata *)entry;
            NSLog(@"Deleted data: %@\n", deletedMetadata);
        }
    }
}


- (void) sortAndReloadData {
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.folderEntries = [self.folderEntries sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
    self.fileEntries = [self.fileEntries sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
    [self.tableView reloadData];
}


#pragma mark - TableView Delegate & DataSource


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2; // folders first, then files
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.folderEntries.count;
    }
    if (section == 1) {
        return self.fileEntries.count;
    }
    return 0;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell ;
    
    if (indexPath.section == 0) {  // folders
        cell = [tableView dequeueReusableCellWithIdentifier:@"folderTableViewCell"];
        LBRemoteFolder* remoteFolder = [self.folderEntries objectAtIndex:indexPath.row];
        cell.textLabel.text = remoteFolder.name;
        cell.imageView.image = [UIImage imageNamed:@"FolderIcon"];
    }
    if (indexPath.section == 1) {  // files
        cell = [tableView dequeueReusableCellWithIdentifier:@"fileTableViewCell"];
        LBRemoteFile* remoteFile = [self.fileEntries objectAtIndex:indexPath.row];
        cell.textLabel.text = remoteFile.name;
        cell.imageView.image = [UIImage imageNamed:@"AudioFileIcon"];
    }
    return cell ;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {       // folder
        LBRemoteFolder* remoteFolder = [self.folderEntries objectAtIndex:indexPath.row];
        LBDropboxFolderViewController *nextVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DropboxFolderViewController"];
        nextVC.folderPath = remoteFolder.path;
        [self.navigationController showViewController:nextVC sender:self];
    }
}


#pragma mark - Importing

- (IBAction) showImportActionController {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Import Media Files", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self importThisFolder];
    }]];
    
    actionSheet.view.tintColor = [UIColor blackColor];
    actionSheet.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self presentViewController:actionSheet animated:YES completion:nil];
}


- (void) importThisFolder {
    
    [self.appDelegate.importer cleanupTempDirectory];
    for (LBRemoteFile* remoteFile in self.fileEntries) {
        [self downloadFileAndImportIntoLibrary:remoteFile.path];
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
        
        DBDownloadUrlTask* downloadTask = [[[self.dropboxClient.filesRoutes downloadUrl:path overwrite:YES destination:outputUrl]
                                            setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *networkError,
                                                               NSURL *destination) {
                                                if (result) {
                                                    [downloadItem downloadComplete];
                                                    [self.appDelegate.importer importFileIntoLibraryAtPath:destination.path originalFilename:path.lastPathComponent];
                                                }
                                                else {
                                                    NSLog(@"Error downloading file from dropbox: %@  --  %@", routeError, networkError);
                                                }
                                            }] setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
                                                [downloadItem updateProgressBytesWritten:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpected:totalBytesExpectedToWrite];
                                            }];
        
        downloadItem.cancelTarget = downloadTask;
        downloadItem.cancelSelector = NSSelectorFromString(@"cancel");
        [self.appDelegate.downloadManager addItemToQueue:downloadItem];
    });
}


#pragma mark - Logout Dropbox

- (void) titleViewTapped:(UIGestureRecognizer*)recognizer {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    UIAlertAction* logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Logout", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [DBClientsManager unlinkAndResetClients];
        [self.navigationController popToRootViewControllerAnimated:YES];

    }];
    [actionSheet addAction:logoutAction];
    
    actionSheet.view.tintColor = [UIColor blackColor];
    actionSheet.popoverPresentationController.sourceView = self.navigationItem.titleView;
    actionSheet.popoverPresentationController.sourceRect = self.navigationItem.titleView.bounds;
    [self presentViewController:actionSheet animated:YES completion:nil];
}


@end
