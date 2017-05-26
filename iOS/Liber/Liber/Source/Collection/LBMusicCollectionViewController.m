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
#import "LBPlaylistsViewController.h"
#import "LBRemoteViewController.h"


@interface LBMusicCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray* displayItems;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;

- (IBAction) actionBarButtonItemAction;
- (IBAction) filterBarButtonItemAction;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* filterBarButtonItem;

@end


@implementation LBMusicCollectionViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.displayItems = [Album MR_findAll];
    self.filterBarButtonItem.title = NSLocalizedString(@"Album", nil);
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
    [colViewCell.imageView setImage:[UIImage imageWithData:album.image]];
    return colViewCell;
}


- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Album* album = [self.displayItems objectAtIndex:indexPath.row];
    LBAlbumViewController* albumViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AlbumViewController"];
    albumViewController.album = album;
    [self.navigationController pushViewController:albumViewController animated:YES];
}


- (IBAction) actionBarButtonItemAction {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    /*
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Playlists", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        LBPlaylistsViewController* pVC = (LBPlaylistsViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PlaylistsViewController"];
        [self.navigationController pushViewController:pVC animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    */
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Import Music", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        LBRemoteViewController* rVC = (LBRemoteViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RemoteViewController"];
        [self.navigationController pushViewController:rVC animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}


- (IBAction) filterBarButtonItemAction {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Filter" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.filterBarButtonItem.title = NSLocalizedString(@"Album", nil);
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Artist", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.filterBarButtonItem.title = NSLocalizedString(@"Artist", nil);
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Track", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.filterBarButtonItem.title = NSLocalizedString(@"Track", nil);
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}


@end
