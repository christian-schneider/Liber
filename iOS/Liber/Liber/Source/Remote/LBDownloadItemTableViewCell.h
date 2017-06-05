//
//  LBDownloadItemTableViewCell.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LBDownloadItem;

@interface LBDownloadItemTableViewCell : UITableViewCell

@property (nonatomic, weak) LBDownloadItem* downloadItem;

@end
