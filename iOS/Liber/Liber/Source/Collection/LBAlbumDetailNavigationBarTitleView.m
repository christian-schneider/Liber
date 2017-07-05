//
//  LBAlbumDetailNavigationBarTitleView.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBAlbumDetailNavigationBarTitleView.h"


@implementation LBAlbumDetailNavigationBarTitleView


- (id) initWithFrame:(CGRect)frame albumTitle:(NSString*)albumTitle artistName:(NSString*)artistName {
    
    if (self = [super initWithFrame:frame]) {
        _albumTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _albumTitleLabel.font = [UIFont boldSystemFontOfSize:13];
        _albumTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _albumTitleLabel.text = albumTitle;
        
        _artistNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _artistNameLabel.font = [UIFont systemFontOfSize:13];
        _artistNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _artistNameLabel.text = artistName;
        
        [self addSubview:_albumTitleLabel];
        [self addSubview:_artistNameLabel];
    }
    [self updateConstraintsIfNeeded];
    
    [NSNotificationCenter.defaultCenter addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self removeConstraints:self.constraints];
        [self updateConstraints];
    }];
    
    return self;
}


- (void)setFrame:(CGRect)frame {
    
    [super setFrame:CGRectMake(35, 0, self.superview.bounds.size.width - 70.0, self.superview.bounds.size.height)];
}


- (void) updateConstraints {
    
    [super updateConstraints];
    
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(_albumTitleLabel,_artistNameLabel);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_albumTitleLabel]-|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:viewsDictionary];
    [self addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_artistNameLabel]-|"
                                                          options:0
                                                          metrics:nil
                                                            views:viewsDictionary];
    [self addConstraints:constraints];
    
    if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation)) {
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_albumTitleLabel][_artistNameLabel]"
                                                              options:0
                                                              metrics:nil
                                                                views:viewsDictionary];
    }
    else {
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_albumTitleLabel][_artistNameLabel]"
                                                              options:0
                                                              metrics:nil
                                                                views:viewsDictionary];
    }
    
    [self addConstraints:constraints];
}


@end
