//
//  LBPlayingTrackProgressCell.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBPlayingTrackProgressCell.h"
#import "AppDelegate.h"
#import "LBPlayQueue.h"
#import "Album+Functions.h"


@implementation LBPlayingTrackProgressCell


- (void) initialize {
    
    self.trackTitleLabel.text = @"";
    self.timeSlider.value = 0.0;
    self.currentTimeLabel.text = @"0:00";
    self.durationLabel.text = @"0:00";
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.timeSlider setThumbImage:[UIImage imageNamed:@"TrackSliderHandle"] forState:UIControlStateNormal];
    [self.timeSlider addTarget:self action:@selector(timeSliderUpdated:) forControlEvents:UIControlEventValueChanged];
}


- (IBAction) playPauseButtonPressed {
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate ;
    if (!appDelegate.playQueue.currentTrack ||
        (appDelegate.playQueue.currentTrack && ![self.album.tracks containsObject:appDelegate.playQueue.currentTrack])) {
        [appDelegate.playQueue playAlbum:self.album trackAtIndex:0];
    }
    else {
        [appDelegate.playQueue startOrPauseTrack:appDelegate.playQueue.currentTrack];
    }
}


- (IBAction) previousButtonPressed {
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate ;
    [appDelegate.playQueue playPreviousTrack];
}


- (IBAction) nextButtonPressed {
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate ;
    [appDelegate.playQueue playNextTrack];
}


- (void) updatePlayButtonImage:(BOOL)isPlaying {
    
    UIImage* buttonImage = isPlaying ? [UIImage imageNamed:@"PauseIconLarge"] : [UIImage imageNamed:@"PlayIconLarge"];
    [self.playPauseButton setImage:buttonImage forState:UIControlStateNormal];
}


- (void) timeSliderUpdated:(UISlider*)timeSlider {
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate ;
    [appDelegate.playQueue setTrackCurrentTimeRelative:timeSlider.value];
}


@end
