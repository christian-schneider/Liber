//
//  UIimage+Functions.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "UIImage+Functions.h"


@implementation UIImage (Functions)


+ (UIImage*) imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsImageRenderer* renderer = [[UIGraphicsImageRenderer alloc] initWithSize:newSize];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    }];
}

@end
