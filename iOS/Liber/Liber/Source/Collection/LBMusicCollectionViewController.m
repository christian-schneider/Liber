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


@interface LBMusicCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray* displayItems;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;

@end


@implementation LBMusicCollectionViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.displayItems = [Album MR_findAll];
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


@end
