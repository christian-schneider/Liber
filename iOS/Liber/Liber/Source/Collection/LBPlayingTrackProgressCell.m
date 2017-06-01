//
//  LBPlayingTrackProgressCell.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBPlayingTrackProgressCell.h"


@implementation LBPlayingTrackProgressCell


- (void) didMoveToSuperview {
    
    // called after loading of storyboard is complete but before dequeue happens
    
    self.trackTitleLabel.text = @"";
    self.timeSlider.value = 0.0;
    self.currentTimeLabel.text = @"0:00";
    self.durationLabel.text = @"0:00";
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.timeSlider setThumbImage:[UIImage imageNamed:@"TrackSliderHandle"] forState:UIControlStateNormal];
}


- (IBAction) playPauseButtonPressed {
    
    NSLog(@"playPause button pressed");
}


- (IBAction) previousButtonPressed {
    
    NSLog(@"previous button pressed");
}


- (IBAction) nextButtonPressed {
    
    NSLog(@"next button pressed");
}


@end
