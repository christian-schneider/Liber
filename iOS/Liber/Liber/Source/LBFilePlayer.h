//
//  LBFilePlayer.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LBFilePlayer : NSObject

@property (nonatomic, strong) AVAudioPlayer *player;

- (void) play: (NSString*) path; // dont use!! temporary, todo: remove
- (void) play:(NSString*)path artist:(NSString*)artist trackTitle:(NSString*)trackTitle image:(UIImage*)image;

@end
