//
//  LBMusicCollectionViewCell.h
//  Liber
//
//  Created by galzu on 25.05.17.
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBMusicCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView* imageView;
@property (nonatomic, weak) IBOutlet UILabel* artistName;
@property (nonatomic, weak) IBOutlet UILabel* albumTitle;

@end
