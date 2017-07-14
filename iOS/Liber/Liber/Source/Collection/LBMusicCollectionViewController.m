//
//  DetailViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBMusicCollectionViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Album+Functions.h"
#import "Artist+Functions.h"
#import "Track+Functions.h"
#import "LBMusicCollectionViewCell.h"
#import "LBAlbumViewController.h"
#import "LBDropboxFolderViewController.h"
#import "AppDelegate.h"
#import "LBPlayQueue.h"
#import "LBDownloadsViewController.h"
#import "LBArtistListTableViewCell.h"
#import "LBTrackListTableViewCell.h"

typedef enum : NSUInteger {
    LBSortByAlbum,
    LBSortByArtist,
    LBSortByTrack,
    LBSortByLastPlayed,
    LBSortByLastAdded
} LBSortByType;


@interface LBMusicCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) AppDelegate* appDelegate;

@property (nonatomic, strong) NSArray* displayItems;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;
@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem* importMusicBarButtonItem; 
- (IBAction) importMusicBarButtonItemAction;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* filterBarButtonItem;
- (IBAction) filterBarButtonItemAction;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* nowPlayingBarButtonItem;
- (IBAction) nowPlayingBarButtonItemAction;

@property (nonatomic, strong) UIBarButtonItem* downloadsInProgressBarButtonItem;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;

@property (nonatomic, strong) UIRefreshControl* refreshControl;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* searchBarHeightConstraint;
@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;
@property (nonatomic, readwrite) BOOL showSearchBar;

@property (nonatomic, readwrite) BOOL presentingEditAlertController;

@property (nonatomic, readwrite) CGFloat itemSpacing;

@property (nonatomic, readwrite) LBSortByType sortByType;

@end


@implementation LBMusicCollectionViewController

#pragma mark - View Lifecycle

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    
    // collection view setup
    
    self.sortByType = LBSortByTrack;
    self.itemSpacing = 4.0;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 4.0, 0, 4.0);
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    lpgr.cancelsTouchesInView = NO;
    [self.collectionView addGestureRecognizer:lpgr];
    
    [NSNotificationCenter.defaultCenter addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.collectionView reloadData];
    }];
    
    // search bar
    
    self.searchBar.returnKeyType = UIReturnKeyDone;
    self.searchBar.enablesReturnKeyAutomatically = NO;
    
    // navigation bar
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    self.downloadsInProgressBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    UITapGestureRecognizer* downloadTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDownloadsInProgressBarButtonItemAction:)];
    [self.activityIndicator addGestureRecognizer:downloadTapRecogniser];
    
    self.navigationItem.rightBarButtonItems = @[self.importMusicBarButtonItem, self.filterBarButtonItem, self.downloadsInProgressBarButtonItem];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.searchBarHeightConstraint.constant = 0.0f;
    [self updateDisplayItems];
    
    [self updateNowPlayingBarButtonItem];
    
    [self updateDownloadsActivityIndicatorStatus];
    [self startObserving];
    
    if (self.sortByType == LBSortByAlbum) {
        [self showCollectionView];
    }
    else {
        [self showTableView];
    }
}


- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self stopObserving];
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self updateDisplayItems];
    self.navigationController.hidesBarsOnSwipe = YES;
}


- (BOOL) prefersStatusBarHidden {
 
    return YES;
}


#pragma mark - Status

- (void) updateNowPlayingBarButtonItem {
    
    if (self.appDelegate.playQueue.currentTrack) {
        self.nowPlayingBarButtonItem.image = [[self imageAlbumArtResizedForBarButtonImtem:self.appDelegate.playQueue.currentTrack.artwork] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.leftBarButtonItems = @[self.nowPlayingBarButtonItem];
    }
    else {
        self.nowPlayingBarButtonItem.image = nil;
        self.navigationItem.leftBarButtonItems = @[];
    }
}


- (void) updateDisplayItems {
    
    switch (self.sortByType) {
            
        default:
        case LBSortByAlbum:
            self.displayItems = [Album MR_findAllSortedBy:@"title" ascending:YES];
            break;
            
        case LBSortByArtist:
            self.displayItems = [Artist MR_findAllSortedBy:@"name" ascending:YES];
            break;
            
        case LBSortByTrack:
            self.displayItems = [Track MR_findAllSortedBy:@"artist.name,title" ascending:YES];
            break;
            
        case LBSortByLastPlayed:
            self.displayItems = [Album MR_findAllSortedBy:@"" ascending:YES];
            break ;
            
        case LBSortByLastAdded:
            self.displayItems = [Album MR_findAllSortedBy:@"" ascending:YES];
            break;
            
    }
    [self.collectionView reloadData];
    [self.tableView reloadData];
}


- (void) updateDownloadsActivityIndicatorStatus {
    
    if (self.appDelegate.downloadManager.downloadQueue.count > 0) {
        [self.activityIndicator startAnimating];
    }
    else {
        [self.activityIndicator stopAnimating];
    }
}


- (void) showCollectionView {
    
    if (self.collectionView.hidden == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.collectionView.alpha = 1.0;
        }];
    }
}


