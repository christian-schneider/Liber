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


- (void) prepareUI {
    
    self.textField.text = self.track.title;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.titleLabel.text = self.track.title;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:self] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.textField resignFirstResponder]; 
    return YES;
}

@end
