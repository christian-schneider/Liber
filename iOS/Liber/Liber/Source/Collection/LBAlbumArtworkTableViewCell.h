//
//  LBAlbumArtworkTableViewCell.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBAlbumArtworkTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView* artworkImageView;
@property (nonatomic, weak) IBOutlet UILabel* albumTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel* albumArtistLabel;

@end
