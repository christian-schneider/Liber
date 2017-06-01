//
//  NSString+Functions.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "NSString+Functions.h"


@implementation NSString (Functions)


+ (NSString*) formatTime:(double)time {
    
    int minutes = time / 60;
    int seconds = (int)time % 60;
    return [NSString stringWithFormat:@"%@%d:%@%d",
            minutes / 10 ? [NSString stringWithFormat:@"%d", minutes / 10] : @"",
            minutes % 10, [NSString stringWithFormat:@"%d", seconds / 10],
            seconds % 10];
}


@end
