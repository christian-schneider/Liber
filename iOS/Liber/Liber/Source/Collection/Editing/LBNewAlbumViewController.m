//
//  LBNewAlbumViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBNewAlbumViewController.h"
#import "UIViewController+InfoMessage.h"

@interface LBNewAlbumViewController ()

@property (nonatomic, weak) IBOutlet UILabel* headerLabel;
@property (nonatomic, weak) IBOutlet UILabel* albumTitleLabel;
@property (nonatomic, weak) IBOutlet UITextField* albumTitleTextField;
@property (nonatomic, weak) IBOutlet UILabel* artistNameLabel;
@property (nonatomic, weak) IBOutlet UITextField* artistNameTextField;
@property (nonatomic, weak) IBOutlet UILabel* compilationLabel;
@property (nonatomic, weak) IBOutlet UISwitch* compilationSwitch;
@property (nonatomic, weak) IBOutlet UILabel* compilationHelpTextLabel;

@property (nonatomic, weak) IBOutlet UIBarButtonItem* createBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* cancelBarButtonItem;

@property (nonatomic, strong) id observer;

@end


@implementation LBNewAlbumViewController


#pragma mark - View Lifecycle

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.headerLabel.text = NSLocalizedString(@"New Album", nil) ;
    self.albumTitleLabel.text = NSLocalizedString(@"Title", nil) ;
    self.artistNameLabel.text = NSLocalizedString(@"Artist", nil) ;
    self.compilationLabel.text = NSLocalizedString(@"Compilation", nil) ;
    self.compilationHelpTextLabel.text = NSLocalizedString(@"For a compilation use a descriptive name like 'Various' in the artist field", nil);
    self.compilationSwitch.on = NO;
    
    self.navigationController.hidesBarsOnSwipe = NO;
    
    self.createBarButtonItem.title = NSLocalizedString(@"Create", nil);
    self.cancelBarButtonItem.title = NSLocalizedString(@"Cancel", nil);
    
    self.observer = [NSNotificationCenter.defaultCenter addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.view layoutSubviews];
    }];
}


- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self.observer];
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


#pragma mark - Actions

- (IBAction) cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES]; 
}


- (IBAction)create:(id)sender {
    
    NSString* albumTitle = [self.albumTitleLabel.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    NSString* artistName = [self.artistNameLabel.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    NSString* albumArtist = nil;
    BOOL isCompilation = self.compilationSwitch.on;
    if (isCompilation) {
        albumArtist = artistName;
    }
    
    if (albumTitle.length == 0) {
        [self presentInformalAlertWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"Album title empty.", nil)];
        return;
    }
    
    if (artistName.length == 0) {
        [self presentInformalAlertWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"Artist name empty.", nil)];
        return;
    }
    
    
    
    NSLog(@"create");
}

@end
