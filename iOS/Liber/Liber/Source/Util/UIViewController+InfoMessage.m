//
//  UIViewController+InfoMessage.m
//  Liber
//
//  Copyright © 2017 Christian-Schneider. All rights reserved.
//

#import "UIViewController+InfoMessage.h"


@implementation UIViewController (InfoMessage)


- (void) presentInformalAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    alertController.view.tintColor = [UIColor blackColor];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
