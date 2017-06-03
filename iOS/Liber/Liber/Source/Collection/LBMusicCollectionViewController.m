//
//  DetailViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBMusicCollectionViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Album+CoreDataClass.h"
#import "Artist+CoreDataClass.h"
#import "Track+CoreDataClass.h"
#import "LBMusicCollectionViewCell.h"
#import "LBAlbumViewController.h"
#import "LBDropboxFolderViewController.h"
#import "AppDelegate.h"


@interface LBMusicCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate> {
    
    BOOL showSearchBar;
}

@property (nonatomic, strong) NSArray* displayItems;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;

- (IBAction) actionBarButtonItemAction;
- (IBAction) filterBarButtonItemAction;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* filterBarButtonItem;

@property (nonatomic, strong) UIRefreshControl* refreshControl;


@property (nonatomic, weak) IBOutlet NSLayoutConstraint* searchBarHeightConstraint;
@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;

@end


@implementation LBMusicCollectionViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.collectionView.alwaysBounceVertical = YES;
    self.searchBar.returnKeyType = UIReturnKeyDone;
    self.searchBar.enablesReturnKeyAutomatically = NO;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:lpgr];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LBMusicItemAddedToCollection object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateDisplayItems];
    }];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.searchBarHeightConstraint.constant = 0.0f;
    [self updateDisplayItems];
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self updateDisplayItems];
    self.navigationController.hidesBarsOnSwipe = YES;
}


- (void) updateDisplayItems {
    
    self.displayItems = [Album MR_findAll];
    [self updateFilterButtonVisibilityStatus];
    [self.collectionView reloadData];
    
}


- (BOOL) prefersStatusBarHidden {
 
    return YES;
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
    LBAlbumViewController* albumViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AlbumViewController"];
    albumViewController.album = album;
    [self.navigationController pushViewController:albumViewController animated:YES];
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

- (IBAction) actionBarButtonItemAction {
    
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
        //self.filterBarButtonItem.title = NSLocalizedString(@"Album", nil);
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Artist", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //self.filterBarButtonItem.title = NSLocalizedString(@"Artist", nil);
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Track", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //self.filterBarButtonItem.title = NSLocalizedString(@"Track", nil);
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    actionSheet.view.tintColor = [UIColor blackColor];
    [self presentViewController:actionSheet animated:YES completion:nil];
}


#pragma mark - Search Bar

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (decelerate) {
        [self.searchBar resignFirstResponder];
    }
    
    if(scrollView.contentOffset.y < 0) {
        [self setShowSearchBar:!showSearchBar];
    }
}


- (void) setShowSearchBar:(BOOL)show {
    
    if (showSearchBar != show) {
        showSearchBar = show;
        [self updateSearchBarVisibility];
    }
}


- (BOOL) showSearchBar {
    
    return showSearchBar;
}


- (void) updateSearchBarVisibility {
    
    [self.view layoutIfNeeded];
    
    if (showSearchBar ) {
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


- (void) updateFilterButtonVisibilityStatus {
    
    if (self.displayItems.count == 0) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    else {
        self.navigationItem.leftBarButtonItem = self.filterBarButtonItem;
    }
}


#pragma mark - Item Delete

- (void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    }
    else {
        Album* album = [self.displayItems objectAtIndex:indexPath.row];
        NSLog(@"Ask to delete %@", album.title);
    }
}


@end
