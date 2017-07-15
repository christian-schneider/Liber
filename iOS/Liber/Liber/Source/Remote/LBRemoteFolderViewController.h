//
//  LBRemoteFolderViewController.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "LBRemoteFolder.h"
#import "LBRemoteFile.h"

@interface LBRemoteFolderViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString* folderPath;

@property (nonatomic, weak) AppDelegate* appDelegate ;

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSMutableArray<LBRemoteFolder*>* folderEntries;
@property (nonatomic, strong) NSMutableArray<LBRemoteFile*>* fileEntries;

- (IBAction) showImportActionController;

@property (readwrite) BOOL loaded;
@property (readwrite) BOOL loginCancelledByUser;

@property (nonatomic, strong) NSArray* observers;


- (void) listRemoteFolder;
- (void) listFolderCompleted;
- (void) sortAndReloadData;

- (void) downloadFileAndImportIntoLibrary:(NSString*)path;

- (void) setHeaderIcon:(UIImage*)image; 

@end
