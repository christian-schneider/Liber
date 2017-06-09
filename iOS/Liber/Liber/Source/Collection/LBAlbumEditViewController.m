//
//  LBAlbumEditViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBAlbumEditViewController.h"
#import "Album+Functions.h"
#import "Track+Functions.h"
#import "Artist+Functions.h"
#import "LBTrackEditTableViewCell.h"
#import "LBArtistEditTableViewCell.h"
#import "LBAlbumEditTableViewCell.h"


@interface LBAlbumEditViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSMutableArray* orderedTracks;

- (IBAction)cancelAlbumEditing:(id)sender;
- (IBAction)saveEditedAlbum:(id)sender;

@end


@implementation LBAlbumEditViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    self.orderedTracks = self.album.tracks.allObjects.mutableCopy;
    
    self.navigationController.hidesBarsOnSwipe = NO;
    self.navigationController.navigationBar.hidden = NO;
    
    [self.tableView setEditing:YES animated:YES];
}


- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.navigationController.hidesBarsOnSwipe = YES;
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


#pragma mark - TableView Delegate & DataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0 || section == 1) return 1;
    return self.orderedTracks.count;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        LBAlbumEditTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"AlbumEditTableViewCell"];
        cell.album = self.album;
        cell.tableView = self.tableView;
        [cell prepareUI];
        return cell;
        
    }
    else if (indexPath.section == 1) {
        LBArtistEditTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ArtistEditTableViewCell"];
        cell.artist = self.album.artist;
        cell.tableView = self.tableView;
        [cell prepareUI];
        return cell;
        
    }
    else {
        LBTrackEditTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"TrackEditTableViewCell"];
        Track* track = [self.orderedTracks objectAtIndex:indexPath.row];
        cell.track = track;
        cell.tableView = self.tableView;
        [cell prepareUI];
        return cell;
    }
}


- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return indexPath.section == 2;
}


- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.section == 2;
}


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Track* trackToRemove = [self.orderedTracks objectAtIndex:indexPath.row];
        [self.orderedTracks removeObject:trackToRemove];
        [self.tableView reloadData];
    }
}


- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    Track* trackToMove = [self.orderedTracks objectAtIndex:sourceIndexPath.row];
    [self.orderedTracks removeObjectAtIndex:sourceIndexPath.row];
    [self.orderedTracks insertObject:trackToMove atIndex:destinationIndexPath.row];
    [self.tableView reloadData];
}


#pragma mark - Actions


- (IBAction)cancelAlbumEditing:(id)sender {
 
    [self.navigationController popViewControllerAnimated:YES];
}



- (IBAction)saveEditedAlbum:(id)sender {
    
    NSLog(@"TODO: implement save");
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
