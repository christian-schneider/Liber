//
//  LBTrackEditTableViewCell.m
//  Liber
//
//  Created by galzu on 09.06.17.
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBTrackEditTableViewCell.h"
#import "Track+Functions.h"


@implementation LBTrackEditTableViewCell

- (void) awakeFromNib {
    
    [super awakeFromNib];
    // Initialization code
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) prepareUI {
    
    self.textField.text = self.track.title;
    self.textField.returnKeyType = UIReturnKeyDone;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:self] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.textField resignFirstResponder]; 
    return YES;
}

@end
