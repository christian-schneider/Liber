//
//  LBAlbumViewController.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Album, Track;


@interface LBAlbumViewController : UIViewController

@property (nonatomic, strong) Album* album;
@property (nonatomic, weak) Track* preselectedTrack;

@end
