//
//  LBRemoteViewController.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBRemoteViewController.h"
#import "LBDropboxFolderViewController.h"


@interface LBRemoteViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (strong, nonatomic) NSArray* menuEntries;

@end


@implementation LBRemoteViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    self.menuEntries = @[
        @{@"title" : NSLocalizedString(@"Dropbox", @""),  @"segue" : @"showDropboxFolder"},
    ];

}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.menuEntries.count;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"remoteTableViewCell"];
    cell.textLabel.text = [[self.menuEntries objectAtIndex:indexPath.row] objectForKey:@"title"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* entry = [self.menuEntries objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:[entry objectForKey:@"segue"] sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showDropboxFolder"]) {
        LBDropboxFolderViewController* dropboxFolderVC = [segue destinationViewController];
        dropboxFolderVC.folderPath = @"";  // start at the root, for now
    }
}


@end
