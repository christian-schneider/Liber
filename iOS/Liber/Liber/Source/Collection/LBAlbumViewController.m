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
#import "LBPlayingTrackProgressCell.h"
#import "LBAlbumTrackTableViewCell.h"
#import "LBAlbumDetailNavigationBarTitleView.h"
#import "LBAlbumEditViewController.h"


@interface LBAlbumViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, weak) AppDelegate* appDelegate ;
@property (nonatomic, weak) LBPlayQueue* playQueue;

@property (nonatomic, strong) NSArray* observers;

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) LBPlayingTrackProgressCell* playingTrackCell;

@property (nonatomic, strong) UIView* albumArtHeaderView;
@property (nonatomic, strong) UIImageView* albumArtImageView;

@property (nonatomic, readwrite) BOOL presentingEditAlertController;

@end


@implementation LBAlbumViewController

#pragma mark - View Lifecycle

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
    
    self.albumArtHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    self.albumArtImageView = [[UIImageView alloc] initWithFrame:self.albumArtHeaderView.frame];
    [self.albumArtHeaderView addSubview:self.albumArtImageView];
    self.tableView.tableHeaderView = self.albumArtHeaderView;
    
    
    [NSNotificationCenter.defaultCenter addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        CGFloat newWidth = self.view.frame.size.width;
        CGRect artworkRect = CGRectMake(0, 0, newWidth, newWidth);
        self.albumArtHeaderView.frame = artworkRect;
        self.albumArtImageView.frame = artworkRect;
        [self.tableView reloadData];
    }];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (!self.album) return ;
    
    LBAlbumDetailNavigationBarTitleView* titleView = [[LBAlbumDetailNavigationBarTitleView alloc] initWithFrame:CGRectMake(0, 0, 300, 44.0) albumTitle:self.album.title artistName:self.album.artist.name];
    self.navigationItem.titleView = titleView;
    
    self.navigationController.navigationBar.topItem.title = @"";
    self.albumArtImageView.image = [UIImage imageWithData:self.album.image];
    self.albumArtImageView.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    lpgr.cancelsTouchesInView = NO;
    [self.albumArtImageView addGestureRecognizer:lpgr];
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self startObserving];
}


- (void) viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [self stopObserving];
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


#pragma mark - TableView delegate & dataSource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 125.0;
    }
    else {
        return 44.0;
    }
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
        Track* currentTrack = self.playQueue.currentTrack;
        LBPlayingTrackProgressCell* cell = (LBPlayingTrackProgressCell*)[tableView dequeueReusableCellWithIdentifier:@"PlayingTrackProgressCell"];
        [cell initialize];
        cell.album = self.album;
        
        if (!currentTrack || ![self.album.tracks containsObject:currentTrack]) {
            Track* firstTrack = [self.album.orderedTracks objectAtIndex:0];
            cell.trackTitleLabel.text = [self trackTitleLabelTextForTrack:firstTrack] ;
            cell.durationLabel.text = [NSString formatTime:firstTrack.duration];
        }
        
        if ([self.album.tracks containsObject:currentTrack]) { // the album with the current track currently played is displayed in this VC
            [cell updatePlayButtonImage:self.playQueue.isPlaying];
            cell.trackTitleLabel.text = [self trackTitleLabelTextForTrack:self.playQueue.currentTrack];
            cell.timeSlider.value = self.playQueue.currentTrackCurrentPercent;
            cell.currentTimeLabel.text = self.playQueue.currentTrackCurrentTime;
            cell.durationLabel.text = self.playQueue.currentTrackDuration;
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


- (NSString*) trackTitleLabelTextForTrack:(Track*)track {
    
    if (track.index > 0) {
        return [NSString stringWithFormat:@"%d. %@", track.index, track.displayTrackTitle];
    }
    else {
        return track.displayTrackTitle;
    }
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        [self.playQueue playAlbum:self.album trackAtIndex:indexPath.row];
    }
}


#pragma mark - Observing Notifications

- (void) startObserving {
    
    id observer1 = [[NSNotificationCenter defaultCenter] addObserverForName:LBCurrentTrackPlayProgress object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        Track* currentTrack = self.appDelegate.playQueue.currentTrack;
        if ([self.album.tracks containsObject:currentTrack]) {
            if (self.playingTrackCell) {
                NSDictionary* progressDict = note.object;
                self.playingTrackCell.currentTimeLabel.text = [progressDict objectForKey:@"currentTime"];
                self.playingTrackCell.durationLabel.text = [progressDict objectForKey:@"duration"];
                self.playingTrackCell.timeSlider.value = ((NSNumber*)[progressDict objectForKey:@"currentPercent"]).floatValue;
            }
        }
    }];
    
    id observer2 = [[NSNotificationCenter defaultCenter] addObserverForName:LBCurrentTrackStatusChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        [self handleCurrentTrackStatusChanged];
    }];
    
    
    id observer3 = [[NSNotificationCenter defaultCenter] addObserverForName:LBPlayQueueFinishedPlaying object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        [self handleCurrentTrackStatusChanged];
    }];
    
    self.observers = @[observer1, observer2, observer3];
}


- (void) stopObserving {
    
    for (id observer in self.observers) {
        [NSNotificationCenter.defaultCenter removeObserver:observer];
    }
}


- (void) handleCurrentTrackStatusChanged {
    
    [self.tableView reloadData];
    [self.playingTrackCell updatePlayButtonImage:self.playQueue.isPlaying];
}


#pragma mark - Long Press  

- (void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if (!self.presentingEditAlertController && !(self.album == self.appDelegate.playQueue.currentTrack.album)) {
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            self.presentingEditAlertController = NO;
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Edit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.presentingEditAlertController = NO;
            LBAlbumEditViewController* albumEditVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AlbumEditViewController"];
            albumEditVC.album = self.album;
            [self.navigationController pushViewController:albumEditVC animated:YES];
        }]];
        
        actionSheet.view.tintColor = [UIColor blackColor];
        self.presentingEditAlertController = YES;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        actionSheet.popoverPresentationController.sourceView = cell.contentView;
        
        CGRect rect = cell.contentView.frame;
        actionSheet.popoverPresentationController.sourceRect = rect;
        
        [self presentViewController:actionSheet animated:YES completion:nil];
        
    }
}


@end
