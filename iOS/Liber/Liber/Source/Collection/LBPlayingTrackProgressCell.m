//
//  LBPlayingTrackProgressCell.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBPlayingTrackProgressCell.h"

@implementation LBPlayingTrackProgressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction) playPauseButtonPressed {
    
    NSLog(@"playPause button pressed");
}

@end
