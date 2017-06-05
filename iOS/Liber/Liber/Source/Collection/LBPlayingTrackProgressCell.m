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


@interface LBPlayingTrackProgressCell()

@property (nonatomic, weak) AppDelegate* appDelegate;

@end

@implementation LBPlayingTrackProgressCell


- (void) initialize {
    
    self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    
    self.trackTitleLabel.text = @"";
    self.timeSlider.value = 0.0;
    self.currentTimeLabel.text = @"0:00";
    self.durationLabel.text = @"0:00";
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.timeSlider setThumbImage:[UIImage imageNamed:@"TrackSliderHandle"] forState:UIControlStateNormal];
    [self.timeSlider addTarget:self action:@selector(timeSliderUpdated:) forControlEvents:UIControlEventValueChanged];
}


- (IBAction) playPauseButtonPressed {
    
    AppDelegate* appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate ;
    if (!appDelegate.playQueue.currentTrack ||
        (appDelegate.playQueue.currentTrack && ![self.album.tracks containsObject:appDelegate.playQueue.currentTrack])) {
        
        float timeSliderCurrentValue = self.timeSlider.value;
        [appDelegate.playQueue playAlbum:self.album trackAtIndex:0];
        if (timeSliderCurrentValue > 0.0) {
            [appDelegate.playQueue setCurrentTrackCurrentTimeRelative:self.timeSlider.value];
        }
    }
    else {
        [appDelegate.playQueue startOrPauseTrack:appDelegate.playQueue.currentTrack];
    }
}


- (IBAction) previousButtonPressed {
    
    [self.appDelegate.playQueue playPreviousTrack];
}


- (IBAction) nextButtonPressed {
    
    [self.appDelegate.playQueue playNextTrack];
}


- (void) updatePlayButtonImage:(BOOL)isPlaying {
    
    UIImage* buttonImage = isPlaying ? [UIImage imageNamed:@"PauseIconLarge"] : [UIImage imageNamed:@"PlayIconLarge"];
    [self.playPauseButton setImage:buttonImage forState:UIControlStateNormal];
}


- (void) timeSliderUpdated:(UISlider*)timeSlider {
    
    if ([self.album.tracks containsObject:self.appDelegate.playQueue.currentTrack]) {
        [self.appDelegate.playQueue setCurrentTrackCurrentTimeRelative:timeSlider.value];
    }
}


@end
