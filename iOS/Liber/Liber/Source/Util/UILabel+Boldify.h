//
//  UILabel+Boldify.h
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Boldify)

- (void) boldSubstring: (NSString*) substring;
- (void) boldRange: (NSRange) range;

- (void) unboldSubstring:(NSString*)string;
- (void) unboldRange:(NSRange)range;

@end
