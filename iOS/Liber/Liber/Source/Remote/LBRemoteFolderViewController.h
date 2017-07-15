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
@property (nonatomic, strong) NSString* folderDisplayName;

@property (readwrite) BOOL loginCancelledByUser;
@property (readwrite) BOOL loaded;

@property (nonatomic, weak) AppDelegate* appDelegate ;
@property (nonatomic, strong) NSArray* observers;

@property (nonatomic, strong) NSMutableArray<LBRemoteFolder*>* folderEntries;
@property (nonatomic, strong) NSMutableArray<LBRemoteFile*>* fileEntries;


- (void) listFolderCompleted;
- (void) sortAndReloadData;
- (void) setHeaderIcon:(UIImage*)image;

// must! be implemented by subclass
- (void) downloadFileAndImportIntoLibrary:(NSString*)path;
- (void) performLogout;
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

// must! be implemented by subclass and called on super
- (void) listRemoteFolder;


@end
