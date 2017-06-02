//
//  LBAlbumTrackTableViewCell.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 Used by LBAlbumViewController to display all the tracks in one album. If the respective track
 is currently played by the global player, the cell is highlighted.
 */
@interface LBAlbumTrackTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* trackTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel* trackNumberLabel;
@property (nonatomic, weak) IBOutlet UILabel* trackDurationLabel;

- (void) initialize;

@end
