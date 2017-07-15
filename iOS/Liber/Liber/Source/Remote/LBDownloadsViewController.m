//
//  LBDownloadsViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBDownloadsViewController.h"
#import "AppDelegate.h"
#import "LBDownloadItemTableViewCell.h"
#import "LBDownloadItem.h"


@interface LBDownloadsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@property (nonatomic, weak) AppDelegate* appDelegate;

@end


@implementation LBDownloadsViewController

- (void) viewDidLoad {

    [super viewDidLoad];

    self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    
    [NSNotificationCenter.defaultCenter addObserverForName:LBDownloadItemDownloadProgress object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.tableView reloadData];
    }];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.bounces = NO;
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [NSNotificationCenter.defaultCenter addObserverForName:LBAddedDownloadItemToQueue object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.tableView reloadData];
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:LBRemovedDownloadItemFromQueue object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.tableView reloadData];
    }];
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


#pragma mark - TableView data source & delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LBDownloadItem* downloadItem = [self.appDelegate.downloadManager.downloadQueue objectAtIndex:indexPath.row];
    
    LBDownloadItemTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadTableViewCell"];
    cell.downloadItem = downloadItem;
    cell.titleLabel.text = downloadItem.downloadPath.lastPathComponent;
    [cell updateProgressBar]; 
    return cell;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.appDelegate.downloadManager.downloadQueue.count;
}




@end
