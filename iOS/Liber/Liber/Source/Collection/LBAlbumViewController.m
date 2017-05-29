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
#import "LBAlbumDetailNavigationBarTitleView.h"


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
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (!self.album) return ;
    
    LBAlbumDetailNavigationBarTitleView* titleView = [[LBAlbumDetailNavigationBarTitleView alloc] initWithFrame:CGRectMake(0, 0, 300, 44.0) albumTitle:self.album.title artistName:self.album.artist.name];
    self.navigationItem.titleView = titleView;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
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

- (void) viewDidLayoutSubviews {
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
    LBAlbumArtworkTableViewCell* cell = (LBAlbumArtworkTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
    cell.albumArtHeightConstraint.constant = cell.artworkImageView.frame.size.width;
    [cell layoutIfNeeded];
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
