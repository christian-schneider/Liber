//
//  LBPlayingTrackProgressCell.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Album;


/**
 Used in LBAlbumViewController. There is only ever one instance of such a cell. The
 album view controller stores a reference to this, as it is frequently updated in case 
 the track currently played by the global player is part of the displayed album.
 */
@interface LBPlayingTrackProgressCell : UITableViewCell

@property (nonatomic, weak) Album* album;

@property (nonatomic, weak) IBOutlet UILabel* currentTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel* durationLabel;
@property (nonatomic, weak) IBOutlet UISlider* timeSlider;
@property (nonatomic, weak) IBOutlet UILabel* trackTitleLabel;
@property (nonatomic, weak) IBOutlet UIButton* playPauseButton;

- (IBAction) playPauseButtonPressed;
- (IBAction) previousButtonPressed;
- (IBAction) nextButtonPressed;

- (void) initialize;

- (void) updatePlayButtonImage:(BOOL)isPlaying;

@end
