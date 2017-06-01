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
#import "LBPlayingTrackProgressCell.h"
#import "UIImage+Functions.h"
#import "NSString+Functions.h"


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

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self startObservingPlayProgress];
}


- (void) viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [self stopObservingPlayProgress];
}


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
        cell.artworkImageView.image = [UIImage imageWithData:self.album.image];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
        return cell;
    }
    else if (indexPath.section == 1) {
        LBPlayingTrackProgressCell* cell = (LBPlayingTrackProgressCell*)[tableView dequeueReusableCellWithIdentifier:@"PlayingTrackProgressCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.timeSlider.value = 0.0;
        cell.currentTimeLabel.text = @"0:00";
        cell.durationLabel.text = @"0:00";
        [cell.timeSlider setThumbImage:[UIImage imageWithImage:[UIImage imageNamed:@"circle-gray"] scaledToSize:CGSizeMake(17.0, 17.0)] forState:UIControlStateNormal];
        //cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
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
        cell.trackNumberLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
        cell.trackDurationLabel = [NSString formatTime:track.duration];
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
    
    if (indexPath.section == 2) {
        LBPlayQueue* playQueue = self.appDelegate.playQueue;
        Track* selectedTrack = [self.album.orderedTracks objectAtIndex:indexPath.row];
        
        [playQueue clearQueue];
        [playQueue addTracks:self.album.orderedTracks];
        [playQueue setCurrentTrack:selectedTrack];
        [playQueue startOrPauseTrack:selectedTrack];
    }
}


#pragma mark - Observe Play Progress

- (void) startObservingPlayProgress {
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LBCurrentTrackPlayProgress object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary* progressDict = note.object;
        
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:1];
        LBPlayingTrackProgressCell* cell = (LBPlayingTrackProgressCell*)[self.tableView cellForRowAtIndexPath:path];
        cell.currentTimeLabel.text = [progressDict objectForKey:@"currentTime"];
        cell.durationLabel.text = [progressDict objectForKey:@"duration"];
        cell.timeSlider.value = ((NSNumber*)[progressDict objectForKey:@"currentPercent"]).floatValue;
    }];
}


- (void) stopObservingPlayProgress {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LBCurrentTrackPlayProgress object:nil];
}


@end
