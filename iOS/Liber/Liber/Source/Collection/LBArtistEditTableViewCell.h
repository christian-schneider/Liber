//
//  LBArtistEditTableViewCell.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLPAutoCompleteTextField.h"
@class Artist;


@interface LBArtistEditTableViewCell : UITableViewCell <MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource, UITextFieldDelegate>

@property (nonatomic, weak) Artist* artist;
@property (nonatomic, weak) UITableView* tableView;

@property (nonatomic, weak) IBOutlet MLPAutoCompleteTextField* autocompleteTextField;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;

- (void) prepareUI;

@end
