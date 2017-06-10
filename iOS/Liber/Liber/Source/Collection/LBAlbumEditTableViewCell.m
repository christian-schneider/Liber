//
//  LBAlbumEditTableViewCell.m
//  Liber
//
//  Created by galzu on 09.06.17.
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBAlbumEditTableViewCell.h"
#import "Album+Functions.h"
#import "Track+Functions.h"
#import "MLPAutoCompleteTextField.h"


@implementation LBAlbumEditTableViewCell


- (void) prepareUI {
    
    self.titleLabel.text = NSLocalizedString(@"Album", nil);
    self.autocompleteTextField.text = self.album.title;
    self.autocompleteTextField.autoCompleteTableAppearsAsKeyboardAccessory = YES;
    self.autocompleteTextField.returnKeyType = UIReturnKeyDone;
    self.autocompleteTextField.delegate = self;
}



- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void(^)(NSArray *suggestions))handler {
    
    handler([self.album allAlbumTitles]);
}


- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(selectedObject){
        NSLog(@"selected object from autocomplete menu %@ with string %@", selectedObject, [selectedObject autocompleteString]);
    } else {
        NSLog(@"selected string '%@' from autocomplete menu", selectedString);
    }
}


- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willHideAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    
    NSLog(@"Autocomplete table view will be removed from the view hierarchy");
}


- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    
    NSLog(@"Autocomplete table view will be added to the view hierarchy");
}


- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField didHideAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    
    NSLog(@"Autocomplete table view ws removed from the view hierarchy");
}


- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField didShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    
    NSLog(@"Autocomplete table view was added to the view hierarchy");
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:self] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}


@end
