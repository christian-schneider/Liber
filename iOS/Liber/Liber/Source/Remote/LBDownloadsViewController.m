//
//  LBDownloadsViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBDownloadsViewController.h"
#import "AppDelegate.h"
#import "LBDownloadItemTableViewCell.h"


@interface LBDownloadsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@property (nonatomic, weak) AppDelegate* appDelegate;

@end


@implementation LBDownloadsViewController

- (void) viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - TableView data source & delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LBDownloadItem* downloadItem = [self.appDelegate.downloadManager.downloadQueue objectAtIndex:indexPath.row];
    
    LBDownloadItemTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadTableViewCell"];
    cell.downloadItem = downloadItem;
    
    
    return cell;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.appDelegate.downloadManager.downloadQueue.count;
}

@end
