//
//  LBBOXAuthorizationViewController.m
//  Liber
//
//  Created by galzu on 15.07.17.
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBBOXAuthorizationViewController.h"


@implementation LBBOXAuthorizationViewController

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}

@end
