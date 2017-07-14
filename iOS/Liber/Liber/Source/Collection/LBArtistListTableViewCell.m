//
//  LBArtistListTableViewCell.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBArtistListTableViewCell.h"
#import "Artist+Functions.h"

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
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView setCollectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor redColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



#pragma mark - Collection View (Albums)

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 5;
    //return self.artist.albums.count;
}


- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* colViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ArtistAlbumsCollectionViewCell" forIndexPath:indexPath];
    
    colViewCell.backgroundColor = UIColor.redColor;

    return colViewCell;
}


- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
}



@end
