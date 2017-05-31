//
//  LBPlayingTrackProgressCell.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBPlayingTrackProgressCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* currentTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel* durationLabel;
@property (nonatomic, weak) IBOutlet UISlider* timeSlider;
@property (nonatomic, weak) IBOutlet UILabel* trackTitleLabel;
@property (nonatomic, weak) IBOutlet UIButton* playPauseButton;

- (IBAction) playPauseButtonPressed;

@end
