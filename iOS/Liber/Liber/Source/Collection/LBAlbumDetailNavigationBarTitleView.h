//
//  LBAlbumDetailNavigationBarTitleView.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LBAlbumDetailNavigationBarTitleView : UIView

@property (nonatomic, strong) UILabel* albumTitleLabel;
@property (nonatomic, strong) UILabel* artistNameLabel;

- (id) initWithFrame:(CGRect)frame albumTitle:(NSString*)albumTitle artistName:(NSString*)artistName;

@end
