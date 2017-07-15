//
//  LBAlbumDetailNavigationBarTitleView.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBAlbumDetailNavigationBarTitleView.h"
#import "UILabel+Boldify.h"

@interface LBAlbumDetailNavigationBarTitleView()

@property (nonatomic, strong) NSString* albumTitle;
@property (nonatomic, strong) NSString* artistName;

@end


@implementation LBAlbumDetailNavigationBarTitleView


- (id) initWithFrame:(CGRect)frame albumTitle:(NSString*)albumTitle artistName:(NSString*)artistName {
    
    if (self = [super initWithFrame:frame]) {
        
        self.albumTitle = albumTitle;
        self.artistName = artistName;
        
        self.albumTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.albumTitleLabel.font = [UIFont boldSystemFontOfSize:13];
        self.albumTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.albumTitleLabel.text = albumTitle;
        
        self.artistNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.artistNameLabel.font = [UIFont systemFontOfSize:13];
        self.artistNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.artistNameLabel.text = artistName;
        
        [self addSubview:_albumTitleLabel];
        [self addSubview:_artistNameLabel];
    }
    [self updateConstraintsIfNeeded];
    
    [NSNotificationCenter.defaultCenter addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self removeConstraints:self.constraints];
        [self updateConstraints];
        
        if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation)) {
            self.albumTitleLabel.text = [NSString stringWithFormat:@"%@ - %@", self.albumTitle, self.artistName];
            [self.albumTitleLabel unboldSubstring:self.artistName];
            self.artistNameLabel.text = @"";
        }
        else {
            self.albumTitleLabel.text = self.albumTitle;
            self.artistNameLabel.text = self.artistName;
        }
        
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
    
    if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation)
        && !(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)) {
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_albumTitleLabel][_artistNameLabel]"
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