- (void) showTableView {
    
    if (self.tableView.hidden == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            self.collectionView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.tableView.alpha = 1.0;
        }];
    }
}


#pragma mark - Collection View (Albums)

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.sortByType == LBSortByAlbum) {
        return self.displayItems.count;
    }
    return 0; 
}


- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LBMusicCollectionViewCell* colViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"musicCollectionViewCell" forIndexPath:indexPath];
    Album* album = [self.displayItems objectAtIndex:indexPath.row];
    colViewCell.artistName.text = album.artist.name;
    colViewCell.albumTitle.text = album.title;
    colViewCell.albumTitle.lineBreakMode = NSLineBreakByWordWrapping;
    colViewCell.albumTitle.numberOfLines = 2;
    [colViewCell.imageView setImage:[UIImage imageWithData:album.image]];
    return colViewCell;
}


- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Album* album = [self.displayItems objectAtIndex:indexPath.row];
    [self pushAlbumViewControllerForAlbum:album];
}


- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return self.itemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return self.itemSpacing;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int numberOfItemsPerLine = 0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation)) {
            numberOfItemsPerLine = 6;
        }
        else {
            numberOfItemsPerLine = 4;
        }
    }
    else {
        if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation)) {
            numberOfItemsPerLine = 4;
        }
        else {
            numberOfItemsPerLine = 2;
        }
    }
    
    CGFloat screenWidth = self.view.frame.size.width - 2 * self.itemSpacing;
    CGFloat totalSpacing = self.itemSpacing * numberOfItemsPerLine;
    CGFloat itemSide = (screenWidth - totalSpacing) / numberOfItemsPerLine;
    return CGSizeMake(itemSide, itemSide + 40.0);
}


#pragma mark - Table View (Artists and Tracks)

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.sortByType == LBSortByArtist || self.sortByType == LBSortByTrack) {
        return self.displayItems.count;
    }
    return 0 ; 
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sortByType == LBSortByArtist) {
        LBArtistListTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ArtistListTableViewCell"];
        Artist* artist = [self.displayItems objectAtIndex:indexPath.row];
        cell.textLabel.text = artist.name;
        return cell;
    }
    else if (self.sortByType == LBSortByTrack) {
        LBTrackListTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"TrackListTableViewCell"];
        Track* track = [self.displayItems objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", track.artist.name, track.title];
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sortByType == LBSortByTrack) {
        Track* track = [self.displayItems objectAtIndex:indexPath.row];
        [self pushAlbumViewControllerForAlbum:track.album];
    }
}


#pragma mark - Actions


- (void) pushAlbumViewControllerForAlbum:(Album*)album {
    
    LBAlbumViewController* albumViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AlbumViewController"];
    albumViewController.album = album;
    [self.navigationController pushViewController:albumViewController animated:YES];
}


