//
//  MasterViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBMasterViewController.h"
#import "LBMusicCollectionViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>


@interface LBMasterViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray* menuEntries;

@end


@implementation LBMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuEntries = @[
        @{@"title" : NSLocalizedString(@"Collection", @""),  @"segue" : @"showCollection"},
        @{@"title" : NSLocalizedString(@"Playlists", @""),   @"segue" : @"showPlaylists"},
        @{@"title" : NSLocalizedString(@"Remote", @""),      @"segue" : @"showRemote"}
    ];

    //self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}


- (void)viewWillAppear:(BOOL)animated {
    //self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}


#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showCollection"]) {
        NSLog(@"Switching to collection VC");
        /*
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Event *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        LBCollectionViewController *controller = (LBCollectionViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
         */
    }
    
    if ([[segue identifier] isEqualToString:@"showPlaylists"]) {
        NSLog(@"Switching to playlists VC");
    }
    
    if ([[segue identifier] isEqualToString:@"showRemote"]) {
        NSLog(@"Switching to remote VC");
    }
}


#pragma mark - Table View delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.menuEntries.count;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [[self.menuEntries objectAtIndex:indexPath.row] objectForKey:@"title"];
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* entry = [self.menuEntries objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:[entry objectForKey:@"segue"] sender:self];
}

@end
