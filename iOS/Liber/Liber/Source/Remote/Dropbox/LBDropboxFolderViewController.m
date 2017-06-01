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


@interface LBDropboxFolderViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) DBUserClient* dropboxClient;
@property (nonatomic, weak) AppDelegate* appDelegate ;

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSMutableArray<LBRemoteFolder*>* folderEntries;
@property (nonatomic, strong) NSMutableArray<LBRemoteFile*>* fileEntries;

- (IBAction) showImportActionController;

@property (readwrite) BOOL loaded;

@end


@implementation LBDropboxFolderViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dropboxClient = [DBClientsManager authorizedClient];
    self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    
    self.folderEntries = [NSMutableArray arrayWithCapacity:10];
    self.fileEntries = [NSMutableArray arrayWithCapacity:10];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refreshControl;
    
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
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
    
    if (!self.loaded) {
        [self listRemoteFolder];
    }
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


- (void) refresh:(UIRefreshControl*)refreshControl {
    
    [refreshControl endRefreshing];
    [self.folderEntries removeAllObjects];
    [self.fileEntries removeAllObjects];
    [self.tableView reloadData];
    [self listRemoteFolder];
}


- (void) listRemoteFolder {
    
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
                 // NSLog(@"List folder complete.");
                 self.loaded = YES;
             }
             [self.tableView reloadData];
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
                 NSLog(@"List folder complete.");
                 self.loaded = YES;
             }
             [self.tableView reloadData];
         } else {
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
        } else if ([entry isKindOfClass:[DBFILESFolderMetadata class]]) {
            
            DBFILESFolderMetadata *folderMetadata = (DBFILESFolderMetadata *)entry;
            NSLog(@"Folder data: %@\n", folderMetadata);
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
    
    if (indexPath.section == 0) {
        // folders
        cell = [tableView dequeueReusableCellWithIdentifier:@"folderTableViewCell"];
        LBRemoteFolder* remoteFolder = [self.folderEntries objectAtIndex:indexPath.row];
        cell.textLabel.text = remoteFolder.name;
        cell.imageView.image = [UIImage imageNamed:@"FolderIcon"];
    }
    if (indexPath.section == 1) {
        // files
        cell = [tableView dequeueReusableCellWithIdentifier:@"fileTableViewCell"];
        LBRemoteFile* remoteFile = [self.fileEntries objectAtIndex:indexPath.row];
        cell.textLabel.text = remoteFile.name;
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


- (IBAction) showImportActionController {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Import", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Folder", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self importThisFolder];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }]];
    
    actionSheet.view.tintColor = [UIColor blackColor];
    [self presentViewController:actionSheet animated:YES completion:nil];
}


- (void) importThisFolder {
    
    [self.appDelegate.importer cleanupTempDirectory];
    for (LBRemoteFile* remoteFile in self.fileEntries) {
        [self downloadFileAndImportIntoLibrary:remoteFile.path];
    }
}


- (void) downloadFileAndImportIntoLibrary:(NSString*)path {
    
    NSString* tempFileName = [@"import-" stringByAppendingString:self.appDelegate.importer.generateUUID];
    NSString* tempPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:tempFileName]
                          stringByAppendingPathExtension:path.pathExtension];
    NSURL* outputUrl = [NSURL fileURLWithPath:tempPath];
    
    [[self.dropboxClient.filesRoutes downloadUrl:path overwrite:YES destination:outputUrl]
     setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *networkError,
                        NSURL *destination) {
         if (result) {
             [self.appDelegate.importer importFileIntoLibraryAtPath:destination.path originalFilename:path.lastPathComponent];
         }
         else {
             NSLog(@"Error downloading file from dropbox: %@  --  %@", routeError, networkError);
         }
     }];
}


- (void) titleViewTapped:(UIGestureRecognizer*)recognizer {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    UIAlertAction* logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Logout", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [DBClientsManager unlinkAndResetClients];
        [self.navigationController popToRootViewControllerAnimated:YES];

    }];
    [actionSheet addAction:logoutAction];
    
    actionSheet.view.tintColor = [UIColor blackColor];
    [self presentViewController:actionSheet animated:YES completion:nil];
}


@end