- (IBAction) importMusicBarButtonItemAction {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    UIAlertAction* dropboxAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dropbox", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        LBDropboxFolderViewController* dropboxFolderVC = (LBDropboxFolderViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DropboxFolderViewController"];
        dropboxFolderVC.folderPath = @"";
        [self.navigationController pushViewController:dropboxFolderVC animated:YES];
    }];
    [dropboxAction setValue:[[UIImage imageNamed:@"DropboxIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [actionSheet addAction:dropboxAction];
    
    actionSheet.view.tintColor = [UIColor blackColor];
    actionSheet.popoverPresentationController.barButtonItem = self.importMusicBarButtonItem;
    [self presentViewController:actionSheet animated:YES completion:nil];
}


- (IBAction) filterBarButtonItemAction {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Filter" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showCollectionView];
        self.sortByType = LBSortByAlbum;
        [self updateDisplayItems];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Artist", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showTableView];
        self.sortByType = LBSortByArtist;
        [self updateDisplayItems];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Track", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showTableView];
        self.sortByType = LBSortByTrack;
        [self updateDisplayItems];
    }]];
    
    actionSheet.view.tintColor = [UIColor blackColor];
    actionSheet.popoverPresentationController.barButtonItem = self.filterBarButtonItem;
    [self presentViewController:actionSheet animated:YES completion:nil];
}


- (IBAction) nowPlayingBarButtonItemAction {
    
    if (self.appDelegate.playQueue.currentTrack) {
        [self pushAlbumViewControllerForAlbum:self.appDelegate.playQueue.currentTrack.album];
    }
}


- (void) showDownloadsInProgressBarButtonItemAction:(UIGestureRecognizer*)tapGestureRecognizer {

    LBDownloadsViewController* downloadsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DownloadsViewController"];
    [self.navigationController pushViewController:downloadsVC animated:YES];
}


#pragma mark - Search Bar

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (decelerate) {
        [self.searchBar resignFirstResponder];
    }
    
    if(scrollView.contentOffset.y < 0) {
        [self setShowSearchBar:!self.showSearchBar];
    }
}


- (void) setShowSearchBar:(BOOL)show {
    
    if (_showSearchBar != show) {
        _showSearchBar = show;
        [self updateSearchBarVisibility];
    }
}


- (void) updateSearchBarVisibility {
    
    [self.view layoutIfNeeded];
    
    if (self.showSearchBar ) {
        self.searchBarHeightConstraint.constant = 50.0f;
        [self.searchBar becomeFirstResponder];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    else {
        self.searchBarHeightConstraint.constant = 0.0f;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}


- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSLog(@"Filter now for: %@", searchText);
    if ([searchText isEqualToString:@""]) {
        self.searchBarHeightConstraint.constant = 50.0f;
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}


- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self.searchBar resignFirstResponder];
}


#pragma mark - Long Press Actions

- (void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    //if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
    //    return;
    //}
    
    if (!self.presentingEditAlertController) {
        
        CGPoint point = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        if (indexPath == nil){
            NSLog(@"couldn't find index path");
        }
        else {
            Album* album = [self.displayItems objectAtIndex:indexPath.row];
            
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                self.presentingEditAlertController = NO;
            }]];
            
            [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.presentingEditAlertController = NO;
                [self.appDelegate.importer deleteAlbum:album];
            }]];
            
            actionSheet.view.tintColor = [UIColor blackColor];
            self.presentingEditAlertController = YES;
            
            UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            actionSheet.popoverPresentationController.sourceView = cell.contentView;
            
            CGRect rect = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
            actionSheet.popoverPresentationController.sourceRect = rect;
            
            [self presentViewController:actionSheet animated:YES completion:nil];
        }
    }
}


#pragma mark - Observing

- (void) startObserving {
    
    [NSNotificationCenter.defaultCenter addObserverForName:LBMusicItemAddedToCollection object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateDisplayItems];
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:LBAlbumDeleted object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateNowPlayingBarButtonItem];
        [self updateDisplayItems];
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:LBAddedDownloadItemToQueue object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        [self updateDownloadsActivityIndicatorStatus];
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:LBRemovedDownloadItemFromQueue object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        [self updateDownloadsActivityIndicatorStatus];
    }];
}


- (void) stopObserving {
    
    [NSNotificationCenter.defaultCenter removeObserver:self name:LBMusicItemAddedToCollection object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:LBAlbumDeleted object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:LBAddedDownloadItemToQueue object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:LBRemovedDownloadItemFromQueue object:nil];
}


#pragma mark - Utility 

- (UIImage*) imageAlbumArtResizedForBarButtonImtem:(UIImage*)albumArt {
    
    CGFloat length = 30.0;
    CGRect rect = CGRectMake(0,0,length,length);
    UIGraphicsBeginImageContext(rect.size);
    [albumArt drawInRect:rect];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIImage imageWithData:UIImagePNGRepresentation(resizedImage)];
}


@end
