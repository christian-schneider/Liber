//
//  LBAlbumEditTableViewCell.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBAlbumEditTableViewCell.h"
#import "Album+Functions.h"
#import "Track+Functions.h"
#import "MLPAutoCompleteTextField.h"
#import "AppDelegate.h"


@implementation LBAlbumEditTableViewCell


- (void) prepareUI {
    
    self.titleLabel.text = NSLocalizedString(@"Album", nil);
    self.autocompleteTextField.autoCompleteTableAppearsAsKeyboardAccessory = YES;
    self.autocompleteTextField.returnKeyType = UIReturnKeyDone;
    self.autocompleteTextField.delegate = self;
}


#pragma mark - Autocomplet delegate

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


- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:self] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}


- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    [NSNotificationCenter.defaultCenter postNotificationName:LBAlbumEditEnded object:self];
}


@end
