//
//  LBPlayingTrackProgressCell.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBPlayingTrackProgressCell.h"
#import "AppDelegate.h"
#import "LBPlayQueue.h"


@implementation LBPlayingTrackProgressCell


- (void) initialize {
    
    self.trackTitleLabel.text = @"";
    self.timeSlider.value = 0.0;
    self.currentTimeLabel.text = @"0:00";
    self.durationLabel.text = @"0:00";
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.timeSlider setThumbImage:[UIImage imageNamed:@"TrackSliderHandle"] forState:UIControlStateNormal];
}


- (IBAction) playPauseButtonPressed {
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate ;
    [appDelegate.playQueue startOrPauseTrack:appDelegate.playQueue.currentTrack];
}


- (IBAction) previousButtonPressed {
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate ;
    [appDelegate.playQueue playPreviousTrack];
}


- (IBAction) nextButtonPressed {
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate ;
    [appDelegate.playQueue playNextTrack];
}


@end
