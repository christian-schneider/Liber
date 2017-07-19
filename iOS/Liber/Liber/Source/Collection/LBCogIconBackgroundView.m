//
//  LBCogIconBackgroundView.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "LBCogIconBackgroundView.h"

@implementation LBCogIconBackgroundView


- (void) drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    
    CGContextMoveToPoint(context, 0.0f, 0.0f);
    CGContextAddLineToPoint(context, rect.size.width, 0.0);
    
    CGContextMoveToPoint(context, 0.0f, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);

    CGContextStrokePath(context);
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self setNeedsDisplay];
}


@end
