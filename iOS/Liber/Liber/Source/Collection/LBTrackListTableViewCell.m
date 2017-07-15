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


@implementation LBTrackListTableViewCell

- (void) setTrack:(Track *)track {
    
    _track = track;
    self.titleLabel.text = [NSString stringWithFormat:@"%@ : %@", _track.artist.name, _track.title];
    [self.albumArtImageView setImage:_track.album.artwork];
}

@end
