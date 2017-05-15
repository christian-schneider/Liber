//
//  LBRemoteViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBRemoteViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>


@interface LBRemoteViewController ()

@property (strong, nonatomic) DBUserClient *dropboxClient;

@end

@implementation LBRemoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction) myButtonInControllerPressed:(UIButton*)sender {
    
    self.dropboxClient = [DBClientsManager authorizedClient];
    
    [[self.dropboxClient.filesRoutes listFolder:@""]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderError *routeError, DBRequestError *networkError) {
         if (response) {
             NSArray<DBFILESMetadata *> *entries = response.entries;
             NSString *cursor = response.cursor;
             BOOL hasMore = [response.hasMore boolValue];
             
             [self printEntries:entries];
             
             if (hasMore) {
                 NSLog(@"Folder is large enough where we need to call `listFolderContinue:`");
                 
                 [self listFolderContinueWithClient:self.dropboxClient cursor:cursor];
             } else {
                 NSLog(@"List folder complete.");
             }
         } else {
             NSString* message = networkError.userMessage ? networkError.userMessage : networkError.nsError.localizedDescription;
             [self presentErrorAlertWithTitle:@"Network error" andMessage:message];
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
             
             [self printEntries:entries];
             
             if (hasMore) {
                 [self listFolderContinueWithClient:client cursor:cursor];
             } else {
                 NSLog(@"List folder complete.");
             }
         } else {
             NSLog(@"%@\n%@\n", routeError, networkError);
         }
     }];
}


- (void)printEntries:(NSArray<DBFILESMetadata *> *)entries {
    for (DBFILESMetadata *entry in entries) {
        if ([entry isKindOfClass:[DBFILESFileMetadata class]]) {
            DBFILESFileMetadata *fileMetadata = (DBFILESFileMetadata *)entry;
            NSLog(@"File data: %@\n", fileMetadata);
        } else if ([entry isKindOfClass:[DBFILESFolderMetadata class]]) {
            DBFILESFolderMetadata *folderMetadata = (DBFILESFolderMetadata *)entry;
            NSLog(@"Folder data: %@\n", folderMetadata);
        } else if ([entry isKindOfClass:[DBFILESDeletedMetadata class]]) {
            DBFILESDeletedMetadata *deletedMetadata = (DBFILESDeletedMetadata *)entry;
            NSLog(@"Deleted data: %@\n", deletedMetadata);
        }
    }
}

#pragma mark - Convenience

- (void) presentErrorAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
