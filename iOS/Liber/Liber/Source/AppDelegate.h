//
//  AppDelegate.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LBFilePlayer.h"
#import "LBImporter.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LBFilePlayer* filePlayer;
@property (strong, nonatomic) LBImporter* importer;


@end

