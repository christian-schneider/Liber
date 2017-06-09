//
//  LBArtistEditTableViewCell.h
//  Liber
//
//  Created by galzu on 09.06.17.
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Artist;


@interface LBArtistEditTableViewCell : UITableViewCell

@property (nonatomic, weak) Artist* artist;
@property (nonatomic, weak) UITableView* tableView;

- (void) prepareUI;

@end
