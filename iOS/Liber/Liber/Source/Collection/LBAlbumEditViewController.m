//
//  LBAlbumEditViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBAlbumEditViewController.h"
#import "Album+Functions.h"
#import "Track+Functions.h"
#import "Artist+Functions.h"
#import "LBTrackEditTableViewCell.h"
#import "LBArtistEditTableViewCell.h"
#import "LBAlbumEditTableViewCell.h"
#import <Photos/Photos.h>
#import "AppDelegate.h"
#import "LBImporter.h"
#import <MagicalRecord/MagicalRecord.h>


@interface LBAlbumEditViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@property (nonatomic, weak) AppDelegate* appDelegate;

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIView* albumArtHeaderView;
@property (nonatomic, weak) IBOutlet UIImageView *albumArtImageView;


@property (nonatomic, strong) NSMutableArray* orderedTracks;

- (IBAction)cancelAlbumEditing:(id)sender;
- (IBAction)saveEditedAlbum:(id)sender;

@property (nonatomic, strong) UIImage* selectedAlbumArt;
@property (nonatomic, strong) NSString* editedAlbumTitle;
@property (nonatomic, strong) NSString* editedArtistName;
@property (nonatomic, strong) NSMutableArray* editedTrackNames;

@end


@implementation LBAlbumEditViewController


#pragma mark - View Lifecycle and Setup

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 220.0f)];
    
    UITapGestureRecognizer* imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseAlbumArt:)];
    [imageTapRecognizer setCancelsTouchesInView:NO];
    [self.albumArtImageView addGestureRecognizer:imageTapRecognizer];
    self.albumArtImageView.userInteractionEnabled = YES;
    
    [NSNotificationCenter.defaultCenter addObserverForName:LBTrackEditEnded object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        LBTrackEditTableViewCell* cell = (LBTrackEditTableViewCell*)note.object;
        NSIndexPath* path = [self.tableView indexPathForCell:cell];
        NSString* editedText = cell.textField.text;
        [self.editedTrackNames setObject:editedText atIndexedSubscript:path.row]; 
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:LBAlbumEditEnded object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        LBAlbumEditTableViewCell* cell = (LBAlbumEditTableViewCell*)note.object;
        self.editedAlbumTitle = cell.autocompleteTextField.text;
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:LBArtistEditEnded object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        LBArtistEditTableViewCell* cell = (LBArtistEditTableViewCell*)note.object;
        self.editedArtistName = cell.autocompleteTextField.text;
    }];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    self.orderedTracks = self.album.orderedTracks.mutableCopy;
    
    self.navigationController.hidesBarsOnSwipe = NO;
    self.navigationController.navigationBar.hidden = NO;
    
    [self.tableView setEditing:YES animated:YES];
    
    if (self.selectedAlbumArt) {
        self.albumArtImageView.image = self.selectedAlbumArt;
    }
    else {
        self.albumArtImageView.image = self.album.artwork;
    }
}


- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.navigationController.hidesBarsOnSwipe = YES;
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


- (void) setAlbum:(Album *)album {
    
    if (album != _album) {
        _album = album;
        self.editedTrackNames = [NSMutableArray arrayWithCapacity:_album.tracks.count];
        for (Track* track in _album.orderedTracks) {
            [self.editedTrackNames addObject:track.title];
        }
        self.editedArtistName = self.album.artist.name;
        self.editedAlbumTitle = self.album.title;
    }
}


#pragma mark - TableView Delegate & DataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0 || section == 1) return 1;
    return self.orderedTracks.count;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        LBAlbumEditTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"AlbumEditTableViewCell"];
        cell.album = self.album;
        cell.tableView = self.tableView;
        [cell prepareUI];
        cell.autocompleteTextField.text = self.editedAlbumTitle;
        return cell;
        
    }
    else if (indexPath.section == 1) {
        LBArtistEditTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ArtistEditTableViewCell"];
        cell.artist = self.album.artist;
        cell.tableView = self.tableView;
        [cell prepareUI];
        cell.autocompleteTextField.text = self.editedArtistName;
        return cell;
        
    }
    else {
        LBTrackEditTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"TrackEditTableViewCell"];
        Track* track = [self.orderedTracks objectAtIndex:indexPath.row];
        cell.track = track;
        cell.tableView = self.tableView;
        [cell prepareUI];
        cell.textField.text = [self.editedTrackNames objectAtIndex:indexPath.row];
        return cell;
    }
}


- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return indexPath.section == 2;
}


- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.section == 2;
}


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Track* trackToRemove = [self.orderedTracks objectAtIndex:indexPath.row];
        [self.orderedTracks removeObject:trackToRemove];
        [self.tableView reloadData];
    }
}


- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    Track* trackToMove = [self.orderedTracks objectAtIndex:sourceIndexPath.row];
    [self.orderedTracks removeObjectAtIndex:sourceIndexPath.row];
    [self.orderedTracks insertObject:trackToMove atIndex:destinationIndexPath.row];
    
    NSString* editedTrackTitle = [self.editedTrackNames objectAtIndex:sourceIndexPath.row];
    [self.editedTrackNames removeObjectAtIndex:sourceIndexPath.row];
    [self.editedTrackNames insertObject:editedTrackTitle atIndex:destinationIndexPath.row];
    
    [self.tableView reloadData];
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 78.0f;
}


#pragma mark - Album Art

- (void) chooseAlbumArt:(UIGestureRecognizer*)recognizer {
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}


- (void) showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {

    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
    
    [self presentViewController:imagePickerController animated:YES completion:^{
        //.. done presenting
    }];
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.albumArtImageView.image = image;
    self.selectedAlbumArt = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        //.. done dismissing
    }];
    [self.tableView reloadData];
}


- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:^{
        //.. done dismissing
    }];
}


#pragma mark - Actions

- (IBAction) cancelAlbumEditing:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction) saveEditedAlbum:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    NSMutableArray* trackPathsToImport = [NSMutableArray arrayWithCapacity:self.orderedTracks.count];
    
    // copy media file to temp folder and apply new tags
    
    NSInteger i = 0;
    for (Track* track in self.orderedTracks) {
        NSString* tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:track.fullPath.lastPathComponent];
        NSURL* outputUrl = [NSURL fileURLWithPath:tempPath];
        NSError* error = nil;
        [NSFileManager.defaultManager moveItemAtURL:[NSURL fileURLWithPath:track.fullPath] toURL:outputUrl error:&error];
        if (error) {
            NSLog(@"moving file failed!!! %@", track.fullPath.lastPathComponent);
        }
        else {
            [trackPathsToImport addObject:tempPath];
            [self.appDelegate.importer writeTagsToFile:tempPath albumTitle:self.editedAlbumTitle albumArtist:nil artist:self.editedArtistName trackTitle:[self.editedTrackNames objectAtIndex:i] trackNumber:i+1 artwor:self.albumArtImageView.image];
        }
        i++;
    }
    
    // remove old files from file sys and db
    
    for (Track* track in self.orderedTracks.reverseObjectEnumerator) {
        [self.album removeTracksObject:track];
        [self.album.artist removeTracksObject:track];
        [self.orderedTracks removeObject:track];
        [track MR_deleteEntity];
    }
    
    if (self.album.tracks.count == 0) {
        [self.album.artist removeAlbumsObject:self.album];
        [self.appDelegate.importer deleteAlbum:self.album];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    // import all files in temp folder
    
    for (NSString* path in trackPathsToImport) {
        [self.appDelegate.importer importFileIntoLibraryAtPath:path originalFilename:path.lastPathComponent];
    }
}


@end
