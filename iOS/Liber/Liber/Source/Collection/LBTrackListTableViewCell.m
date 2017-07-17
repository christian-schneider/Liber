//
//  LBTrackListTableViewCell.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBTrackListTableViewCell.h"
#import "Track+Functions.h"
#import "Album+Functions.h"
#import "Artist+Functions.h"
#import "UILabel+Boldify.h"


@implementation LBTrackListTableViewCell

- (void) setTrack:(Track *)track {
    
    _track = track;
    self.titleLabel.text = [NSString stringWithFormat:@"%@ \n%@", _track.title, _track.artist.name];
    [self.titleLabel boldSubstring:_track.artist.name];
    [self.albumArtImageView setImage:_track.album.artwork];
}

@end
