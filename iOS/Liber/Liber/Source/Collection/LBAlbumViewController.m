//
//  LBAlbumViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBAlbumViewController.h"
#import "Album+CoreDataClass.h"
#import "Artist+CoreDataClass.h"
#import "Artist+Functions.h"
#import "Track+CoreDataClass.h"
#import "LBAlbumArtworkTableViewCell.h"
#import "LBAlbumTrackTableViewCell.h"
#import "AppDelegate.h"
#import "Album+Functions.h"


@interface LBAlbumViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) AppDelegate* appDelegate ;

@end


@implementation LBAlbumViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LBMusicItemAddedToCollection object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.tableView reloadData];
    }];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (!self.album) return ;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) return 1;
    if (section == 1) return self.album.tracks.count;
    return 0;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        LBAlbumArtworkTableViewCell* cell = (LBAlbumArtworkTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"AlbumArtworkTableViewCell"];
        cell.artworkImageView.image = [UIImage imageWithData:self.album.image];
        cell.albumArtistLabel.text = self.album.artist.name;
        cell.albumTitleLabel.text = self.album.title;
        return cell;
    }
    else {
        LBAlbumTrackTableViewCell* cell = (LBAlbumTrackTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"AlbumTrackTableViewCell"];
        Track* track = [[self.album orderedTracks] objectAtIndex:indexPath.row];
        if (self.album.artist != track.artist) {
            cell.trackTitleLabel.text = [NSString stringWithFormat:@"%@ - %@", track.artist.name, track.title];
        }
        else {
            cell.trackTitleLabel.text = track.title;
        }
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.section == 0 ? 360.f : 44.f ;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LBPlayQueue* playQueue = self.appDelegate.playQueue;
    Track* selectedTrack = [self.album.orderedTracks objectAtIndex:indexPath.row];
    
    [playQueue clearQueue];
    [playQueue addTracks:self.album.orderedTracks];
    [playQueue setCurrentTrack:selectedTrack];
    [playQueue startOrPauseTrack:selectedTrack];
}

@end
