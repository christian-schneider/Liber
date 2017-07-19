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
#import "LBBoxFolderViewController.h"
#import "AppDelegate.h"
#import "LBPlayQueue.h"
#import "LBDownloadsViewController.h"
#import "LBArtistListTableViewCell.h"
#import "LBTrackListTableViewCell.h"
#import "UIImage+Functions.h"
#import <objc/runtime.h>
@import BoxContentSDK;


typedef enum : NSUInteger {
    LBSortByAlbum,
    LBSortByArtist,
    LBSortByTrack,
    LBSortByLastPlayed,
    LBSortByLastAdded
} LBSortByType;


@interface LBMusicCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) AppDelegate* appDelegate;
@property (nonatomic, strong) NSArray* observers;

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
@property (nonatomic, strong) NSString* currentSearchString;
@property (nonatomic, weak) IBOutlet UIButton* cogIconButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* cogIconWidthConstraint;
- (IBAction) cogIconAction;

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
    
    self.sortByType = LBSortByAlbum;
    self.itemSpacing = 4.0;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 4.0, 0, 4.0);
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 54.0;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
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
    self.currentSearchString = @"";
    self.cogIconWidthConstraint.constant = 0.0;
    self.searchBar.layer.borderWidth = 0.0;
    
    // navigation bar
    
    self.navigationItem.title = @" ";
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    self.downloadsInProgressBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    UITapGestureRecognizer* downloadTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDownloadsInProgressBarButtonItemAction:)];
    [self.activityIndicator addGestureRecognizer:downloadTapRecogniser];
    
    self.navigationItem.rightBarButtonItems = @[self.importMusicBarButtonItem, self.filterBarButtonItem, self.downloadsInProgressBarButtonItem];
    
    self.automaticallyAdjustsScrollViewInsets = NO; // check if this is really needed!
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self updateSearchBarVisibility];
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


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self updateDisplayItems];
    self.navigationController.hidesBarsOnSwipe = YES;
}


- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self stopObserving];
}


- (BOOL) prefersStatusBarHidden {
 
    return YES;
}


/*
    Reason for this extra update of the display items: when rotating very fast one way, then back in Album view mode
    the sizing of the collection view cell is not working properly. Under normal "civilized" rotation, this is not
    needed, but there are no visible artifacts from calling updateDisplayItems another time.
*/
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Stuff you used to do in willRotateToInterfaceOrientation would go here.
        // If you don't need anything special, you can set this block to nil.
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Stuff you used to do in didRotateFromInterfaceOrientation
        [self updateDisplayItems];
        
    }];
}


#pragma mark - Status

- (void) updateNowPlayingBarButtonItem {
    
    if (self.appDelegate.playQueue.currentTrack) {
        
        self.nowPlayingBarButtonItem.image = [[UIImage imageWithImage:self.appDelegate.playQueue.currentTrack.artwork scaledToSize:CGSizeMake(30.0, 30.0)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.leftBarButtonItems = @[self.nowPlayingBarButtonItem];
    }
    else {
        self.nowPlayingBarButtonItem.image = nil;
        self.navigationItem.leftBarButtonItems = @[];
    }
}


- (void) updateDisplayItems {
    
    BOOL gotSearchString = ![self.currentSearchString isEqualToString:@""] && self.currentSearchString;
   
    switch (self.sortByType) {
            
        default:
        case LBSortByAlbum:
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
            break;
            
        case LBSortByArtist:
            if (gotSearchString) {
                NSPredicate* predicate = [NSPredicate predicateWithFormat:
                                          @"(name CONTAINS[cd] %@)",
                                          self.currentSearchString];
                self.displayItems = [Artist MR_findAllSortedBy:@"name" ascending:YES withPredicate:predicate];
            }
            else {
                self.displayItems = [Artist MR_findAllSortedBy:@"name" ascending:YES];
            }
            break;
            
        case LBSortByTrack:
            if (gotSearchString) {
                NSPredicate* predicate = [NSPredicate predicateWithFormat:
                                          @"(title CONTAINS[cd] %@) OR (artist.name CONTAINS[cd] %@) OR (album.title CONTAINS[cd] %@)",
                                          self.currentSearchString,
                                          self.currentSearchString,
                                          self.currentSearchString];
                self.displayItems = [Track MR_findAllSortedBy:@"title,artist.name" ascending:YES withPredicate:predicate];
            }
            else {
                self.displayItems = [Track MR_findAllSortedBy:@"title,artist.name" ascending:YES];
            }
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
    [self updateSearchBarVisibility];
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
    [colViewCell.imageView setImage:album.artwork];
    return colViewCell;
}


- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Album* album = [self.displayItems objectAtIndex:indexPath.row];
    [self pushAlbumViewControllerForAlbum:album preselectedTrack:nil];
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
        cell.artist = artist; 
        return cell;
    }
    else if (self.sortByType == LBSortByTrack) {
        LBTrackListTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"TrackListTableViewCell"];
        Track* track = [self.displayItems objectAtIndex:indexPath.row];
        cell.track = track;
        return cell;
    }
    return [[UITableViewCell alloc] init];
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sortByType == LBSortByTrack && !self.tableView.isEditing) {
        Track* track = [self.displayItems objectAtIndex:indexPath.row];
        [self pushAlbumViewControllerForAlbum:track.album preselectedTrack:track];
    }
}


- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sortByType == LBSortByTrack) {
        return YES;
    }
    return NO;
}


#pragma mark - Actions


- (void) pushAlbumViewControllerForAlbum:(Album*)album preselectedTrack:(Track*)preselectedTrack {
    
    LBAlbumViewController* albumViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AlbumViewController"];
    albumViewController.album = album;
    if (preselectedTrack) {
        albumViewController.preselectedTrack = preselectedTrack;
    }
    [self.navigationController pushViewController:albumViewController animated:YES];
}


- (IBAction) importMusicBarButtonItemAction {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Import Music", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    // Dropbox
    
    UIAlertAction* dropboxAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dropbox", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        LBDropboxFolderViewController* dropboxFolderVC = (LBDropboxFolderViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RemoteFolderViewController"];
        object_setClass(dropboxFolderVC, [LBDropboxFolderViewController class]);
        dropboxFolderVC.folderPath = @"";
        [self.navigationController pushViewController:dropboxFolderVC animated:YES];
    }];
    [dropboxAction setValue:[[UIImage imageNamed:@"DropboxIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [actionSheet addAction:dropboxAction];
    
    
    // Box
    
    UIAlertAction* boxAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Box", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        LBBoxFolderViewController* boxFolderVC = (LBBoxFolderViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RemoteFolderViewController"];
        object_setClass(boxFolderVC, [LBBoxFolderViewController class]);
        boxFolderVC.folderPath = BOXAPIFolderIDRoot;
        [self.navigationController pushViewController:boxFolderVC animated:YES];
    }];
    [boxAction setValue:[[UIImage imageNamed:@"BoxIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [actionSheet addAction:boxAction];
    
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
        [self pushAlbumViewControllerForAlbum:self.appDelegate.playQueue.currentTrack.album preselectedTrack:nil];
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
    
    if (_showSearchBar && ![self.currentSearchString isEqualToString:@""]) return ;
    
    if (_showSearchBar != show) {
        _showSearchBar = show;
        [self updateSearchBarVisibility];
    }
}


- (void) updateSearchBarVisibility {
    
    [self.view layoutIfNeeded];
    
    if (self.showSearchBar ) {
        self.searchBarHeightConstraint.constant = 50.0f;
        //[self.searchBar becomeFirstResponder];
        if (self.sortByType == LBSortByTrack) {
            self.cogIconWidthConstraint.constant = 53.0f;
        }
        else {
            self.cogIconWidthConstraint.constant = 0.0f;
        }
    }
    else {
        self.searchBarHeightConstraint.constant = 0.0f;
        if (self.tableView.isEditing) {
            [self.tableView setEditing:NO animated:YES];
        }
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}


- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    self.currentSearchString = searchText;
    [self updateDisplayItems];
}


- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self.searchBar resignFirstResponder];
}


- (IBAction) cogIconAction {
    
    if (!self.tableView.isEditing) {
        [self.tableView setEditing:YES animated:YES];
    }
    else {
        
        if (self.tableView.indexPathsForSelectedRows.count > 0) {
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self.tableView setEditing:NO animated:YES];
            }]];
            
            [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Move to Album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSLog(@"move these!");
            }]];
            
            [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create new Album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSLog(@"create new album for these!");
            }]];
            
            actionSheet.view.tintColor = [UIColor blackColor];
            actionSheet.popoverPresentationController.sourceRect = self.cogIconButton.frame;
            [self presentViewController:actionSheet animated:YES completion:nil];
        }
        else {
            [self.tableView setEditing:NO animated:YES];
        }
    }
}


#pragma mark - Long Press Actions

- (void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
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
    
    id observer1 = [NSNotificationCenter.defaultCenter addObserverForName:LBMusicItemAddedToCollection object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateDisplayItems];
    }];
    
    id observer2 = [NSNotificationCenter.defaultCenter addObserverForName:LBAlbumDeleted object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateNowPlayingBarButtonItem];
        [self updateDisplayItems];
    }];
    
    id observer3 = [NSNotificationCenter.defaultCenter addObserverForName:LBAddedDownloadItemToQueue object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        [self updateDownloadsActivityIndicatorStatus];
    }];
    
    id observer4 = [NSNotificationCenter.defaultCenter addObserverForName:LBRemovedDownloadItemFromQueue object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        [self updateDownloadsActivityIndicatorStatus];
    }];
    
    id observer5 = [NSNotificationCenter.defaultCenter addObserverForName:LBCollectionShowAlbum object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        Album* album = note.object;
        [self pushAlbumViewControllerForAlbum:album preselectedTrack:nil];
    }];
    
    self.observers = @[observer1, observer2, observer3, observer4, observer5];
}


- (void) stopObserving {
    
    for (id observer in self.observers) {
        [NSNotificationCenter.defaultCenter removeObserver:observer];
    }
}


@end
