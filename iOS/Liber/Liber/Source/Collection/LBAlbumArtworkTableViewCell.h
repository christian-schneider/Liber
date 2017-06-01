//
//  LBAlbumArtworkTableViewCell.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 Used in LBAlbumViewController to display the album art. There is only ever one instance of such a cell.
 The height constraint is used to adjust the image view to a square on all supported devices and resolutions.
 */
@interface LBAlbumArtworkTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView* artworkImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* albumArtHeightConstraint;

@end
