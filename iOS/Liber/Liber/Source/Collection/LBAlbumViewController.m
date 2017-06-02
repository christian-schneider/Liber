//
//  LBAlbumViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBAlbumViewController.h"
#import "AppDelegate.h"
#import "LBPlayQueue.h"
#import "LBFilePlayer.h"
#import "UIImage+Functions.h"
#import "NSString+Functions.h"
#import "Album+Functions.h"
#import "Artist+Functions.h"
#import "Track+Functions.h"
#import "LBAlbumArtworkTableViewCell.h"
#import "LBPlayingTrackProgressCell.h"
#import "LBAlbumTrackTableViewCell.h"
#import "LBAlbumDetailNavigationBarTitleView.h"


@interface LBAlbumViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) AppDelegate* appDelegate ;
@property (nonatomic, weak) LBPlayQueue* playQueue;

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) LBPlayingTrackProgressCell* playingTrackCell;

@end


@implementation LBAlbumViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    self.playQueue = self.appDelegate.playQueue;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LBMusicItemAddedToCollection object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.tableView reloadData];
    }];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (!self.album) return ;
    
    LBAlbumDetailNavigationBarTitleView* titleView = [[LBAlbumDetailNavigationBarTitleView alloc] initWithFrame:CGRectMake(0, 0, 300, 44.0) albumTitle:self.album.title artistName:self.album.artist.name];
    self.navigationItem.titleView = titleView;
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self startObserving];
}


- (void) viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [self stopObserving];
}


- (void) viewDidLayoutSubviews {
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
    LBAlbumArtworkTableViewCell* cell = (LBAlbumArtworkTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
    [cell adjustLayout];
}


- (BOOL)prefersStatusBarHidden {
    
    return YES;
}


#pragma mark - TableView delegate & dataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section < 2) return 1;
    if (section == 2) return self.album.tracks.count;
    return 0;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        LBAlbumArtworkTableViewCell* cell = (LBAlbumArtworkTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"AlbumArtworkTableViewCell"];
        [cell initialize];
        if (self.album.image) {
            cell.artworkImageView.image = [UIImage imageWithData:self.album.image];
        }
        return cell;
    }
    else if (indexPath.section == 1) {
        LBPlayingTrackProgressCell* cell = (LBPlayingTrackProgressCell*)[tableView dequeueReusableCellWithIdentifier:@"PlayingTrackProgressCell"];
        [cell initialize];
        if (!self.appDelegate.playQueue.currentTrack) {
            cell.trackTitleLabel.text = ((Track*)[self.album.orderedTracks objectAtIndex:0]).displayTrackTitle;
        }
        else {
            cell.trackTitleLabel.text = self.appDelegate.playQueue.currentTrack.displayTrackTitle;
        }
        self.playingTrackCell = cell;
        return cell;
    }
    else {
        LBAlbumTrackTableViewCell* cell = (LBAlbumTrackTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"AlbumTrackTableViewCell"];
        [cell initialize];
        Track* track = [[self.album orderedTracks] objectAtIndex:indexPath.row];
        BOOL isCurrentTrack = self.appDelegate.playQueue.currentTrack == track;
        cell.trackTitleLabel.text = track.displayTrackTitle;
        cell.trackTitleLabel.font = isCurrentTrack ? [UIFont boldSystemFontOfSize:15.0] : [UIFont systemFontOfSize:15.0];
        cell.trackNumberLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
        cell.trackDurationLabel.text = [NSString formatTime:track.duration];
        return cell;
    }
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2) {
        Track* selectedTrack = [self.album.orderedTracks objectAtIndex:indexPath.row];
        [self.playQueue clearQueue];
        [self.playQueue addTracks:self.album.orderedTracks];
        [self.playQueue setCurrentTrack:selectedTrack];
        [self.playQueue startOrPauseTrack:selectedTrack];
    }
}


#pragma mark - Observe Play Progress

- (void) startObserving {
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LBCurrentTrackPlayProgress object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        if (self.playingTrackCell) {
            NSDictionary* progressDict = note.object;
            self.playingTrackCell.currentTimeLabel.text = [progressDict objectForKey:@"currentTime"];
            self.playingTrackCell.durationLabel.text = [progressDict objectForKey:@"duration"];
            self.playingTrackCell.timeSlider.value = ((NSNumber*)[progressDict objectForKey:@"currentPercent"]).floatValue;
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LBCurrentTrackStatusChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {

        NSMutableArray* indexPathsToReload = [NSMutableArray arrayWithCapacity:self.album.tracks.count+1];
        [indexPathsToReload addObject:[NSIndexPath indexPathForRow:0 inSection:1]];
        for (int i = 0 ; i < self.album.tracks.count ; i++) {
            [indexPathsToReload addObject:[NSIndexPath indexPathForRow:i inSection:2]];
        }
        
        [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationNone];
    }];
}


- (void) stopObserving {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LBCurrentTrackPlayProgress object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LBCurrentTrackStatusChanged object:nil];
}


@end
