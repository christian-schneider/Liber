//
//  LBTrackEditTableViewCell.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBTrackEditTableViewCell.h"
#import "Track+Functions.h"
#import "AppDelegate.h"


@implementation LBTrackEditTableViewCell


- (void) prepareUI {
    
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


- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    [NSNotificationCenter.defaultCenter postNotificationName:LBTrackEditEnded object:self];
}

@end
