//
//  LBAlbumArtworkTableViewCell.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBAlbumArtworkTableViewCell.h"


@implementation LBAlbumArtworkTableViewCell


- (void) initialize {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.separatorInset = UIEdgeInsetsMake(0.f, self.bounds.size.width, 0.f, 0.f);
    self.artworkImageView.image = [UIImage imageNamed:@"TestPressing"];
}


- (void) adjustLayout {
    
    self.albumArtHeightConstraint.constant = self.artworkImageView.frame.size.width;
    //[self layoutIfNeeded];
}


@end
