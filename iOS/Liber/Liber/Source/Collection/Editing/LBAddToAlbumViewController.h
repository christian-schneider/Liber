//
//  LBAddToAlbumViewController.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Track;


@interface LBAddToAlbumViewController : UIViewController

@property (nonatomic, strong) NSArray<Track*>* tracksToMoveAndAdd;

@end
