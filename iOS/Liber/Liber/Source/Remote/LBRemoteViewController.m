//
//  LBRemoteViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBRemoteViewController.h"
#import "LBDropboxFolderViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>


@interface LBRemoteViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (strong, nonatomic) NSArray* menuEntries;

@end


@implementation LBRemoteViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    self.menuEntries = @[
        @{@"title" : @"Dropbox",
          @"segue" : @"showDropboxFolder",
          @"api"   : @"Dropbox",
          @"image" : @"Dropbox-icon"},
    ];
    
    self.title = NSLocalizedString(@"Import Music", nil);
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.menuEntries.count;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* entryDict = [self.menuEntries objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"remoteTableViewCell"];
    cell.textLabel.text = [entryDict objectForKey:@"title"];
    cell.imageView.image = [UIImage imageNamed:[entryDict objectForKey:@"image"]];
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* entry = [self.menuEntries objectAtIndex:indexPath.row];
    NSString* api = [entry objectForKey:@"api"];
    
    if ([api isEqualToString:@"Dropbox"]) {
        if (![DBClientsManager authorizedClient]) {
            [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                           controller:self
                                              openURL:^(NSURL *url) {
                                                  [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                                                      //
                                                  }];
            }];
        }
        
    }
    
    [self performSegueWithIdentifier:[entry objectForKey:@"segue"] sender:self];
}


- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // no implementation is ok here
}


- (NSArray*) tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *logout = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Logout" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [DBClientsManager unlinkAndResetClients];
        [tableView setEditing:NO animated:YES];
    }];
    logout.backgroundColor = [UIColor colorWithRed:0.188 green:0.514 blue:0.984 alpha:1];
    
    return @[logout]; // array with all the buttons. 1,2,3, etc...
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showDropboxFolder"]) {
        LBDropboxFolderViewController* dropboxFolderVC = [segue destinationViewController];
        dropboxFolderVC.folderPath = @"";  // start at the root, for now
    }
}


@end
