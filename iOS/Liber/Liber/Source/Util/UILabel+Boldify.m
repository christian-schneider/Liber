//
//  UILabel+Boldify.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "UILabel+Boldify.h"


@implementation UILabel (Boldify)


- (void) unboldSubstring:(NSString*)string {
    
    NSRange range = [self.text rangeOfString:string options:NSBackwardsSearch];
    [self unboldRange:range];
}


- (void) boldSubstring:(NSString*)string {
    
    NSRange range = [self.text rangeOfString:string options:NSBackwardsSearch];
    [self boldRange:range];
}


- (void) mediumSubstring:(NSString*)string {
    
    NSRange range = [self.text rangeOfString:string options:NSBackwardsSearch];
    [self mediumRange:range];
}


- (void) boldRange:(NSRange)range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:self.font.pointSize]} range:range];
    
    self.attributedText = attributedText;
}


- (void) unboldRange:(NSRange)range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.font.pointSize]} range:range];
    
    self.attributedText = attributedText;
}


- (void) mediumRange:(NSRange)range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:self.font.pointSize]} range:range];
    
    self.attributedText = attributedText;
}


@end
