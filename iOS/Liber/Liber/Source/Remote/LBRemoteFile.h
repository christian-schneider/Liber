//
//  LBRemoteFile.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LBRemoteFile : NSObject

@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) NSString* name;
@property (readwrite) BOOL isPlayableMediaFile;

@end
