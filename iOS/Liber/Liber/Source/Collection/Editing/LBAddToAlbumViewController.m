//
//  LBAddToAlbumViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBAddToAlbumViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Album+Functions.h"
#import "Artist+Functions.h"
#import "UIViewController+InfoMessage.h"


@interface LBAddToAlbumViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;

@property (nonatomic, strong) NSArray* displayItems;
@property (nonatomic, strong) NSString* currentSearchString;

@end


@implementation LBAddToAlbumViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.searchBar.returnKeyType = UIReturnKeyDone;
    self.searchBar.enablesReturnKeyAutomatically = NO;
    self.currentSearchString = @"";
    
    self.tableView.
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self updateDisplayItems];
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


#pragma mark - Display Items

- (void) updateDisplayItems {
    
    BOOL gotSearchString = ![self.currentSearchString isEqualToString:@""] && self.currentSearchString;
    if (gotSearchString) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:
                                  @"(title CONTAINS[cd] %@) OR (artist.name CONTAINS[cd] %@)",
                                  self.currentSearchString,
                                  self.currentSearchString];
        self.displayItems = [Album MR_findAllSortedBy:@"title" ascending:YES withPredicate:predicate];
    }
    else {
        self.displayItems = [Album MR_findAllSortedBy:@"title" ascending:YES];
    }
    [self.tableView reloadData];
}


#pragma mark - Table View

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _displayItems.count;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AddToAlbumCell" forIndexPath:indexPath];
    Album* album = [self.displayItems objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = album.artist.name;
    cell.textLabel.text = album.title;
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.tracksToMoveAndAdd.count == 0) {
        [self presentInformalAlertWithTitle:@"Error" andMessage:@"No tracks to move!"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    Album* album = [self.displayItems objectAtIndex:indexPath.row];
    [self moveTrackToMoveAndAddToAlbum:album];
}


#pragma mark - Search Bar

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    self.currentSearchString = searchText;
    [self updateDisplayItems];
}


- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self.searchBar resignFirstResponder];
}


#pragma mark - Add and Move

- (void) moveTrackToMoveAndAddToAlbum:(Album*)album {
    
    NSLog(@"implement the move!");
}

@end
