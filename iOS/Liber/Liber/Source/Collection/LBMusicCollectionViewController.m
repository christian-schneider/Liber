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


@interface LBMusicCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) AppDelegate* appDelegate;

@property (nonatomic, strong) NSArray* displayItems;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;

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

@end


@implementation LBMusicCollectionViewController

#pragma mark - View Lifecycle

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    
    self.collectionView.alwaysBounceVertical = YES;
    self.searchBar.returnKeyType = UIReturnKeyDone;
    self.searchBar.enablesReturnKeyAutomatically = NO;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:lpgr];
    
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
    
    if (self.appDelegate.playQueue.currentTrack) {
        self.nowPlayingBarButtonItem.image = [[self imageAlbumArtResizedForBarButtonImtem:self.appDelegate.playQueue.currentTrack.artwork] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.leftBarButtonItems = @[self.nowPlayingBarButtonItem];
    }
    else {
        self.nowPlayingBarButtonItem.image = nil;
        self.navigationItem.leftBarButtonItems = @[];
    }
    
    [self updateDownloadsActivityIndicatorStatus];
    [self startObserving];
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


- (void) updateDisplayItems {
    
    self.displayItems = [Album MR_findAll];
    [self.collectionView reloadData];
}


- (void) updateDownloadsActivityIndicatorStatus {
    
    if (self.appDelegate.downloadManager.downloadQueue.count > 0) {
        [self.activityIndicator startAnimating];
    }
    else {
        [self.activityIndicator stopAnimating];
    }
}


#pragma mark - Collection View

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.displayItems.count;
}


- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
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


/*
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = self.view.frame.size.height;
    CGFloat width  = self.view.frame.size.width;
    // in case you you want the cell to be 40% of your controllers view
    return CGSizeMake(width*0.4,height*0.4);
}
*/


#pragma mark - Actions


- (void) pushAlbumViewControllerForAlbum:(Album*)album {
    
    LBAlbumViewController* albumViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AlbumViewController"];
    albumViewController.album = album;
    [self.navigationController pushViewController:albumViewController animated:YES];
}


- (IBAction) importMusicBarButtonItemAction {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    UIAlertAction* dropboxAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dropbox", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        LBDropboxFolderViewController* dropboxFolderVC = (LBDropboxFolderViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DropboxFolderViewController"];
        dropboxFolderVC.folderPath = @"";
        [self.navigationController pushViewController:dropboxFolderVC animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [dropboxAction setValue:[[UIImage imageNamed:@"DropboxIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [actionSheet addAction:dropboxAction];
    
    actionSheet.view.tintColor = [UIColor blackColor];
    [self presentViewController:actionSheet animated:YES completion:nil];
}


- (IBAction) filterBarButtonItemAction {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Filter" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Artist", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Track", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    actionSheet.view.tintColor = [UIColor blackColor];
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
    
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    }
    else {
        Album* album = [self.displayItems objectAtIndex:indexPath.row];
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.appDelegate.importer deleteAlbum:album];
        }]];
        
        
        actionSheet.view.tintColor = [UIColor blackColor];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}


#pragma mark - Observing

- (void) startObserving {
    
    [NSNotificationCenter.defaultCenter addObserverForName:LBMusicItemAddedToCollection object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateDisplayItems];
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:LBAlbumDeleted object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
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
