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
#import <id3/tag.h>



@interface LBDropboxFolderViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) DBUserClient* dropboxClient;
@property (weak, nonatomic) AppDelegate* appDelegate ;

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSMutableArray<LBRemoteFolder*>* folderEntries;
@property (nonatomic, strong) NSMutableArray<LBRemoteFile*>* fileEntries;

@end


@implementation LBDropboxFolderViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dropboxClient = [DBClientsManager authorizedClient];
    self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    
    self.folderEntries = [NSMutableArray arrayWithCapacity:10];
    self.fileEntries = [NSMutableArray arrayWithCapacity:10];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[self.dropboxClient.filesRoutes listFolder:self.folderPath]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderError *routeError, DBRequestError *networkError) {
         if (response) {
             NSArray<DBFILESMetadata *> *entries = response.entries;
             NSString *cursor = response.cursor;
             BOOL hasMore = [response.hasMore boolValue];
             
             [self handleEntries:entries];
             
             if (hasMore) {
                 NSLog(@"Folder is large enough where we need to call `listFolderContinue:`");
                 
                 [self listFolderContinueWithClient:self.dropboxClient cursor:cursor];
             } else {
                 NSLog(@"List folder complete.");
             }
             [self.tableView reloadData];
         } else {
             NSString* message = networkError.userMessage ? networkError.userMessage : networkError.nsError.localizedDescription;
             [self presentInformalAlertWithTitle:@"Network error" andMessage:message];
             NSLog(@"%@\n%@\n", routeError, networkError);
         }
     }];
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            remoteFile.isPlayableMediaFile = [self.appDelegate.importer isPlayableMediaFile:remoteFile.path];
            [self.fileEntries addObject:remoteFile];
            
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


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
        LBDropboxFolderViewController *nextVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"dropboxFolderViewController"];
        nextVC.folderPath = remoteFolder.path;
        [self.navigationController showViewController:nextVC sender:self];
    }
    
    if (indexPath.section == 1) {       // file
        LBRemoteFile* remoteFile = [self.fileEntries objectAtIndex:indexPath.row];
        if (remoteFile.isPlayableMediaFile) {
            [self downloadAndPlayFileAtPath:remoteFile.path];
        }
    }
}


- (void) downloadAndPlayFileAtPath:(NSString*)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *outputDirectory = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSURL *outputUrl = [outputDirectory URLByAppendingPathComponent:@"current.mp3"];
    
    [[[self.dropboxClient.filesRoutes downloadUrl:path overwrite:YES destination:outputUrl]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *networkError,
                         NSURL *destination) {
          if (result) {
              NSLog(@"%@\n", result);
              NSData *data = [[NSFileManager defaultManager] contentsAtPath:[destination path]];
              NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"%@\n", dataStr);
              
              NSString* artist = @"Unknown Artist";
              NSString* trackTitle = path.lastPathComponent.stringByDeletingPathExtension;
              
              if ([path.pathExtension isEqualToString:@"mp3"]) {
                  
                  // not working atm..
                  /*
                  ID3_Tag tag;
                  tag.Link([outputUrl.absoluteString UTF8String]);
                  
                  ID3_Frame *titleFrame = tag.Find(ID3FID_TITLE);
                  unicode_t const *value = titleFrame->GetField(ID3FN_TEXT)->GetRawUnicodeText();
                  NSString *title = [NSString stringWithCString:(char const *) value encoding:NSUnicodeStringEncoding];
                  NSLog(@"The title before is %@", title);
                  */
                  
                  // this works ;)
                  NSDictionary* id3Tags = [self.appDelegate.importer id3TagsForURL:outputUrl];
                  NSLog(@"thee tags: %@", id3Tags) ;
                  artist = [id3Tags objectForKey:@"artist"];
                  trackTitle = [id3Tags objectForKey:@"title"];
              }
              
              [self.appDelegate.filePlayer play:destination.path artist:artist trackTitle:trackTitle image:nil];
          } else {
              NSLog(@"%@\n%@\n", routeError, networkError);
          }
      }] setProgressBlock:^(int64_t bytesDownloaded, int64_t totalBytesDownloaded, int64_t totalBytesExpectedToDownload) {
          NSLog(@"%lld\n%lld\n%lld\n", bytesDownloaded, totalBytesDownloaded, totalBytesExpectedToDownload);
      }];
}

@end
