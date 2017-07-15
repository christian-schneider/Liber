//
//  LBArtistListTableViewCell.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBArtistListTableViewCell.h"
#import "Artist+Functions.h"
#import "Album+Functions.h"
#import "LBArtistAlbumsCollectionViewCell.h"
#import "AppDelegate.h"


@interface LBArtistListTableViewCell() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) UICollectionViewFlowLayout* flowLayout;

@end


@implementation LBArtistListTableViewCell

- (void) setArtist:(Artist *)artist {
    
    _artist = artist;
    self.nameLabel.text = _artist.name;
    
    if (!self.flowLayout) {
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout.itemSize = CGSizeMake(44, 44);
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        [self.collectionView setCollectionViewLayout:self.flowLayout];
        self.collectionView.showsHorizontalScrollIndicator = NO;
    }
    
    [self.collectionView reloadData];
}


#pragma mark - Collection View (Albums)

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.artist.albums.count;
}


- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LBArtistAlbumsCollectionViewCell* colViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ArtistAlbumsCollectionViewCell" forIndexPath:indexPath];
    Album* album = [self.artist.albumsSorted objectAtIndex:indexPath.row];
    [colViewCell.imageView setImage:album.artwork];
    return colViewCell;
}


- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Album* album = [self.artist.albumsSorted objectAtIndex:indexPath.row];
    [NSNotificationCenter.defaultCenter postNotificationName:LBCollectionShowAlbum object:album];
}


@end
