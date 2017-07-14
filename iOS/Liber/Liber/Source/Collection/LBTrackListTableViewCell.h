//
//  LBTrackListTableViewCell.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Track;


@interface LBTrackListTableViewCell : UITableViewCell

@property (nonatomic, strong) Track* track;

@property (nonatomic, weak) IBOutlet UIImageView* albumArtImageView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;

@end
