//
//  LBTrackEditTableViewCell.h
//  Liber
//
//  Created by galzu on 09.06.17.
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Track;

@interface LBTrackEditTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) Track* track;
@property (nonatomic, weak) UITableView* tableView;

@property (nonatomic, weak) IBOutlet UITextField* textField;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;


- (void) prepareUI;

@end
