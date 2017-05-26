//
//  LBAlbumViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBAlbumViewController.h"
#import "Album+CoreDataClass.h"
#import "Artist+CoreDataClass.h"
#import "Track+CoreDataClass.h"
#import "LBAlbumArtworkTableViewCell.h"
#import "LBAlbumTrackTableViewCell.h"


@interface LBAlbumViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@end


@implementation LBAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (!self.album) return ;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        Track* track = [self.album.tracks.allObjects objectAtIndex:indexPath.row];
        cell.textLabel.text = track.title;
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.section == 0 ? 324.f : 44.f ;
}

@end
