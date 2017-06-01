//
//  LBAlbumTrackTableViewCell.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBAlbumTrackTableViewCell.h"


@implementation LBAlbumTrackTableViewCell


- (void) didMoveToSuperview {
    
    // called after loading of storyboard is complete but before dequeue happens
    
    self.trackTitleLabel.text = @"";
    self.trackNumberLabel.text = @"";
    self.trackDurationLabel.text = @"0:00";
}


@end
