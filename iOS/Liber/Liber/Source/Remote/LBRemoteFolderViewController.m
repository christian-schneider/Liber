//
//  LBRemoteFolderViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBRemoteFolderViewController.h"
#import "AppDelegate.h"
#import "LBRemoteFile.h"
#import "LBRemoteFolder.h"
#import <MBProgressHUD/MBProgressHUD.h>


@interface LBRemoteFolderViewController ()

@property (nonatomic, strong) IBOutlet UITableView* tableView;

- (IBAction) showImportActionController;

@property (nonatomic, strong) MBProgressHUD *hud;

@end


@implementation LBRemoteFolderViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refreshControl;
    
    self.folderEntries = [NSMutableArray array];
    self.fileEntries = [NSMutableArray array];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    // add any required observer to self.observers, removal is handled in this class -> viewWillDisappear
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


- (void) setHeaderIcon:(UIImage *)image {
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewTapped:)]];
    self.navigationItem.titleView = imageView;
}


- (void) refresh:(UIRefreshControl*)refreshControl {
    
    [self.folderEntries removeAllObjects];
    [self.fileEntries removeAllObjects];
    [self.tableView reloadData];
    [self listRemoteFolder];
}


// must be implemented by subclass and call super
- (void) listRemoteFolder {
 
    
    [self.tableView.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - self.tableView.refreshControl.frame.size.height) animated:YES];
    
    // use the specific api here
    
    // when done loading LBRemoteFiles & LBRemoteFolders call listFolderComplete
}


- (void) listFolderCompleted {
    
    self.loaded = YES;
    [self.tableView.refreshControl endRefreshing];
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


// must be implemented by subclass!
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    // push a new correctly configured instance of this class on the navcontroller
    assert(0);
}


// must be implemented by subclass!
- (void) performLogout {
    
    assert(0);
}


#pragma mark - Logout

- (void) titleViewTapped:(UIGestureRecognizer*)recognizer {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    UIAlertAction* logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Logout", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performLogout];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }];
    [actionSheet addAction:logoutAction];
    
    actionSheet.view.tintColor = [UIColor blackColor];
    actionSheet.popoverPresentationController.sourceView = self.navigationItem.titleView;
    actionSheet.popoverPresentationController.sourceRect = self.navigationItem.titleView.bounds;
    [self presentViewController:actionSheet animated:YES completion:nil];
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
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.label.text = NSLocalizedString(@"Files added to download queue.", nil);
    [self.hud addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelHud)]];
    [self.hud hideAnimated:NO afterDelay:3.f];
}


- (void) cancelHud {
    
    [self.hud hide:YES];
    self.hud = nil;
}


// must be implemented by subclass!
- (void) downloadFileAndImportIntoLibrary:(NSString*)path {
    
    // see the LBDropboxFolderVC implementation for an example
    assert(0);
}


@end
