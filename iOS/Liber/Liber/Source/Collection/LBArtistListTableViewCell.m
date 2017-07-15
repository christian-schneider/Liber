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

@end


@implementation LBArtistListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.itemSize = CGSizeMake(44, 44);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.collectionView setCollectionViewLayout:layout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    return self;
}


- (void) setArtist:(Artist *)artist {
    
    _artist = artist;
    self.nameLabel.text = _artist.name;
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
