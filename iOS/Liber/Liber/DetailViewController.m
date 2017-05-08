//
//  DetailViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "DetailViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void) configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = self.detailItem.timestamp.description;
    }
}


- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    

}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Managing the detail item

- (void) setDetailItem:(Event *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

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


@end
