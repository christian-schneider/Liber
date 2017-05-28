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

- (void) play:(NSString*)path artist:(NSString*)artist trackTitle:(NSString*)trackTitle image:(UIImage*)image;


@property (readonly) BOOL isPlaying;
@property (readonly) NSString* playingArtist;
@property (readonly) NSString* playingTitle;
@property (readonly) UIImage* playingImage;

@end
